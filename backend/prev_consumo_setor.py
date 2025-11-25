import pandas as pd
from prophet import Prophet
from supabase import create_client, Client
import os
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from prev_estoque_item import ConsumoException 

load_dotenv()
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("ERRO: Variáveis de ambiente Supabase não configuradas!")
    exit()

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

router = APIRouter()

def _get_setor_data(setor_id: int) -> pd.DataFrame:
    print(f"\n[API-CONSUMO] Buscando dados para Setor ID: {setor_id}")
    try:
        response = supabase.table('mov_estoque') \
            .select('mve_data_mov, mve_qtd_movimentada, item!inner(id, grupo!inner(id, grp_setor_id))') \
            .eq('item.grupo.grp_setor_id', setor_id) \
            .eq('mve_tipo', 'SAÍDA') \
            .execute()
        
        print(f"[API-CONSUMO-DEBUG] Recebidas {len(response.data)} movimentações para o Setor {setor_id}.")

        if not response.data:
            raise ConsumoException(f"Sem dados históricos para o setor {setor_id}.")

    except Exception as e:
        print(f"[API-CONSUMO-ERRO] Falha ao buscar dados: {e}")
        raise ConsumoException(str(e))

    print(f"[API-CONSUMO] Preparando dados para Setor ID: {setor_id}...")
    df = pd.DataFrame(response.data)

    df['mve_data_mov'] = pd.to_datetime(df['mve_data_mov'], format='ISO8601')
    df_resampled = df.resample('D', on='mve_data_mov')['mve_qtd_movimentada'].sum().reset_index()
    df_prophet = df_resampled.rename(columns={'mve_data_mov': 'ds', 'mve_qtd_movimentada': 'y'})
    df_prophet['ds'] = df_prophet['ds'].dt.tz_localize(None)

    hoje = pd.Timestamp.today().normalize()
    df_prophet = df_prophet[df_prophet['ds'] < hoje]
    
    return df_prophet

def _get_setor_backtest(df_full: pd.DataFrame, days_to_test: int = 20):
    
    MIN_TRAIN_DAYS = 3

    if len(df_full) < (days_to_test + MIN_TRAIN_DAYS):
        msg = f"Dados insuficientes. São necessários {days_to_test + MIN_TRAIN_DAYS} dias de histórico para uma análise de {days_to_test} dias. (Encontrados: {len(df_full)})"
        raise ConsumoException(msg)

    split_date = df_full['ds'].max() - pd.DateOffset(days=days_to_test - 1)
    
    train_df = df_full[df_full['ds'] < split_date]
    test_df = df_full[df_full['ds'] >= split_date]

    if len(train_df) < MIN_TRAIN_DAYS:
        raise ConsumoException(f"Dados de treino insuficientes após a divisão. (Mínimo: {MIN_TRAIN_DAYS})")

    print(f"[API-CONSUMO] Treinando modelo com {len(train_df)} dias de dados...")
    model = Prophet()
    model.fit(train_df)

    future = model.make_future_dataframe(periods=days_to_test)
    forecast = model.predict(future)
    
    print(f"[API-CONSUMO] Previsão de backtest concluída. Comparando {len(test_df)} dias reais.")

    predicted_data_raw = forecast[forecast['ds'] >= split_date]
    predicted_values = predicted_data_raw['yhat'].clip(lower=0).round().astype(int)

    real_values = test_df['y']

    return {
        "real_total": int(real_values.sum()),
        "previsto_total": int(predicted_values.sum())
    }

@router.get("/gerar-consumo-setor")
def gerar_consumo_setor_endpoint():
    print("\n[API] Recebida requisição para /gerar-consumo-setor")
    
    try:
        df_almox = _get_setor_data(setor_id=1)
        dados_almoxarifado = _get_setor_backtest(df_almox, days_to_test=20)
        
        df_farmacia = _get_setor_data(setor_id=2)
        dados_farmacia = _get_setor_backtest(df_farmacia, days_to_test=20)
        
        response_data = {
            "almoxarifado": dados_almoxarifado,
            "farmacia": dados_farmacia
        }
        
        return JSONResponse(status_code=200, content=jsonable_encoder(response_data))

    except ConsumoException as e:
        print(f"[API-CONSUMO-ERRO] Erro: {e}")
        return JSONResponse(status_code=400, content={"erro": str(e)})
    except Exception as e:
        print(f"[API-CONSUMO-ERRO-FATAL] Erro fatal: {e}")
        return JSONResponse(status_code=500, content={"erro": f"Erro interno do servidor: {e}"})
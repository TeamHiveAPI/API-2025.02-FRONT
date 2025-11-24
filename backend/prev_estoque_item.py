import pandas as pd
from prophet import Prophet
from supabase import create_client, Client
import os
from dotenv import load_dotenv
import pandas as pd
from fastapi import APIRouter
from fastapi.responses import JSONResponse

load_dotenv()
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("ERRO: Variáveis de ambiente Supabase não configuradas!")
    exit()

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class ConsumoException(Exception):
    pass

router = APIRouter()

@router.get("/gerar-previsao")
def gerar_previsao_endpoint(item_id: int):
    
    print(f"\n[API-ITEM] Recebida requisição para o item ID: {item_id}")

    try:
        response = supabase.table('mov_estoque') \
            .select('mve_data_mov', 'mve_qtd_movimentada') \
            .eq('mve_item_id', item_id) \
            .eq('mve_tipo', 'SAÍDA') \
            .execute()
        
        print(f"[API-ITEM-DEBUG] Dados recebidos do Supabase: {response.data}")
        
        if not response.data:
            print(f"[API-ITEM-AVISO] Sem dados para o item {item_id}.")
            return JSONResponse(status_code=404, content={"erro": "Este item não possui movimentações o suficiente para poder gerar uma previsão confiável."})
            
    except Exception as e:
        print(f"[API-ITEM-ERRO] Falha ao buscar dados: {e}")
        return JSONResponse(status_code=500, content={"erro": str(e)})

    print("[API-ITEM] Preparando dados...")
    df = pd.DataFrame(response.data)
    df['mve_data_mov'] = pd.to_datetime(df['mve_data_mov'], format='ISO8601')
    df_resampled = df.resample('D', on='mve_data_mov')['mve_qtd_movimentada'].sum().reset_index()
    df_prophet = df_resampled.rename(columns={'mve_data_mov': 'ds', 'mve_qtd_movimentada': 'y'})
    df_prophet['ds'] = df_prophet['ds'].dt.tz_localize(None)

    if len(df_prophet) < 3:
           return JSONResponse(status_code=400, content={"erro": "Este item não possui movimentações o suficiente para poder gerar uma previsão confiável."})

    print("[API-ITEM] Treinando modelo... Isso vai demorar.")
    model = Prophet()
    model.fit(df_prophet)

    last_historical_date = df_prophet['ds'].max()
    hoje = pd.Timestamp.today().normalize()
    
    if last_historical_date > hoje:
        last_historical_date = hoje

    dias_de_gap = (hoje - last_historical_date).days
    
    dias_para_prever_total = 30 + dias_de_gap

    print(f"[API-ITEM-DEBUG] Último dado: {last_historical_date.date()}. Dias de gap: {dias_de_gap}. Prevendo {dias_para_prever_total} dias.")
    
    future = model.make_future_dataframe(periods=dias_para_prever_total)
    
    forecast = model.predict(future)
    
    print("[API-ITEM] Previsão concluída. Retornando JSON.")

    hoje_meia_noite = pd.Timestamp.today().normalize()
    dados_apenas_futuros = forecast[forecast['ds'] > hoje_meia_noite].copy()

    dados_apenas_futuros = dados_apenas_futuros.head(30)

    dados_apenas_futuros['yhat'] = dados_apenas_futuros['yhat'].clip(lower=0)
    dados_apenas_futuros['yhat_lower'] = dados_apenas_futuros['yhat_lower'].clip(lower=0)
    dados_apenas_futuros['yhat_upper'] = dados_apenas_futuros['yhat_upper'].clip(lower=0)

    dados_apenas_futuros['yhat'] = dados_apenas_futuros['yhat'].round().astype(int)
    dados_apenas_futuros['yhat_lower'] = dados_apenas_futuros['yhat_lower'].round().astype(int)
    dados_apenas_futuros['yhat_upper'] = dados_apenas_futuros['yhat_upper'].round().astype(int)

    dados_apenas_futuros['ds'] = dados_apenas_futuros['ds'].apply(lambda x: x.isoformat())
    
    dados_retorno = dados_apenas_futuros[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].to_dict('records')
    
    return {"previsao": dados_retorno}
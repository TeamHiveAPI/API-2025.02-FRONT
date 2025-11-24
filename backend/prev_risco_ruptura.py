import pandas as pd
from prophet import Prophet
from supabase import create_client, Client
import os
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

load_dotenv()
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("ERRO: Variáveis de ambiente Supabase não configuradas!")
    exit()

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

router = APIRouter()

class RiscoException(Exception):
    pass

def _calcular_risco_item(df_history, estoque_atual, item_nome):
    if len(df_history) < 5:
        return {
            "nivel": "DESCONHECIDO",
            "cor": "grey",
            "msg": "Dados insuficientes"
        }

    m = Prophet(daily_seasonality=False, yearly_seasonality=False)
    m.fit(df_history)
    
    future = m.make_future_dataframe(periods=7)
    forecast = m.predict(future)
    
    forecast_future = forecast.tail(7)
    
    consumo_previsto_medio = forecast_future['yhat'].sum()
    consumo_previsto_pessimista = forecast_future['yhat_upper'].sum()

    if consumo_previsto_pessimista < 0: consumo_previsto_pessimista = 0
    if consumo_previsto_medio < 0: consumo_previsto_medio = 0

    if estoque_atual < consumo_previsto_medio:
        return {
            "nivel": "CRÍTICO",
            "cor": "red",
            "probabilidade": 95,
            "previsao_7d": int(consumo_previsto_medio)
        }
    
    elif estoque_atual < consumo_previsto_pessimista:
        return {
            "nivel": "ALTO",
            "cor": "orange",
            "probabilidade": 70,
            "previsao_7d": int(consumo_previsto_medio)
        }

    elif estoque_atual < (consumo_previsto_medio * 2):
        return {
            "nivel": "MÉDIO",
            "cor": "yellow",
            "probabilidade": 40,
            "previsao_7d": int(consumo_previsto_medio)
        }
    else:
        return {
            "nivel": "BAIXO",
            "cor": "green",
            "probabilidade": 10,
            "previsao_7d": int(consumo_previsto_medio)
        }

def _get_itens_risco(setor_id: int):
    print(f"\n[API-RISCO] --- INICIANDO ANÁLISE PARA SETOR {setor_id} ---")

    resp_itens = supabase.table('item') \
        .select('id, it_nome, grupo!inner(grp_setor_id)') \
        .eq('grupo.grp_setor_id', setor_id) \
        .execute()
    
    itens = resp_itens.data
    if not itens:
        print("[API-RISCO] Nenhum item encontrado no cadastro deste setor.")
        raise RiscoException("Nenhum item encontrado neste setor.")

    lista_analise = []
    print(f"[API-RISCO] Total de itens no cadastro: {len(itens)}")
    
    for item in itens:
        if len(lista_analise) >= 10:
            print("[API-RISCO] Limite de 10 itens atingido. Parando.")
            break

        item_id = item['id']
        item_nome = item['it_nome']
        
        print(f"\n[API-RISCO] >> Verificando Item: {item_nome} (ID: {item_id})")
        
        resp_estoque = supabase.table('lote') \
            .select('lot_qtd_atual') \
            .eq('lot_item_id', item_id) \
            .eq('lot_ativo', True) \
            .execute()
        
        estoque_total = sum([l['lot_qtd_atual'] for l in resp_estoque.data])

        resp_mov = supabase.table('mov_estoque') \
            .select('mve_data_mov, mve_qtd_movimentada') \
            .eq('mve_item_id', item_id) \
            .eq('mve_tipo', 'SAÍDA') \
            .order('mve_data_mov', desc=True) \
            .limit(90) \
            .execute()

        qtd_movimentacoes = len(resp_mov.data) if resp_mov.data else 0
        print(f"    -> Movimentações encontradas: {qtd_movimentacoes}")

        if qtd_movimentacoes < 5:
            print(f"    -> [PULANDO] Histórico insuficiente (Mínimo 5, tem {qtd_movimentacoes}).")
            continue 
        
        print(f"    -> [PROCESSANDO] Dados suficientes. Rodando Prophet...")

        df = pd.DataFrame(resp_mov.data)
        df['ds'] = pd.to_datetime(df['mve_data_mov'], format='ISO8601').dt.tz_localize(None)
        df['y'] = df['mve_qtd_movimentada']
        
        df = df.groupby('ds')['y'].sum().reset_index()

        try:
            analise = _calcular_risco_item(df, estoque_total, item_nome)
            
            lista_analise.append({
                "id": item_id,
                "nome": item_nome,
                "estoque_atual": estoque_total,
                "consumo_previsto_7d": analise.get("previsao_7d", 0),
                "nivel_risco": analise["nivel"],
                "cor": analise["cor"],
                "probabilidade_ruptura": analise.get("probabilidade", 0)
            })
            print(f"    -> [SUCESSO] Item adicionado. Risco: {analise['nivel']}")
            
        except Exception as e:
            print(f"    -> [ERRO PROPHET] Falha ao calcular: {e}")

    lista_analise.sort(key=lambda x: x['probabilidade_ruptura'], reverse=True)
    
    print(f"\n[API-RISCO] --- FIM DA ANÁLISE. Retornando {len(lista_analise)} itens. ---")
    return lista_analise

@router.get("/gerar-risco-ruptura")
def gerar_risco_ruptura_endpoint(setor_id: int):
    try:
        dados_risco = _get_itens_risco(setor_id)
        return JSONResponse(status_code=200, content=jsonable_encoder({"itens": dados_risco}))
    
    except RiscoException as e:
        return JSONResponse(status_code=400, content={"erro": str(e)})
    except Exception as e:
        print(f"[API-RISCO] {e}")
        return JSONResponse(status_code=500, content={"erro": str(e)})
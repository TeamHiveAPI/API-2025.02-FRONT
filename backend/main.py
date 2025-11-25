import os
from dotenv import load_dotenv
import uvicorn
from fastapi import FastAPI

from prev_consumo_setor import router as consumo_setor_router
from prev_estoque_item import router as previsao_item_router
from prev_risco_ruptura import router as risco_ruptura_router

load_dotenv()
app = FastAPI()

app.include_router(consumo_setor_router, tags=["Consumo Setor"])
app.include_router(previsao_item_router, tags=["Previsão Item"])
app.include_router(risco_ruptura_router, tags=["Risco Ruptura"])

if __name__ == "__main__":
    print("Servidor Iniciado!")
    print(f"Ouvindo em http://0.0.0.0:8000")
    print("Aguardando requisições do Flutter...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
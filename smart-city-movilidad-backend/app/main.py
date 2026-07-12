from datetime import datetime

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from .database import engine
from .routers import kpis, sla

app = FastAPI(
    title="API Smart City Movilidad",
    description="Backend de solo lectura sobre la BD 'paraderos' (Smart_city_movilidad.sql). Calcula KPIs y el semáforo SLA.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(kpis.router)
app.include_router(sla.router)


@app.get("/", tags=["Root"])
def root():
    return {"mensaje": "API Smart City Movilidad activa", "documentacion": "/docs"}


@app.get("/api/health", tags=["Root"])
def health():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        db_ok = False
    return {"status": "ok" if db_ok else "db_error", "db_conectada": db_ok, "timestamp": datetime.now().isoformat()}

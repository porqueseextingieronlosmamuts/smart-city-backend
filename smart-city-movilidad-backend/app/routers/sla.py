"""
Endpoint /api/sla, adaptado al esquema de Smart_city_movilidad.sql.

Diferencias importantes respecto al diseño anterior (documentadas también
en el README):
  - Freshness se calcula desde log_etl.fecha_ejecucion, porque
    fact_movilidad no tiene columna de fecha de carga.
  - Unicidad se calcula como % de filas de fact_movilidad que NO son un
    duplicado exacto (mismo paradero+recorrido+tiempo+medidas). No hay
    una tabla agregada en este esquema, así que esta es la mejor
    aproximación disponible sin agregar tablas nuevas.
  - Pipeline NO se puede calcular: log_etl solo guarda fecha_ejecucion,
    no un inicio y un fin. Por eso esta dimensión siempre da "rojo" con
    valor nulo. Ver README para la columna opcional que se puede agregar.
"""
from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.engine import Connection

from ..config import settings
from ..database import get_connection
from ..utils.sla_utils import estado_general, estado_semaforo

router = APIRouter(prefix="/api", tags=["SLA"])


@router.get("/sla")
def get_sla(conn: Connection = Depends(get_connection)):
    # 1) Completitud
    fila = conn.execute(text("""
        SELECT
            ROUND(SUM(CASE WHEN tiempo_prometido IS NOT NULL
                             AND tiempo_real IS NOT NULL
                             AND pasajeros IS NOT NULL
                            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct
        FROM fact_movilidad
    """)).mappings().first()
    pct_completitud = float(fila["pct"]) if fila and fila["pct"] is not None else 0.0

    # 2) Freshness (desde log_etl, fact_movilidad no tiene fecha de carga propia)
    fila = conn.execute(text("SELECT MAX(fecha_ejecucion) AS ultima FROM log_etl")).mappings().first()
    if fila and fila["ultima"] is not None:
        dias_freshness = (datetime.now() - fila["ultima"]).days
    else:
        dias_freshness = 999

    # 3) Unicidad: % de filas que no son duplicado exacto de otra
    fila = conn.execute(text("""
        SELECT ROUND(
            COUNT(DISTINCT CONCAT_WS('|', id_paradero, id_recorrido, id_tiempo,
                                      tiempo_prometido, tiempo_real, pasajeros,
                                      sat_espera, sat_puntualidad, sat_servicio, desviacion))
            * 100.0 / COUNT(*), 2) AS pct
        FROM fact_movilidad
    """)).mappings().first()
    pct_unicidad = float(fila["pct"]) if fila and fila["pct"] is not None else 100.0

    # 4) Pipeline: no calculable con el esquema actual (log_etl no guarda duración)
    duracion_pipeline = None

    # 5) Uptime: % de corridas del ETL con estado 'exitoso'
    fila = conn.execute(text("""
        SELECT ROUND(
            SUM(CASE WHEN LOWER(TRIM(estado)) IN ('exitoso', 'ok', 'success', 'successful') THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*),
            2
        ) AS pct
        FROM log_etl
    """)).mappings().first()
    pct_uptime = float(fila["pct"]) if fila and fila["pct"] is not None else 100.0

    estado_completitud = estado_semaforo(pct_completitud, settings.sla_completitud_verde, settings.sla_completitud_amarillo, True)
    estado_freshness = estado_semaforo(dias_freshness, settings.sla_freshness_verde_dias, settings.sla_freshness_amarillo_dias, False)
    estado_unicidad = estado_semaforo(pct_unicidad, settings.sla_unicidad_verde, settings.sla_unicidad_amarillo, True)
    estado_pipeline = estado_semaforo(duracion_pipeline, settings.sla_pipeline_verde_seg, settings.sla_pipeline_amarillo_seg, False) if duracion_pipeline is not None else "sin_datos"
    estado_uptime = estado_semaforo(pct_uptime, settings.sla_uptime_verde, settings.sla_uptime_amarillo, True)

    # Si pipeline no se puede medir con el esquema actual, no debe arrastrar
    # el estado global a rojo por falta de datos.
    estados_para_general = [estado_completitud, estado_freshness, estado_unicidad, estado_uptime]
    if duracion_pipeline is not None:
        estados_para_general.append(estado_pipeline)

    return {
        "completitud": {
            "valor": pct_completitud, "unidad": "%", "estado": estado_completitud,
            "umbral": f">={settings.sla_completitud_verde}% verde, >={settings.sla_completitud_amarillo}% amarillo",
        },
        "freshness": {
            "valor": dias_freshness, "unidad": "dias", "estado": estado_freshness,
            "umbral": f"<={settings.sla_freshness_verde_dias}d verde, <={settings.sla_freshness_amarillo_dias}d amarillo",
        },
        "unicidad": {
            "valor": pct_unicidad, "unidad": "%", "estado": estado_unicidad,
            "umbral": f"={settings.sla_unicidad_verde}% verde, >={settings.sla_unicidad_amarillo}% amarillo",
        },
        "pipeline": {
            "valor": duracion_pipeline, "unidad": "segundos", "estado": estado_pipeline,
            "umbral": f"<={settings.sla_pipeline_verde_seg}s verde, <={settings.sla_pipeline_amarillo_seg}s amarillo",
            "nota": "log_etl no registra duración (falta fecha_inicio o duracion_seg); agrega esa columna para medir esto de verdad.",
        },
        "uptime": {
            "valor": pct_uptime, "unidad": "%", "estado": estado_uptime,
            "umbral": f">={settings.sla_uptime_verde}% verde, >={settings.sla_uptime_amarillo}% amarillo",
        },
        "estado_general": estado_general(*estados_para_general),
        "timestamp": datetime.now().isoformat(),
    }

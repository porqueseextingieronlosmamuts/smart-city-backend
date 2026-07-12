"""
KPIs clave del proyecto, adaptados al esquema de Smart_city_movilidad.sql:
paradero(id_paradero, nombre) — recorrido(id_recorrido, codigo) —
tiempo(id_tiempo, fecha, franja) — fact_movilidad(...).

Nota: el índice de puntualidad se calcula aquí directo desde `desviacion`
(|desviacion| <= 5), NO desde la columna `puntual` ya guardada en
fact_movilidad -- esa columna se calculó en el script de carga como
`desviacion <= 0`, que es una definición distinta (llegó a tiempo o antes)
a la que pide el proyecto (desviación absoluta <= 5 min).
"""
from typing import Any, Dict, List

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.engine import Connection

from ..database import get_connection

router = APIRouter(prefix="/api/kpis", tags=["KPIs"])


def _filas(conn: Connection, sql: str) -> List[Dict[str, Any]]:
    return [dict(r) for r in conn.execute(text(sql)).mappings().all()]


@router.get("/puntualidad")
def puntualidad_por_parada(conn: Connection = Depends(get_connection)):
    """Índice de puntualidad = viajes con |desviación| <= 5 min / total x 100."""
    return _filas(conn, """
        SELECT
            p.nombre AS paradero,
            COUNT(*) AS total_viajes,
            SUM(CASE WHEN ABS(f.desviacion) <= 5 THEN 1 ELSE 0 END) AS viajes_puntuales,
            ROUND(SUM(CASE WHEN ABS(f.desviacion) <= 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS indice_puntualidad_pct
        FROM fact_movilidad f
        JOIN paradero p ON p.id_paradero = f.id_paradero
        WHERE f.desviacion IS NOT NULL
        GROUP BY p.id_paradero, p.nombre
        ORDER BY indice_puntualidad_pct DESC
    """)


@router.get("/tiempo-espera")
def tiempo_espera_real_vs_prometido(conn: Connection = Depends(get_connection)):
    """Tiempo de espera real vs prometido, por paradero y franja horaria."""
    return _filas(conn, """
        SELECT
            p.nombre AS paradero,
            t.franja AS franja_horaria,
            ROUND(AVG(f.tiempo_real), 2)                      AS tiempo_real_promedio_min,
            ROUND(AVG(f.tiempo_prometido), 2)                 AS tiempo_prometido_promedio_min,
            ROUND(AVG(f.tiempo_real) - AVG(f.tiempo_prometido), 2) AS desviacion_promedio_min,
            COUNT(*) AS n_observaciones
        FROM fact_movilidad f
        JOIN paradero p ON p.id_paradero = f.id_paradero
        JOIN tiempo t   ON t.id_tiempo = f.id_tiempo
        WHERE f.tiempo_real IS NOT NULL
        GROUP BY p.id_paradero, p.nombre, t.franja
        ORDER BY p.nombre, t.franja
    """)


@router.get("/pasajeros")
def pasajeros_por_franja(conn: Connection = Depends(get_connection)):
    """N° de pasajeros por franja horaria."""
    return _filas(conn, """
        SELECT
            t.franja AS franja_horaria,
            SUM(f.pasajeros)           AS total_pasajeros,
            ROUND(AVG(f.pasajeros), 2) AS promedio_pasajeros_por_respuesta,
            COUNT(*)                    AS n_respuestas
        FROM fact_movilidad f
        JOIN tiempo t ON t.id_tiempo = f.id_tiempo
        WHERE f.pasajeros IS NOT NULL
        GROUP BY t.franja
        ORDER BY t.franja
    """)


@router.get("/satisfaccion")
def satisfaccion_promedio(conn: Connection = Depends(get_connection)):
    """Satisfacción promedio por paradero (espera, puntualidad, servicio)."""
    return _filas(conn, """
        SELECT
            p.nombre AS paradero,
            ROUND(AVG(f.sat_espera), 2)      AS promedio_espera,
            ROUND(AVG(f.sat_puntualidad), 2)  AS promedio_puntualidad,
            ROUND(AVG(f.sat_servicio), 2)      AS promedio_servicio,
            ROUND((AVG(f.sat_espera) + AVG(f.sat_puntualidad) + AVG(f.sat_servicio)) / 3, 2) AS promedio_general,
            COUNT(*) AS n_encuestas
        FROM fact_movilidad f
        JOIN paradero p ON p.id_paradero = f.id_paradero
        GROUP BY p.id_paradero, p.nombre
    """)


@router.get("/top-desviacion")
def top_paradas_mayor_desviacion(conn: Connection = Depends(get_connection), limite: int = 3):
    """Top N paraderos con mayor desviación promedio absoluta."""
    filas = _filas(conn, """
        SELECT
            p.nombre AS paradero,
            ROUND(AVG(ABS(f.desviacion)), 2) AS desviacion_promedio_abs_min,
            COUNT(*) AS n_observaciones
        FROM fact_movilidad f
        JOIN paradero p ON p.id_paradero = f.id_paradero
        WHERE f.desviacion IS NOT NULL
        GROUP BY p.id_paradero, p.nombre
        ORDER BY desviacion_promedio_abs_min DESC
    """)
    return filas[:limite]


@router.get("/resumen")
def resumen_kpis(conn: Connection = Depends(get_connection)) -> Dict[str, Any]:
    """Todos los KPIs juntos, útil para un dashboard."""
    return {
        "puntualidad_por_parada": puntualidad_por_parada(conn),
        "tiempo_espera_real_vs_prometido": tiempo_espera_real_vs_prometido(conn),
        "pasajeros_por_franja": pasajeros_por_franja(conn),
        "satisfaccion_promedio": satisfaccion_promedio(conn),
        "top_3_paradas_mayor_desviacion": top_paradas_mayor_desviacion(conn, limite=3),
    }

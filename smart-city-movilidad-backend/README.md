# API Smart City Movilidad — backend simple

Backend **de solo lectura** en FastAPI sobre la base de datos que definiste
en `Smart_city_movilidad.sql` (esquema `paradero` / `recorrido` / `tiempo` /
`fact_movilidad` / `log_etl`). Sin ORM, sin endpoints de escritura — solo
lee y calcula los 5 KPIs y el semáforo SLA.

## ⚠️ 2 cosas de tu esquema que debes saber (no las modifiqué)

### 1. Bug de mayúscula/minúscula en el nombre de la base
Tu script tiene:
```sql
create database Paraderos;
use paraderos;
```
En Windows/Mac esto normalmente no falla (no distinguen mayúsculas en
nombres de BD), pero en **Linux sí falla** (`ERROR 1049: Unknown database
'paraderos'`) — lo comprobé al probar este backend. Si vas a correr tu
script en un servidor Linux (por ejemplo, si tu MySQL termina alojado en
algo como Render, Railway, db4free, etc.), cambia una de las dos líneas
para que ambas usen exactamente el mismo casing, ej.:
```sql
create database paraderos;
use paraderos;
```

### 2. La columna `puntual` no usa la misma regla que el KPI de puntualidad
En tu INSERT a `fact_movilidad`:
```sql
CASE WHEN s.desviacion <= 0 THEN TRUE ELSE FALSE END
```
Eso marca `puntual = TRUE` cuando el bus llegó a tiempo o antes. Pero el
KPI de "índice de puntualidad" del proyecto se define como **desviación
absoluta ≤ 5 minutos** (o sea, también cuenta como puntual si se atrasó
hasta 5 min). Por eso, **este backend no usa la columna `puntual`** —
calcula el índice directo desde `desviacion` en cada consulta. Puedes
dejar la columna `puntual` como está (no estorba), pero si la vas a usar
para algo más, ten en cuenta que no representa lo mismo.

## Estructura

```
smart-city-movilidad-backend/
├── requirements.txt
├── .env.example
├── app/
│   ├── config.py           # conexión + umbrales SLA
│   ├── database.py          # motor SQLAlchemy, sin ORM
│   ├── utils/sla_utils.py    # semáforo verde/amarillo/rojo
│   ├── routers/
│   │   ├── kpis.py             # los 5 KPIs
│   │   └── sla.py               # /api/sla
│   └── main.py                 # arma la app
└── sql/
    ├── 01_smart_city_movilidad.sql   # tu script, sin cambios
    └── 02_datos_demo.sql              # datos de prueba (staging + carga + log)
```

## Instalación

```bash
cd smart-city-movilidad-backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # ajusta DATABASE_URL a tu MySQL
uvicorn app.main:app --reload
```

`http://127.0.0.1:8000/docs` para probar todo.

## El otro caso: frontend y backend en distinto origen

Si el dashboard se sirve desde un host o puerto distinto al backend, entonces no debes usar rutas relativas desde el frontend. En `dashboard-smart-city/app.js` cambia:

```js
const API_BASE = '';
```

a:

```js
const API_BASE = 'http://127.0.0.1:8000';
```

De esta forma las llamadas quedarán como `fetch(API_BASE + '/api/sla')` y el navegador apuntará al backend correcto.

Tu backend ya permite CORS desde cualquier origen (`allow_origins=["*"]`), por lo que no hace falta cambiar nada allí para este caso.

## Endpoints

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/kpis/puntualidad` | Índice de puntualidad por paradero (recalculado desde `desviacion`) |
| GET | `/api/kpis/tiempo-espera` | Tiempo real vs prometido, por paradero y franja |
| GET | `/api/kpis/pasajeros` | N° de pasajeros por franja horaria |
| GET | `/api/kpis/satisfaccion` | Promedio de sat_espera/puntualidad/servicio por paradero |
| GET | `/api/kpis/top-desviacion` | Top 3 paraderos con mayor desviación |
| GET | `/api/kpis/resumen` | Todos juntos |
| **GET** | **`/api/sla`** | **Semáforo SLA** |
| GET | `/api/health` | Ping + verifica conexión a MySQL |

## Cómo se calcula el SLA en este esquema (importante, cambia respecto a antes)

| Dimensión | Cómo se calcula aquí | Nota |
|---|---|---|
| Completitud | % de `fact_movilidad` con `tiempo_prometido`, `tiempo_real`, `pasajeros` no nulos | igual que antes |
| Freshness | días desde `MAX(log_etl.fecha_ejecucion)` | **cambio**: antes se leía de la tabla de hechos; aquí `fact_movilidad` no tiene fecha de carga propia, así que se usa el log del ETL |
| Unicidad | % de filas de `fact_movilidad` que no son un duplicado exacto (mismo paradero+recorrido+tiempo+medidas) | **cambio**: antes se validaba sobre una tabla agregada; este esquema no tiene una, así que se detectan duplicados exactos en la tabla de hechos directamente |
| Pipeline | **no calculable** — siempre `null` / rojo | `log_etl` solo tiene `fecha_ejecucion` (un timestamp), no `fecha_inicio` + `fecha_fin`. Sin eso no hay duración que medir |
| Uptime | % de filas en `log_etl` con `estado='exitoso'` | igual que antes |

### Si quieres que "Pipeline" funcione de verdad

Agrega una columna a `log_etl` (no rompe nada de lo que ya tienes):
```sql
ALTER TABLE log_etl ADD COLUMN duracion_seg DECIMAL(10,2) NULL;
```
Y que tu proceso de carga la llene al terminar (fin - inicio, en segundos).
Avísame cuando la agregues y actualizo el endpoint para que la lea.

## Cargar tus datos reales

1. Corre `sql/01_smart_city_movilidad.sql` (con el fix de mayúscula si tu MySQL es Linux) para crear el esquema.
2. Carga tu Excel real en `staging_movilidad` (por ejemplo, importando el CSV/Excel directo con el asistente de importación de tabla de MySQL Workbench, o adaptando el parser de Python que ya usamos en el otro proyecto).
3. Corre los `INSERT INTO paradero/recorrido/tiempo/fact_movilidad` que ya vienen al final de `01_smart_city_movilidad.sql`.
4. Inserta una fila en `log_etl` con el resultado de esa carga.

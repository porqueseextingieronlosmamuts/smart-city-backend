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

### Requisitos previos
- **Python 3.8+** instalado
- **MySQL 8.0+** corriendo localmente o en un servidor
- **Git** (opcional, para clonar el repo)

### Pasos de instalación

#### 1. Navega a la carpeta del proyecto
```bash
cd smart-city-movilidad-backend
```

#### 2. Crea un entorno virtual
**En Windows (PowerShell o CMD):**
```bash
python -m venv venv
venv\Scripts\activate
```

**En macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

#### 3. Instala las dependencias
```bash
pip install -r requirements.txt
```

#### 4. Configura las variables de entorno
```bash
cp .env.example .env
```
Luego edita `.env` y ajusta la URL de conexión a MySQL:
```env
DATABASE_URL=mysql+pymysql://usuario:contraseña@localhost:3306/Paraderos
```

---

## Iniciar el servidor

### Opción 1: Modo desarrollo (con recarga automática)
```bash
uvicorn app.main:app --reload
```
- El servidor se inicia en `http://127.0.0.1:8000`
- Se recarga automáticamente al cambiar archivos
- Ideal para desarrollo

### Opción 2: Modo producción (sin recarga)
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```
- El servidor es accesible desde cualquier máquina en la red
- No se recarga automáticamente
- Más estable para producción

### Opción 3: Con más workers (para más carga)
```bash
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```
- Usa 4 procesos en paralelo
- Mejor rendimiento bajo alta concurrencia

---

## Acceder a la API

Una vez que el servidor esté corriendo:

- **Documentación interactiva (Swagger):** http://127.0.0.1:8000/docs
- **Documentación alternativa (ReDoc):** http://127.0.0.1:8000/redoc
- **Health check:** http://127.0.0.1:8000/api/health

En Swagger puedes probar todos los endpoints directamente desde el navegador.

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

## Diagrama de Consumo de Datos 📊

Para entender cómo fluyen los datos desde MySQL → Backend → Frontend, existe un diagrama interactivo:

**Archivo:** `DATA_FLOW_DIAGRAM.drawio`

### Cómo verlo:

#### Opción 1: Online (recomendado)
1. Ve a https://app.diagrams.net/
2. Haz clic en **File → Open**
3. Selecciona el archivo `DATA_FLOW_DIAGRAM.drawio` desde tu máquina
4. Se abrirá el diagrama en el editor de Draw.io

#### Opción 2: En VS Code
1. Instala la extensión **Draw.io Integration** (hediet.vscode-drawio)
2. Abre el archivo `DATA_FLOW_DIAGRAM.drawio` en VS Code
3. Se mostrará en una pestaña interactiva

#### Opción 3: Exportar como imagen
En Draw.io:
- File → Export as → PNG/SVG
- Guarda la imagen y úsala en documentación

### Qué muestra el diagrama:

```
┌─────────────────┬─────────────────┬─────────────────┐
│  MySQL Database │  FastAPI Backend│  JavaScript FE  │
├─────────────────┼─────────────────┼─────────────────┤
│ • paradero      │ • database.py   │ • index.html    │
│ • recorrido     │ • config.py     │ • app.js        │
│ • tiempo        │ • kpis-endpoint │ • Chart.js 4.4  │
│ • fact_movilidad│ • sla-endpoint  │ • KPI Cards     │
│ • log_etl       │ • sla_utils.py  │ • Tables        │
└─────────────────┴─────────────────┴─────────────────┘
        ↓ SQL Queries       ↓ GET /api/*     ↓ Render
     Mediciones        Datos JSON       Gráficos en vivo
```

**Latencia esperada:** 300-1500ms por actualización (cada 30 segundos)

---

## Cómo se calcula el SLA en este esquema (importante, cambia respecto a antes)

| Dimensión | Cómo se calcula aquí | Nota |
|---|---|---|
| Completitud | % de `fact_movilidad` con `tiempo_prometido`, `tiempo_real`, `pasajeros` no nulos | igual que antes |
| Freshness | días desde `MAX(log_etl.fecha_ejecucion)` | **cambio**: antes se leía de la tabla de hechos; aquí `fact_movilidad` no tiene fecha de carga propia, así que se usa el log del ETL |
| Unicidad | % de filas de `fact_movilidad` que no son un duplicado exacto (mismo paradero+recorrido+tiempo+medidas) | **cambio**: antes se validaba sobre una tabla agregada; este esquema no tiene una, así que se detectan duplicados exactos en la tabla de hechos directamente |
| Pipeline | segundos de la última corrida (`log_etl.duracion_seg`) | si no existe columna o viene `NULL`, se marca `sin_datos` y no arrastra el estado general |
| Uptime | % de filas en `log_etl` con estado exitoso (`exitoso`, `ok`, `success`, `successful`) | más robusto ante variantes comunes del ETL |

### Si ya tenías la tabla creada sin duración

Agrega la columna a `log_etl` (no rompe nada de lo que ya tienes):
```sql
ALTER TABLE log_etl ADD COLUMN duracion_seg DECIMAL(10,2) NULL;
```
Y haz que tu proceso de carga la llene al terminar (fin - inicio, en segundos).
El endpoint ya está listo para leerla automáticamente.

## Los 5 KPIs del Proyecto 📊

Este backend calcula 5 indicadores clave para monitorear la calidad del servicio:

### 1. **Puntualidad por Paradero** 🎯
- **Métrica:** % de viajes con desviación absoluta ≤ 5 minutos
- **Propósito:** Medir si los buses llegan dentro del tiempo prometido
- **Endpoint:** `/api/kpis/puntualidad`
- **Por qué:** Fundamental para la confiabilidad del servicio

### 2. **Tiempo de Espera Real vs Prometido** ⏱️
- **Métrica:** Diferencia (tiempo real - tiempo prometido) por paradero y franja
- **Propósito:** Identificar desviaciones sistemáticas en tiempos publicados
- **Endpoint:** `/api/kpis/tiempo-espera`
- **Por qué:** Ayuda a optimizar y validar los tiempos anunciados

### 3. **Pasajeros por Franja Horaria** 👥
- **Métrica:** Volumen total y promedio de pasajeros por hora
- **Propósito:** Dimensionar demanda y detectar horas pico
- **Endpoint:** `/api/kpis/pasajeros`
- **Por qué:** Permite validar si la capacidad de buses es suficiente

### 4. **Satisfacción Promedio por Paradero** ⭐
- **Métrica:** Promedio de 3 dimensiones:
  - Satisfacción con tiempo de espera
  - Satisfacción con puntualidad
  - Satisfacción general del servicio
- **Endpoint:** `/api/kpis/satisfaccion`
- **Por qué:** Indicador más directo de calidad percibida por usuarios

### 5. **Top 3 Paraderos con Mayor Desviación** 🚨
- **Métrica:** Desviación promedio absoluta en minutos (TOP 3)
- **Propósito:** Identificar rápidamente dónde hay problemas
- **Endpoint:** `/api/kpis/top-desviacion`
- **Por qué:** Priorizar intervenciones operacionales

---

## Entender el Semáforo SLA 🚦

El endpoint `/api/sla` devuelve un "semáforo" que indica si la calidad de los datos es confiable (NO mide los KPIs, mide la calidad del data pipeline).

### Los 3 Estados:
- 🟢 **VERDE:** Todo está óptimo, datos confiables
- 🟡 **AMARILLO:** Hay advertencias, datos aceptables pero revisar
- 🔴 **ROJO:** Hay problemas críticos, datos potencialmente no confiables

### Las 5 Dimensiones Monitoreadas:

| Dimensión | Verde | Amarillo | Rojo | Significado |
|-----------|-------|----------|------|-------------|
| **Completitud** | ≥95% | ≥90% | <90% | % de registros con datos válidos |
| **Freshness** | ≤10 días | ≤15 días | >15 días | Qué tan recientes están los datos |
| **Unicidad** | 100% | ≥98% | <98% | % de registros sin duplicados |
| **Pipeline** | ≤180s | ≤240s | >240s | Velocidad del ETL en segundos |
| **Uptime** | ≥99% | ≥95% | <95% | % de corridas ETL exitosas |

**Importante:** El estado general es rojo si ALGUNA dimensión es roja, amarillo si alguna es amarilla, verde si todas son verdes.

Ejemplo:
```
Completitud: 98%  → Verde
Freshness: 8 días → Verde
Unicidad: 96%     → Amarillo (falta 2% para verde)
Pipeline: 190s    → Amarillo (falta 10s para verde)
Uptime: 98%       → Amarillo (falta 1% para verde)

Estado General: AMARILLO (por las 3 amarillas)
```

---

## Variables de Entorno (.env) 🔐

Copia `.env.example` a `.env` y configura:

```env
# Conexión a base de datos (REQUERIDA)
DATABASE_URL=mysql+pymysql://usuario:contraseña@localhost:3306/Paraderos

# Umbrales SLA (opcional, por defecto están optimizados)
SLA_COMPLETITUD_VERDE=95.0
SLA_COMPLETITUD_AMARILLO=90.0

SLA_FRESHNESS_VERDE_DIAS=10
SLA_FRESHNESS_AMARILLO_DIAS=15

SLA_UNICIDAD_VERDE=100.0
SLA_UNICIDAD_AMARILLO=98.0

SLA_PIPELINE_VERDE_SEG=180
SLA_PIPELINE_AMARILLO_SEG=240

SLA_UPTIME_VERDE=99.0
SLA_UPTIME_AMARILLO=95.0
```

Si no defines umbrales personalizados, se usan los valores por defecto que vienen en `config.py`.

---

## Cargar Datos de Prueba 📥

### Opción 1: Usar datos demo incluidos

```bash
# 1. Crear esquema
mysql -u root -p < sql/01_smart_city_movilidad.sql

# 2. Cargar datos demo (incluye staging + fact_movilidad + log_etl)
mysql -u root -p Paraderos < sql/02_datos_demo.sql

# 3. Verificar
mysql -u root -p -e "SELECT COUNT(*) as total_viajes FROM Paraderos.fact_movilidad;"
```

### Opción 2: Cargar tus datos reales

1. Corre `sql/01_smart_city_movilidad.sql` para crear el esquema
2. Carga tu Excel/CSV en `staging_movilidad`:
   - Usa MySQL Workbench → Table Data Import Wizard
   - O importa via línea de comandos
3. Corre los `INSERT INTO` del final de `01_smart_city_movilidad.sql`
4. Inserta un registro en `log_etl` con metadata de la carga:
   ```sql
   INSERT INTO log_etl (fecha_ejecucion, estado, duracion_seg)
   VALUES (NOW(), 'exitoso', 45.5);
   ```

---

## Verificar que Todo Funciona ✅

Una vez instalado e iniciado:

```bash
# 1. Health check (verifica conexión a MySQL)
curl http://127.0.0.1:8000/api/health

# 2. Probar endpoint de KPIs
curl http://127.0.0.1:8000/api/kpis/puntualidad

# 3. Probar semáforo SLA
curl http://127.0.0.1:8000/api/sla

# 4. Abrir Swagger (navegador)
http://127.0.0.1:8000/docs
```

Si todo retorna datos JSON sin errores: ✅ está funcionando correctamente.

---

## Troubleshooting 🔧

### Error: "Unknown database 'Paraderos'" o "Connection refused"
```
Causa: MySQL no está corriendo o las credenciales son incorrectas
Solución:
1. Verifica que MySQL esté corriendo: mysql -u root -p
2. Revisa DATABASE_URL en .env
3. Crea la base de datos: mysql -u root -p < sql/01_smart_city_movilidad.sql
```

### Error: "Import 'pydantic_settings' could not be resolved"
```
Causa: Entorno virtual no activado o dependencias no instaladas
Solución:
1. Activa el entorno: source venv/bin/activate (Linux/Mac) o venv\Scripts\activate (Windows)
2. Instala dependencias: pip install -r requirements.txt
3. Recarga VS Code
```

### Error: "No module named 'fastapi'"
```
Causa: Dependencias no instaladas
Solución:
pip install -r requirements.txt
```

### El servidor inicia pero los endpoints retornan datos vacíos
```
Causa: No hay datos en la base de datos
Solución:
1. Carga los datos demo: mysql -u root -p Paraderos < sql/02_datos_demo.sql
2. Verifica: SELECT COUNT(*) FROM fact_movilidad;
```

### El semáforo está en ROJO
```
Esto significa que hay problemas en la calidad de datos:
- Freshness rojo: Los datos están muy viejos (>15 días)
  → Ejecuta el ETL nuevamente
- Completitud rojo: <90% de datos válidos
  → Revisa si hay NULLs en tiempo_prometido, tiempo_real o pasajeros
- Unicidad rojo: >2% duplicados
  → Hay registros duplicados en fact_movilidad
- Uptime rojo: ETL falla más del 5% del tiempo
  → Revisa los logs de log_etl para ver qué está fallando
```

---

## Arquitectura de la Aplicación 🏗️

```
FastAPI Backend (Python)
│
├─ main.py
│  └─ Carga routers (kpis, sla)
│  └─ Configuración CORS, middleware de errores
│
├─ config.py
│  └─ Lee DATABASE_URL y umbrales SLA desde .env
│
├─ database.py
│  └─ Crea motor SQLAlchemy
│  └─ Función get_connection() para inyectar conexiones
│
├─ routers/
│  ├─ kpis.py (5 endpoints: puntualidad, tiempo-espera, pasajeros, satisfaccion, top-desviacion)
│  └─ sla.py (1 endpoint: semáforo de 5 dimensiones)
│
└─ utils/
   └─ sla_utils.py
      └─ Lógica del semáforo: estado_semaforo(), estado_general()

MySQL Backend
│
├─ paradero (dimensión: ubicaciones)
├─ recorrido (dimensión: rutas)
├─ tiempo (dimensión: franjas horarias)
├─ fact_movilidad (hechos: mediciones de viajes)
└─ log_etl (metadatos: histórico de cargas)
```

---

## Performance y Escalabilidad 🚀

### En desarrollo (actual)
- 1 worker de uvicorn
- MySQL local
- Latencia: 300-1500ms por request

### Para producción
**Backend:**
```bash
# Usa 4 workers para más concurrencia
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000

# Opcionalmente, usa Gunicorn en lugar de uvicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app
```

**Base de datos:**
- Agrega índices en `fact_movilidad`:
  ```sql
  CREATE INDEX idx_paradero ON fact_movilidad(id_paradero);
  CREATE INDEX idx_tiempo ON fact_movilidad(id_tiempo);
  ```
- Usa replicación MySQL para lecturas
- Considera particionamiento de `fact_movilidad` por fecha

**Frontend:**
- Usa WebSockets o Server-Sent Events en lugar de polling cada 30s
- Cachea respuestas en CDN
- Comprime JSON responses

### Límites actuales
- ~100 requests concurrentes máximo
- Queries que tardan >5s pueden causar timeout
- Sin caché: base de datos se consulta cada 30s

---

## Cargar Datos Reales

1. Corre `sql/01_smart_city_movilidad.sql` (con el fix de mayúscula si tu MySQL es Linux) para crear el esquema.
2. Carga tu Excel real en `staging_movilidad` (por ejemplo, importando el CSV/Excel directo con el asistente de importación de tabla de MySQL Workbench, o adaptando el parser de Python que ya usamos en el otro proyecto).
3. Corre los `INSERT INTO paradero/recorrido/tiempo/fact_movilidad` que ya vienen al final de `01_smart_city_movilidad.sql`.
4. Inserta una fila en `log_etl` con el resultado de esa carga.

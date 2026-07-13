-- Datos de demo para probar el backend sin depender de tener el Excel
-- real ya cargado en staging_movilidad. Usa el mismo staging_movilidad
-- que define Smart_city_movilidad.sql.

INSERT INTO staging_movilidad
    (marca_temporal, fecha_observacion, satisfaccion, paradero, recorrido,
     fecha, hora_observacion, franja_horaria, tiempo_prometido, tiempo_real,
     desviacion, pasajeros, sat_espera, sat_puntualidad, sat_servicio, opinion)
VALUES
    (NOW(), '2026-06-01', 'Aceptable', 'PB1340', 'B18', '2026-06-01', '08:10:00', 'Mañana', 5, 8, 3, 12, 3, 3, 3, NULL),
    (NOW(), '2026-06-01', 'Satisfecho', 'PB1340', 'B18', '2026-06-01', '08:20:00', 'Mañana', 5, 6, 1, 9, 4, 4, 4, NULL),
    (NOW(), '2026-06-01', 'Malo', 'PB405', '314', '2026-06-01', '18:05:00', 'Tarde', 10, 22, 12, 20, 2, 2, 2, NULL),
    (NOW(), '2026-06-02', 'Muy malo', 'PB1329', 'B17', '2026-06-02', '07:40:00', 'Mañana', 10, 30, 20, 5, 1, 1, 1, NULL),
    (NOW(), '2026-06-02', 'Satisfecho', 'PB405', '303', '2026-06-02', '17:50:00', 'Tarde', 15, 14, -1, 18, 5, 4, 4, NULL);

-- Ejecutar el mismo bloque de carga de Smart_city_movilidad.sql (paradero,
-- recorrido, tiempo, fact_movilidad) para poblar desde este staging.
INSERT INTO paradero(nombre)
SELECT DISTINCT TRIM(paradero) FROM staging_movilidad
WHERE paradero IS NOT NULL AND TRIM(paradero) <> ''
  AND TRIM(paradero) NOT IN (SELECT nombre FROM paradero);

INSERT INTO recorrido(codigo)
SELECT DISTINCT TRIM(recorrido) FROM staging_movilidad
WHERE recorrido IS NOT NULL AND TRIM(recorrido) <> ''
  AND TRIM(recorrido) NOT IN (SELECT codigo FROM recorrido);

INSERT INTO tiempo(fecha, franja)
SELECT DISTINCT fecha, TRIM(franja_horaria) FROM staging_movilidad s
WHERE fecha IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM tiempo t WHERE t.fecha = s.fecha AND t.franja = TRIM(s.franja_horaria));

INSERT INTO fact_movilidad
    (id_paradero, id_recorrido, id_tiempo, tiempo_prometido, tiempo_real,
     pasajeros, sat_espera, sat_puntualidad, sat_servicio, desviacion, puntual, comentario)
SELECT
    p.id_paradero, r.id_recorrido, t.id_tiempo,
    s.tiempo_prometido, s.tiempo_real, s.pasajeros,
    s.sat_espera, s.sat_puntualidad, s.sat_servicio, s.desviacion,
    CASE WHEN s.desviacion <= 0 THEN TRUE ELSE FALSE END,
    s.opinion
FROM staging_movilidad s
JOIN paradero p ON TRIM(p.nombre) = TRIM(s.paradero)
JOIN recorrido r ON TRIM(r.codigo) = TRIM(s.recorrido)
JOIN tiempo t ON t.fecha = s.fecha AND TRIM(t.franja) = TRIM(s.franja_horaria)
WHERE s.fecha IS NOT NULL;

-- Log de una corrida del ETL (incluye duración para medir Pipeline SLA)
INSERT INTO log_etl (fecha_ejecucion, registro_cargados, duracion_seg, estado)
VALUES (NOW(), (SELECT COUNT(*) FROM fact_movilidad), 142.50, 'exitoso');

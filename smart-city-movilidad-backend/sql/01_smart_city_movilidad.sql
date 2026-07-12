create database Paraderos;
use paraderos;

create table paradero(
id_paradero INT auto_increment PRIMARY KEY,
nombre varchar(100) not null
);

create table recorrido(
id_recorrido INT auto_increment primary key,
codigo varchar(100) not null
);

create table tiempo(
id_tiempo int auto_increment primary key,
fecha date not null,
franja varchar(100)
);

create table fact_movilidad(
id_movilidad int auto_increment primary key,

id_paradero int,
id_recorrido int,
id_tiempo int,

tiempo_prometido int,
tiempo_real int,

pasajeros int,

sat_espera int,
sat_puntualidad int,
sat_servicio int,

desviacion int,
puntual boolean,
comentario text,

foreign key(id_paradero) references paradero(id_paradero),
foreign key(id_recorrido) references recorrido(id_recorrido),
foreign key(id_tiempo) references tiempo(id_tiempo)
);

create table log_etl(
id_log int auto_increment primary key,
fecha_ejecucion datetime,
registro_cargados int,
estado varchar(30)
);

CREATE TABLE staging_movilidad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    marca_temporal varchar(255),
    fecha_observacion date,
    satisfaccion varchar(255),
    paradero VARCHAR(255),
    recorrido VARCHAR(50),
    fecha DATE,
    hora_observacion VARCHAR(50),
    franja_horaria VARCHAR(50),
    tiempo_prometido INT,
    tiempo_real INT,
    desviacion INT,
    pasajeros INT,
    sat_espera INT,
    sat_puntualidad INT,
    sat_servicio INT,
    opinion TEXT
);

select * from staging_movilidad;

INSERT INTO paradero(nombre)
SELECT DISTINCT TRIM(paradero)
FROM staging_movilidad
WHERE paradero IS NOT NULL
AND TRIM(paradero) <> '';


INSERT INTO recorrido(codigo)
SELECT DISTINCT TRIM(recorrido)
FROM staging_movilidad
WHERE recorrido IS NOT NULL
AND TRIM(recorrido) <> '';


INSERT INTO tiempo(fecha, franja)
SELECT DISTINCT
    fecha,
    TRIM(franja_horaria)
FROM staging_movilidad
WHERE fecha IS NOT NULL;


INSERT INTO fact_movilidad
(
    id_paradero,
    id_recorrido,
    id_tiempo,
    tiempo_prometido,
    tiempo_real,
    pasajeros,
    sat_espera,
    sat_puntualidad,
    sat_servicio,
    desviacion,
    puntual,
    comentario
)
SELECT
    p.id_paradero,
    r.id_recorrido,
    t.id_tiempo,
    s.tiempo_prometido,
    s.tiempo_real,
    s.pasajeros,
    s.sat_espera,
    s.sat_puntualidad,
    s.sat_servicio,
    s.desviacion,
    CASE
        WHEN s.desviacion <= 0 THEN TRUE
        ELSE FALSE
    END,
    s.opinion
FROM staging_movilidad s
INNER JOIN paradero p
    ON TRIM(p.nombre) = TRIM(s.paradero)
INNER JOIN recorrido r
    ON TRIM(r.codigo) = TRIM(s.recorrido)
INNER JOIN tiempo t
    ON t.fecha = s.fecha
   AND TRIM(t.franja) = TRIM(s.franja_horaria)
WHERE s.fecha IS NOT NULL;

select * from paradero;
select * from recorrido;
select * from tiempo;
select * from fact_movilidad;
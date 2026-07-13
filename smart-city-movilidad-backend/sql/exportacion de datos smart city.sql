-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: paraderos
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `fact_movilidad`
--

DROP TABLE IF EXISTS `fact_movilidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fact_movilidad` (
  `id_movilidad` int(11) NOT NULL AUTO_INCREMENT,
  `id_paradero` int(11) DEFAULT NULL,
  `id_recorrido` int(11) DEFAULT NULL,
  `id_tiempo` int(11) DEFAULT NULL,
  `tiempo_prometido` int(11) DEFAULT NULL,
  `tiempo_real` int(11) DEFAULT NULL,
  `pasajeros` int(11) DEFAULT NULL,
  `sat_espera` int(11) DEFAULT NULL,
  `sat_puntualidad` int(11) DEFAULT NULL,
  `sat_servicio` int(11) DEFAULT NULL,
  `desviacion` int(11) DEFAULT NULL,
  `puntual` tinyint(1) DEFAULT NULL,
  `comentario` text DEFAULT NULL,
  PRIMARY KEY (`id_movilidad`),
  KEY `id_paradero` (`id_paradero`),
  KEY `id_recorrido` (`id_recorrido`),
  KEY `id_tiempo` (`id_tiempo`),
  CONSTRAINT `fact_movilidad_ibfk_1` FOREIGN KEY (`id_paradero`) REFERENCES `paradero` (`id_paradero`),
  CONSTRAINT `fact_movilidad_ibfk_2` FOREIGN KEY (`id_recorrido`) REFERENCES `recorrido` (`id_recorrido`),
  CONSTRAINT `fact_movilidad_ibfk_3` FOREIGN KEY (`id_tiempo`) REFERENCES `tiempo` (`id_tiempo`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fact_movilidad`
--

LOCK TABLES `fact_movilidad` WRITE;
/*!40000 ALTER TABLE `fact_movilidad` DISABLE KEYS */;
INSERT INTO `fact_movilidad` VALUES (1,1,1,1,5,10,6,5,1,3,5,0,NULL),(2,1,2,2,10,3,4,1,2,3,-7,1,'Yo opino quie daddy yanki es wekito'),(3,1,1,3,10,7,4,3,3,4,-3,1,'no'),(4,1,2,4,15,40,5,4,1,2,25,0,'la micro pasao a meao y las guagua no se callan nunca las caga ( formulen bien cochino qliao)'),(5,2,3,5,3,2,3,4,4,1,-1,1,NULL),(6,2,3,6,10,7,10,2,4,1,-3,1,NULL),(7,2,1,7,5,4,7,3,5,1,-1,1,NULL),(8,1,4,8,10,20,20,3,4,4,10,0,NULL),(9,2,3,9,10,15,5,2,5,5,5,0,NULL),(10,1,5,10,27,34,16,3,4,1,7,0,NULL),(11,1,1,11,31,39,23,3,3,4,8,0,NULL),(12,2,4,5,24,29,14,1,3,NULL,5,0,NULL),(13,1,2,12,8,12,3,5,2,4,4,0,NULL),(14,2,3,13,NULL,45,21,2,1,2,NULL,0,'una vez se pincho la rueda en medio del recorrido'),(15,2,1,9,25,40,16,4,1,2,15,0,'la falta de higiene en la gente es notable'),(16,3,6,14,10,12,15,5,4,5,2,0,NULL),(17,2,5,15,7,7,30,1,5,5,0,1,'Deberían estar más limpias las micros'),(18,2,1,16,11,20,19,3,1,5,9,0,NULL),(19,2,1,3,5,8,60,3,3,4,3,0,NULL),(20,2,1,17,15,20,5,3,1,3,5,0,NULL),(21,2,3,8,10,12,7,3,1,2,2,0,NULL),(22,3,6,11,35,50,8,3,5,2,15,0,NULL),(23,4,2,18,15,25,4,3,5,2,10,0,NULL),(24,3,6,19,10,30,6,3,4,4,20,0,'Podrian mejorar la forma de redactar en las preguntas, hay algunas las cuales no se entienden muy bien y se complica poder responderlas'),(25,2,3,5,10,15,8,3,2,3,5,0,'No entendí las preguntas ?‍?️'),(26,4,2,20,17,22,4,2,2,3,5,0,NULL),(27,3,6,21,19,12,14,5,3,2,-7,1,'Yo digo que hagan un sistema que uno puede ver donde viene la micro realmente'),(28,4,2,22,14,16,7,2,2,1,2,0,'No entendi muy bien la encuesta, se me hizo poco intuitiva'),(29,3,3,12,25,20,3,1,4,5,-5,1,NULL),(30,3,5,23,16,20,20,3,5,5,4,0,NULL),(31,3,6,24,10,8,4,5,3,3,-2,1,NULL),(32,5,7,25,20,16,16,1,1,2,-4,1,'Considerar a los que tienen la posibilidad de irse en transporte privado, pero no se si  lo consideren'),(33,6,8,8,4,10,20,5,5,5,6,0,'Que la app de red sea en el tiempo que dice y los tiempos de espera para la micro muchas veces es muy lento pasan cada 30 minutos'),(34,5,9,15,12,13,12,3,2,3,1,0,NULL),(35,7,10,26,5,10,3,2,3,4,5,0,'Explicar de mejor forma las preguntas ya que no se entienden todas y especificar'),(36,7,10,27,4,6,4,3,2,3,2,0,NULL),(37,5,7,3,3,4,6,4,4,1,1,0,NULL),(38,7,10,28,15,30,10,2,4,3,15,0,NULL),(39,5,7,29,5,8,5,5,5,5,3,0,'Muy conforme con el transporte actual. Los tiempos de espera son los adecuados y el trato al usuario es excelente. Agradezco que realicen estas encuestas para mantener la calidad del servicio'),(40,7,11,30,5,5,30,3,3,3,0,1,NULL),(41,7,10,31,6,15,6,1,1,3,9,0,NULL),(42,6,8,20,5,8,4,5,3,2,3,0,NULL);
/*!40000 ALTER TABLE `fact_movilidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `log_etl`
--

DROP TABLE IF EXISTS `log_etl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_etl` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_ejecucion` datetime DEFAULT NULL,
  `registro_cargados` int(11) DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `duracion_seg` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_etl`
--

LOCK TABLES `log_etl` WRITE;
/*!40000 ALTER TABLE `log_etl` DISABLE KEYS */;
INSERT INTO `log_etl` VALUES (1,'2026-07-12 16:25:14',44,'OK',142.50);
/*!40000 ALTER TABLE `log_etl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paradero`
--

DROP TABLE IF EXISTS `paradero`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paradero` (
  `id_paradero` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_paradero`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paradero`
--

LOCK TABLES `paradero` WRITE;
/*!40000 ALTER TABLE `paradero` DISABLE KEYS */;
INSERT INTO `paradero` VALUES (1,'PB1340, (B18, B18e, B32'),(2,'PB405, (303, 314, B45)'),(3,'PB1329, (B17)'),(4,'PB1340, (B18, B18e, B32)'),(5,'PB405 (303 - 314 - B45)'),(6,'PB1340 (B18 - B18e - B32)'),(7,'PB1329 (B17)');
/*!40000 ALTER TABLE `paradero` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recorrido`
--

DROP TABLE IF EXISTS `recorrido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recorrido` (
  `id_recorrido` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(100) NOT NULL,
  PRIMARY KEY (`id_recorrido`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recorrido`
--

LOCK TABLES `recorrido` WRITE;
/*!40000 ALTER TABLE `recorrido` DISABLE KEYS */;
INSERT INTO `recorrido` VALUES (1,'314, Plaza Italia'),(2,'B18, Vespucio Norte'),(3,'303, Plaza Italia'),(4,'B18e, Los Libertadores'),(5,'B45, Rigoberto Jara'),(6,'B17, Huamachuco'),(7,'303 - Plaza Italia'),(8,'B18e - Los Libertadores'),(9,'B45 - Rigoberto Jara'),(10,'B17 - Huamachuco'),(11,'314 - Plaza Italia');
/*!40000 ALTER TABLE `recorrido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staging_movilidad`
--

DROP TABLE IF EXISTS `staging_movilidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staging_movilidad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `marca_temporal` varchar(255) DEFAULT NULL,
  `fecha_observacion` date DEFAULT NULL,
  `satisfaccion` varchar(255) DEFAULT NULL,
  `paradero` varchar(255) DEFAULT NULL,
  `recorrido` varchar(50) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `hora_observacion` varchar(50) DEFAULT NULL,
  `franja_horaria` varchar(50) DEFAULT NULL,
  `tiempo_prometido` int(11) DEFAULT NULL,
  `tiempo_real` int(11) DEFAULT NULL,
  `desviacion` int(11) DEFAULT NULL,
  `pasajeros` int(11) DEFAULT NULL,
  `sat_espera` int(11) DEFAULT NULL,
  `sat_puntualidad` int(11) DEFAULT NULL,
  `sat_servicio` int(11) DEFAULT NULL,
  `opinion` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staging_movilidad`
--

LOCK TABLES `staging_movilidad` WRITE;
/*!40000 ALTER TABLE `staging_movilidad` DISABLE KEYS */;
INSERT INTO `staging_movilidad` VALUES (1,'6/25/2026 19:45:55','2026-06-04','Malo','PB1340, (B18, B18e, B32','314, Plaza Italia','2026-06-12',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',5,10,5,6,5,1,3,NULL),(2,'6/25/2026 19:50:32','2026-06-04','Malo','PB1340, (B18, B18e, B32','B18, Vespucio Norte','2026-06-07',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',10,3,-7,4,1,2,3,'Yo opino quie daddy yanki es wekito'),(3,'6/25/2026 19:50:58','2026-06-02','Satisfecho','PB1340, (B18, B18e, B32','314, Plaza Italia','2026-06-09',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',10,7,-3,4,3,3,4,'no'),(4,'6/25/2026 19:51:24','2026-06-09','Muy malo','PB1340, (B18, B18e, B32','B18, Vespucio Norte','2026-06-05',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',15,40,25,5,4,1,2,'la micro pasao a meao y las guagua no se callan nunca las caga ( formulen bien cochino qliao)'),(5,'6/25/2026 20:00:18','2026-06-16','Aceptable','PB405, (303, 314, B45)','303, Plaza Italia','2026-06-15',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',3,2,-1,3,4,4,1,NULL),(6,'6/25/2026 20:00:19','2026-06-22','Aceptable','PB405, (303, 314, B45)','303, Plaza Italia','2026-06-17',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',10,7,-3,10,2,4,1,NULL),(7,'6/25/2026 20:02:19','2026-06-12','Satisfecho','PB405, (303, 314, B45)','314, Plaza Italia','2026-06-11',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',5,4,-1,7,3,5,1,NULL),(8,'6/25/2026 20:11:29','2026-06-20','Aceptable','PB1340, (B18, B18e, B32','B18e, Los Libertadores','2026-06-25',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',10,20,10,20,3,4,4,NULL),(9,'6/25/2026 20:13:56','2026-06-03','Satisfecho','PB405, (303, 314, B45)','303, Plaza Italia','2026-06-24',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',10,15,5,5,2,5,5,NULL),(10,'6/25/2026 20:19:21','2026-06-14','Aceptable','PB1340, (B18, B18e, B32','B45, Rigoberto Jara','2026-06-18',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',27,34,7,16,3,4,1,NULL),(11,'6/25/2026 20:20:06','2026-06-14','Satisfecho','PB1340, (B18, B18e, B32','314, Plaza Italia','2026-06-22',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',31,39,8,23,3,3,4,NULL),(12,'6/25/2026 20:21:01','2026-06-16','Aceptable','PB405, (303, 314, B45)','B18e, Los Libertadores','2026-06-15',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',24,29,5,14,1,3,NULL,NULL),(13,'6/25/2026 20:28:17','2026-06-15','Satisfecho','PB1340, (B18, B18e, B32','B18, Vespucio Norte','2026-06-25',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',8,12,4,3,5,2,4,NULL),(14,'6/25/2026 20:35:34','2026-06-06','Malo','PB405, (303, 314, B45)','303, Plaza Italia','2026-06-13',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',NULL,45,NULL,21,2,1,2,'una vez se pincho la rueda en medio del recorrido'),(15,'6/25/2026 20:36:36','2026-06-07','Malo','PB405, (303, 314, B45)','314, Plaza Italia','2026-06-24',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',25,40,15,16,4,1,2,'la falta de higiene en la gente es notable'),(16,'6/25/2026 20:43:17','2026-06-07','Satisfecho','PB1329, (B17)','B17, Huamachuco','2026-06-27',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',10,12,2,15,5,4,5,NULL),(17,'6/25/2026 20:52:10','2026-06-05','Aceptable','PB405, (303, 314, B45)','B45, Rigoberto Jara','2026-06-26',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',7,7,0,30,1,5,5,'Deberían estar más limpias las micros'),(18,'6/25/2026 21:00:09','2026-06-25','Aceptable','PB405, (303, 314, B45)','314, Plaza Italia','2026-06-15',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',11,20,9,19,3,1,5,NULL),(19,'6/25/2026 21:03:06','2026-06-22','Aceptable','PB405, (303, 314, B45)','314, Plaza Italia','2026-06-09',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',5,8,3,60,3,3,4,NULL),(20,'6/25/2026 21:17:26','2026-06-17','Malo','PB1329, (B17)','B17, Huamachuco',NULL,NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',20,26,6,2,4,3,3,NULL),(21,'6/25/2026 21:24:19','2026-06-21','Aceptable','PB1340, (B18, B18e, B32','B18e, Los Libertadores',NULL,NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',10,15,5,13,2,3,1,NULL),(22,'6/25/2026 21:26:01','2026-06-24','Satisfecho','PB405, (303, 314, B45)','314, Plaza Italia','2026-06-23',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',15,20,5,5,3,1,3,NULL),(23,'6/25/2026 21:27:01','2026-06-27','Aceptable','PB405, (303, 314, B45)','303, Plaza Italia','2026-06-25',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',10,12,2,7,3,1,2,NULL),(24,'6/25/2026 21:32:28','2026-06-28','Aceptable','PB1329, (B17)','B17, Huamachuco','2026-06-22',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',35,50,15,8,3,5,2,NULL),(25,'6/25/2026 22:03:17','2026-06-18','Aceptable','PB1340, (B18, B18e, B32)','B18, Vespucio Norte','2026-06-23',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',15,25,10,4,3,5,2,NULL),(26,'6/25/2026 22:06:28','2026-06-30','Aceptable','PB1329, (B17)','B17, Huamachuco','2026-06-14',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',10,30,20,6,3,4,4,'Podrian mejorar la forma de redactar en las preguntas, hay algunas las cuales no se entienden muy bien y se complica poder responderlas'),(27,'6/25/2026 22:08:50','2026-07-01','Malo','PB405, (303, 314, B45)','303, Plaza Italia','2026-06-15',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',10,15,5,8,3,2,3,'No entendí las preguntas ?‍?️'),(28,'6/25/2026 22:10:02','2026-07-02','Aceptable','PB1340, (B18, B18e, B32)','B18, Vespucio Norte','2026-06-29',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',17,22,5,4,2,2,3,NULL),(29,'6/25/2026 22:52:11','2026-06-08','Aceptable','PB1329, (B17)','B17, Huamachuco','2026-06-16',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',19,12,-7,14,5,3,2,'Yo digo que hagan un sistema que uno puede ver donde viene la micro realmente'),(30,'6/25/2026 22:53:37','2026-06-13','Aceptable','PB1340, (B18, B18e, B32)','B18, Vespucio Norte','2026-06-11',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',14,16,2,7,2,2,1,'No entendi muy bien la encuesta, se me hizo poco intuitiva'),(31,'6/25/2026 23:03:03','2026-06-24','Aceptable','PB1329, (B17)','303, Plaza Italia','2026-06-25',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',25,20,-5,3,1,4,5,NULL),(32,'6/25/2026 23:06:47','2026-06-25','Aceptable','PB1329, (B17)','B45, Rigoberto Jara','2026-06-20',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',16,20,4,20,3,5,5,NULL),(33,'6/25/2026 23:08:40','2026-06-28','Aceptable','PB1329, (B17)','B17, Huamachuco','2026-06-22',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',10,8,-2,4,5,3,3,NULL),(34,'6/25/2026 23:09:07','2026-06-27','Aceptable','PB405 (303 - 314 - B45)','303 - Plaza Italia','2026-06-30',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',20,16,-4,16,1,1,2,'Considerar a los que tienen la posibilidad de irse en transporte privado, pero no se si  lo consideren'),(35,'6/25/2026 23:44:12','2026-06-01','Malo','PB1340 (B18 - B18e - B32)','B18e - Los Libertadores','2026-06-25',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',4,10,6,20,5,5,5,'Que la app de red sea en el tiempo que dice y los tiempos de espera para la micro muchas veces es muy lento pasan cada 30 minutos'),(36,'6/26/2026 8:23:10','2026-06-03','Aceptable','PB405 (303 - 314 - B45)','B45 - Rigoberto Jara','2026-06-26',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',12,13,1,12,3,2,3,NULL),(37,'6/26/2026 12:22:55','2026-06-15','Aceptable','PB1329 (B17)','B17 - Huamachuco','2026-06-24',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',5,10,5,3,2,3,4,'Explicar de mejor forma las preguntas ya que no se entienden todas y especificar'),(38,'6/26/2026 21:44:44','2026-06-17','Aceptable','PB1329 (B17)','B17 - Huamachuco','2026-06-17',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',4,6,2,4,3,2,3,NULL),(39,'6/26/2026 21:46:56','2026-06-09','Aceptable','PB405 (303 - 314 - B45)','303 - Plaza Italia','2026-06-09',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',3,4,1,6,4,4,1,NULL),(40,'6/27/2026 8:19:22','2026-06-01','Malo','PB1329 (B17)','B17 - Huamachuco','2026-07-25',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',15,30,15,10,2,4,3,NULL),(41,'6/27/2026 16:18:23','2026-06-27','Satisfecho','PB405 (303 - 314 - B45)','303 - Plaza Italia','2026-05-31',NULL,'Mañana (Desde las 07:00 hasta las 09:00)',5,8,3,5,5,5,5,'Muy conforme con el transporte actual. Los tiempos de espera son los adecuados y el trato al usuario es excelente. Agradezco que realicen estas encuestas para mantener la calidad del servicio'),(42,'6/28/2026 13:32:30','2026-06-28','Aceptable','PB1329 (B17)','314 - Plaza Italia','2026-06-28',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',5,5,0,30,3,3,3,NULL),(43,'6/30/2026 16:11:21','2026-06-30','Aceptable','PB1329 (B17)','B17 - Huamachuco','2026-06-30',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',6,15,9,6,1,1,3,NULL),(44,'7/5/2026 16:38:07','2026-06-29','Aceptable','PB1340 (B18 - B18e - B32)','B18e - Los Libertadores','2026-06-29',NULL,'Tarde (Desde las 17:00 Hasta las 19:00)',5,8,3,4,5,3,2,NULL);
/*!40000 ALTER TABLE `staging_movilidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tiempo`
--

DROP TABLE IF EXISTS `tiempo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tiempo` (
  `id_tiempo` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `franja` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_tiempo`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tiempo`
--

LOCK TABLES `tiempo` WRITE;
/*!40000 ALTER TABLE `tiempo` DISABLE KEYS */;
INSERT INTO `tiempo` VALUES (1,'2026-06-12','Mañana (Desde las 07:00 hasta las 09:00)'),(2,'2026-06-07','Tarde (Desde las 17:00 Hasta las 19:00)'),(3,'2026-06-09','Mañana (Desde las 07:00 hasta las 09:00)'),(4,'2026-06-05','Tarde (Desde las 17:00 Hasta las 19:00)'),(5,'2026-06-15','Tarde (Desde las 17:00 Hasta las 19:00)'),(6,'2026-06-17','Tarde (Desde las 17:00 Hasta las 19:00)'),(7,'2026-06-11','Mañana (Desde las 07:00 hasta las 09:00)'),(8,'2026-06-25','Mañana (Desde las 07:00 hasta las 09:00)'),(9,'2026-06-24','Tarde (Desde las 17:00 Hasta las 19:00)'),(10,'2026-06-18','Mañana (Desde las 07:00 hasta las 09:00)'),(11,'2026-06-22','Tarde (Desde las 17:00 Hasta las 19:00)'),(12,'2026-06-25','Tarde (Desde las 17:00 Hasta las 19:00)'),(13,'2026-06-13','Tarde (Desde las 17:00 Hasta las 19:00)'),(14,'2026-06-27','Mañana (Desde las 07:00 hasta las 09:00)'),(15,'2026-06-26','Mañana (Desde las 07:00 hasta las 09:00)'),(16,'2026-06-15','Mañana (Desde las 07:00 hasta las 09:00)'),(17,'2026-06-23','Tarde (Desde las 17:00 Hasta las 19:00)'),(18,'2026-06-23','Mañana (Desde las 07:00 hasta las 09:00)'),(19,'2026-06-14','Mañana (Desde las 07:00 hasta las 09:00)'),(20,'2026-06-29','Tarde (Desde las 17:00 Hasta las 19:00)'),(21,'2026-06-16','Mañana (Desde las 07:00 hasta las 09:00)'),(22,'2026-06-11','Tarde (Desde las 17:00 Hasta las 19:00)'),(23,'2026-06-20','Mañana (Desde las 07:00 hasta las 09:00)'),(24,'2026-06-22','Mañana (Desde las 07:00 hasta las 09:00)'),(25,'2026-06-30','Mañana (Desde las 07:00 hasta las 09:00)'),(26,'2026-06-24','Mañana (Desde las 07:00 hasta las 09:00)'),(27,'2026-06-17','Mañana (Desde las 07:00 hasta las 09:00)'),(28,'2026-07-25','Mañana (Desde las 07:00 hasta las 09:00)'),(29,'2026-05-31','Mañana (Desde las 07:00 hasta las 09:00)'),(30,'2026-06-28','Tarde (Desde las 17:00 Hasta las 19:00)'),(31,'2026-06-30','Tarde (Desde las 17:00 Hasta las 19:00)');
/*!40000 ALTER TABLE `tiempo` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-12 22:01:29

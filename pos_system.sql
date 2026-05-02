-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: pos_system
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (7,'Apple'),(15,'Samsung'),(16,'LG'),(17,'Google'),(18,'Dell'),(19,'E-Reader\'s'),(20,'Microsoft'),(21,'Sony'),(22,'Amazon'),(23,'Lenovo'),(24,'Laptop\'s');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_payment_status`
--

DROP TABLE IF EXISTS `order_payment_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_payment_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `method` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_order_id` (`order_id`),
  CONSTRAINT `fk_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_payment_status`
--

LOCK TABLES `order_payment_status` WRITE;
/*!40000 ALTER TABLE `order_payment_status` DISABLE KEYS */;
INSERT INTO `order_payment_status` VALUES (1,98,'Paid','Cash'),(2,99,'Paid','Cash'),(3,100,'Paid','Cash'),(4,101,'Paid','Cash'),(5,102,'Paid','Cash'),(6,103,'Paid','Cash'),(7,104,'Paid','Cash'),(8,105,'Paid','Cash'),(9,105,'Paid','Cash'),(10,106,'Paid','Cash'),(11,106,'Paid','Cash'),(12,106,'Paid','Cash'),(13,107,'Paid','Cash'),(14,108,'Paid','Cash'),(15,108,'Paid','Cash'),(16,108,'Paid','Cash'),(17,109,'Paid','Cash'),(18,110,'Paid','Cash'),(19,111,'Paid','Cash'),(20,111,'Paid','Cash'),(21,112,'Paid','Cash'),(22,112,'Paid','Cash'),(23,112,'Paid','Cash'),(24,112,'Paid','Cash'),(25,112,'Paid','Cash'),(26,113,'Paid','Cash'),(27,113,'Paid','Cash'),(28,113,'Paid','Cash'),(29,113,'Paid','Cash'),(30,113,'Paid','Cash'),(31,114,'Paid','Cash'),(32,114,'Paid','Cash'),(33,114,'Paid','Cash'),(34,115,'Paid','Cash'),(35,115,'Paid','Cash'),(36,115,'Paid','Cash'),(37,115,'Paid','Cash'),(38,115,'Paid','Cash'),(39,115,'Paid','Cash'),(40,116,'Paid','Cash'),(41,116,'Paid','Cash'),(42,116,'Paid','Cash'),(43,117,'Paid','Cash'),(44,117,'Paid','Cash'),(45,118,'Paid','Cash'),(46,119,'Paid','Cash'),(47,120,'Paid','Cash'),(48,121,'Paid','Cash'),(49,121,'Paid','Cash'),(50,121,'Paid','Cash'),(51,122,'Paid','Cash'),(52,123,'Paid','Cash'),(53,124,'Paid','Cash'),(54,125,'Paid','Cash'),(55,126,'Paid','Cash'),(56,127,'Paid','Cash'),(57,128,'Paid','Cash'),(58,129,'Paid','Cash'),(59,129,'Paid','Cash'),(60,129,'Paid','Cash'),(61,129,'Paid','Cash'),(62,129,'Paid','Cash'),(63,129,'Paid','Cash'),(64,129,'Paid','Cash'),(65,130,'Paid','Cash'),(66,131,'Paid','Cash'),(67,131,'Paid','Cash'),(68,132,'Paid','Cash'),(69,132,'Paid','Cash'),(70,133,'Paid','Cash'),(71,134,'Paid','Cash'),(72,135,'Paid','Cash'),(73,135,'Paid','Cash'),(74,135,'Paid','Cash'),(75,135,'Paid','Cash'),(76,136,'Paid','Cash'),(77,137,'Paid','Cash'),(78,137,'Paid','Cash'),(79,138,'Paid','Cash'),(80,139,'Paid','Cash'),(81,140,'Paid','Cash'),(82,140,'Paid','Cash'),(83,141,'Paid','Cash'),(84,142,'Paid','Cash'),(85,143,'Paid','Cash'),(86,143,'Paid','Cash'),(87,143,'Paid','Cash'),(88,144,'Paid','Cash'),(89,145,'Partially Paid','Cash'),(90,146,'Partially Paid','Cash'),(91,147,'Paid','Cash'),(92,147,'Paid','Cash'),(93,148,'Paid','Cash'),(94,149,'Paid','Cash'),(95,150,'Paid','Cash'),(96,150,'Paid','Cash'),(97,150,'Paid','Cash'),(98,150,'Paid','Cash'),(99,150,'Paid','Cash'),(100,150,'Paid','Cash'),(101,150,'Paid','Cash'),(102,150,'Paid','Cash'),(103,150,'Paid','Cash'),(104,151,'Paid','Cash'),(105,151,'Paid','Cash'),(106,152,'Paid','Cash'),(107,153,'Paid','Cash'),(108,154,'Paid','Cash'),(109,155,'Paid','Cash'),(110,156,'Paid','Cash'),(111,157,'Paid','Cash'),(112,157,'Paid','Cash'),(113,158,'Paid','Cash'),(114,158,'Paid','Cash'),(115,158,'Paid','Cash'),(116,158,'Paid','Cash'),(117,158,'Paid','Cash'),(118,159,'Paid','Cash'),(119,160,'Paid','Cash'),(120,161,'Paid','Cash'),(121,162,'Paid','Cash'),(122,162,'Paid','Cash'),(123,163,'Paid','Cash'),(124,164,'Partially Paid','Cash'),(125,165,'Pending','Unknown'),(126,167,'Paid','Cash'),(127,168,'Paid','Cash'),(128,169,'Paid','Cash'),(129,169,'Paid','Cash'),(130,170,'Paid','Cash'),(131,170,'Paid','Cash'),(132,170,'Paid','Cash'),(133,171,'Paid','Cash'),(134,172,'Paid','Cash'),(135,173,'Pending','Unknown'),(136,174,'Paid','Cash'),(137,175,'Paid','Cash'),(138,176,'Paid','Cash'),(139,177,'Paid','Cash'),(140,178,'Paid','Cash'),(141,179,'Paid','Cash'),(142,180,'Paid','Cash'),(143,180,'Paid','Cash'),(144,181,'Paid','Cash'),(145,182,'Paid','Cash'),(146,183,'Paid','Cash'),(147,184,'Paid','Cash'),(148,185,'Pending','Unknown'),(149,186,'Pending','Unknown'),(150,187,'Pending','Unknown'),(151,188,'Pending','Unknown'),(152,189,'Pending','Unknown'),(153,190,'Pending','Unknown'),(154,191,'Pending','Unknown'),(155,192,'Pending','Unknown'),(156,193,'Pending','Unknown'),(157,194,'Paid','Cash'),(158,195,'Paid','Cash'),(159,196,'Pending','Unknown'),(160,197,'Paid','Cash'),(161,198,'Paid','Cash'),(162,199,'Paid','Cash'),(163,200,'Paid','Cash'),(164,201,'Pending','Unknown'),(165,202,'Pending','Unknown'),(166,205,'Pending','Unknown'),(167,206,'Pending','Unknown'),(168,207,'Partially Paid','Cash');
/*!40000 ALTER TABLE `order_payment_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_payments`
--

DROP TABLE IF EXISTS `order_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `price` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `foreign_key_order_id` (`order_id`),
  CONSTRAINT `foreign_key_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_payments`
--

LOCK TABLES `order_payments` WRITE;
/*!40000 ALTER TABLE `order_payments` DISABLE KEYS */;
INSERT INTO `order_payments` VALUES (1,159,'2599.98'),(2,159,'100'),(3,159,'200'),(4,154,'603'),(5,154,'603'),(6,155,'10500'),(7,159,'2600'),(8,160,'2500'),(9,160,'2500'),(10,161,'2300'),(11,161,'200'),(12,161,'2500'),(13,162,'87'),(14,162,'3713'),(15,163,'5000'),(16,164,'200'),(17,164,'189'),(18,164,'89'),(19,168,'3500'),(20,170,'4299'),(21,167,'1900'),(22,169,'6'),(23,171,'2500'),(24,174,'7000'),(25,175,'2500'),(26,180,'787'),(27,181,'10500'),(28,182,'200'),(29,183,'5000'),(30,180,'1111'),(31,182,'599'),(32,178,'1599'),(33,177,'1650'),(34,179,'322'),(35,179,'233'),(36,179,'233'),(37,176,'332'),(38,176,'0'),(39,176,'0'),(40,176,'2968'),(41,179,'3300'),(42,172,'800'),(43,172,'35453453'),(44,184,'0'),(45,184,'3799'),(46,184,'11'),(47,197,'12122'),(48,195,'0'),(49,195,'777667766776677'),(50,194,'9899'),(51,198,'0'),(52,198,'23423'),(53,199,'0'),(54,199,'1500'),(55,200,'2342342342342342144'),(56,199,'3500'),(57,207,'200');
/*!40000 ALTER TABLE `order_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ordered_item`
--

DROP TABLE IF EXISTS `ordered_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordered_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_items_order_id` (`order_id`),
  KEY `fk_items_product_id` (`product_id`),
  CONSTRAINT `fk_items_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_items_product_id` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `ordered_item_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `ordered_item_chk_2` CHECK ((`unit_price` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=277 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordered_item`
--

LOCK TABLES `ordered_item` WRITE;
/*!40000 ALTER TABLE `ordered_item` DISABLE KEYS */;
INSERT INTO `ordered_item` VALUES (109,98,163,1,899.00),(110,99,33,2,3499.99),(111,100,34,2,2499.99),(112,101,34,3,2499.99),(113,102,41,1,1299.99),(114,103,44,1,799.00),(115,104,37,1,1899.99),(116,105,37,2,1899.99),(117,105,35,1,1299.99),(118,106,44,1,799.00),(119,106,43,1,1099.00),(120,106,41,1,1299.99),(121,107,34,1,2499.99),(122,108,37,1,1899.99),(123,108,35,1,1299.99),(124,108,34,1,2499.99),(125,109,34,1,2499.99),(126,110,33,3,3499.99),(127,111,34,2,2499.99),(128,111,43,1,1099.00),(129,112,43,1,1099.00),(130,112,41,1,1299.99),(131,112,46,1,449.00),(132,112,45,1,749.99),(133,112,40,1,1649.99),(134,113,37,1,1899.99),(135,113,35,1,1299.99),(136,113,43,1,1099.00),(137,113,49,1,899.99),(138,113,47,1,499.00),(139,114,35,1,1299.99),(140,114,34,1,2499.99),(141,114,33,1,3499.99),(142,115,44,1,799.00),(143,115,37,1,1899.99),(144,115,43,1,1099.00),(145,115,35,1,1299.99),(146,115,41,1,1299.99),(147,115,34,1,2499.99),(148,116,35,1,1299.99),(149,116,34,1,2499.99),(150,116,41,1,1299.99),(151,117,34,3,2499.99),(152,117,45,1,749.99),(153,118,34,1,2499.99),(154,119,34,1,2499.99),(155,120,37,2,1899.99),(156,121,43,1,1099.00),(157,121,41,1,1299.99),(158,121,40,1,1649.99),(159,122,35,2,1299.99),(160,123,33,1,3499.99),(161,124,35,1,1299.99),(162,125,33,1,3499.99),(163,126,40,1,1649.99),(164,127,35,2,1299.99),(165,128,43,2,1099.00),(166,129,35,1,1299.99),(167,129,37,1,1899.99),(168,129,44,1,799.00),(169,129,43,1,1099.00),(170,129,47,1,499.00),(171,129,49,1,899.99),(172,129,46,1,449.00),(173,130,35,2,1299.99),(174,131,35,2,1299.99),(175,131,43,1,1099.00),(176,132,35,2,1299.99),(177,132,43,1,1099.00),(178,133,47,2,499.00),(179,134,37,1,1899.99),(180,135,37,1,1899.99),(181,135,44,1,799.00),(182,135,43,1,1099.00),(183,135,49,1,899.99),(184,136,35,2,1299.99),(185,137,41,1,1299.99),(186,137,40,1,1649.99),(187,138,35,1,1299.99),(188,139,35,1,1299.99),(189,140,35,1,1299.99),(190,140,43,1,1099.00),(191,141,35,2,1299.99),(192,142,35,2,1299.99),(193,143,37,1,1899.99),(194,143,44,1,799.00),(195,143,43,1,1099.00),(196,144,37,2,1899.99),(197,145,43,1,1099.00),(198,146,35,2,1299.99),(199,147,43,1,1099.00),(200,147,44,1,799.00),(201,148,43,2,1099.00),(202,149,43,2,1099.00),(203,150,41,1,1299.99),(204,150,40,1,1649.99),(205,150,45,2,749.99),(206,150,46,2,449.00),(207,150,47,3,499.00),(208,150,49,1,899.99),(209,150,51,1,149.99),(210,150,52,1,899.99),(211,150,53,1,399.99),(212,151,100,1,799.99),(213,151,106,1,589.99),(214,152,168,2,999.99),(215,153,34,3,2499.99),(216,154,165,3,200.99),(217,155,33,3,3499.99),(218,156,33,2,3499.99),(219,157,33,1,3499.99),(220,157,34,1,2499.99),(221,158,47,3,499.00),(222,158,45,1,749.99),(223,158,44,1,799.00),(224,158,78,1,299.00),(225,158,54,1,249.99),(226,159,35,2,1299.99),(227,160,34,2,2499.99),(228,161,34,2,2499.99),(229,162,35,1,1299.99),(230,162,34,1,2499.99),(231,163,34,2,2499.99),(232,164,44,2,799.00),(233,165,43,1,1099.00),(234,167,37,1,1899.99),(235,168,33,1,3499.99),(236,169,1,1,1.00),(237,169,2,2,2.00),(238,170,37,1,1899.99),(239,170,35,1,1299.99),(240,170,43,1,1099.00),(241,171,34,1,2499.99),(242,172,34,2,2499.99),(243,173,40,2,1649.99),(244,174,33,2,3499.99),(245,175,34,1,2499.99),(246,176,40,2,1649.99),(247,177,40,1,1649.99),(248,178,44,2,799.00),(249,179,44,1,799.00),(250,180,43,1,1099.00),(251,180,44,1,799.00),(252,181,33,3,3499.99),(253,182,44,1,799.00),(254,183,34,2,2499.99),(255,184,37,2,1899.99),(256,185,34,2,2499.99),(257,186,33,2,3499.99),(258,187,33,2,3499.99),(259,188,33,1,3499.99),(260,189,44,1,799.00),(261,190,166,1,417.87),(262,191,49,2,899.99),(263,192,47,1,499.00),(264,193,41,2,1299.99),(265,194,34,2,2499.99),(266,195,41,2,1299.99),(267,196,34,1,2499.99),(268,197,41,1,1299.99),(269,198,34,2,2499.99),(270,199,34,2,2499.99),(271,200,34,1,2499.99),(272,201,17,2,122.00),(273,202,20,1,1.00),(274,205,21,2,1.00),(275,206,23,4,1299.99),(276,207,47,2,499.00);
/*!40000 ALTER TABLE `ordered_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `total_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `orders_chk_1` CHECK ((`total_price` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (98,899.00,'2026-01-31 11:21:52'),(99,6999.98,'2026-01-31 12:31:59'),(100,4999.98,'2026-01-31 13:23:59'),(101,7499.97,'2026-01-31 13:36:56'),(102,1299.99,'2026-01-31 13:39:03'),(103,799.00,'2026-01-31 13:39:05'),(104,1899.99,'2026-01-31 13:39:07'),(105,5099.97,'2026-01-31 13:42:29'),(106,3197.99,'2026-01-31 13:42:32'),(107,2499.99,'2026-02-01 10:39:21'),(108,5699.97,'2026-02-01 10:50:52'),(109,2499.99,'2026-02-01 11:54:06'),(110,10499.97,'2026-02-01 11:59:14'),(111,6098.98,'2026-02-01 12:54:23'),(112,5247.97,'2026-02-01 12:54:26'),(113,5697.97,'2026-02-01 12:54:30'),(114,7299.97,'2026-02-01 12:55:15'),(115,8897.96,'2026-02-01 12:55:20'),(116,5099.97,'2026-02-01 12:55:24'),(117,8249.96,'2026-02-01 12:55:33'),(118,2499.99,'2026-02-01 14:02:57'),(119,2499.99,'2026-02-01 14:04:16'),(120,3799.98,'2026-02-01 14:04:28'),(121,4048.98,'2026-02-02 10:58:53'),(122,2599.98,'2026-02-02 11:49:58'),(123,3499.99,'2026-02-02 11:50:44'),(124,1299.99,'2026-02-02 12:07:52'),(125,3499.99,'2026-02-02 12:32:39'),(126,1649.99,'2026-02-02 13:04:01'),(127,2599.98,'2026-02-02 13:05:00'),(128,2198.00,'2026-02-03 10:58:14'),(129,6945.97,'2026-02-03 11:01:50'),(130,2599.98,'2026-02-03 11:33:09'),(131,3698.98,'2026-02-03 11:34:40'),(132,3698.98,'2026-02-03 11:36:26'),(133,998.00,'2026-02-03 11:38:46'),(134,1899.99,'2026-02-03 11:39:04'),(135,4697.98,'2026-02-03 11:39:46'),(136,2599.98,'2026-02-03 11:41:22'),(137,2949.98,'2026-02-03 11:46:59'),(138,1299.99,'2026-02-03 11:48:21'),(139,1299.99,'2026-02-03 11:55:05'),(140,2398.99,'2026-02-03 11:55:43'),(141,2599.98,'2026-02-03 11:57:17'),(142,2599.98,'2026-02-03 12:00:14'),(143,3797.99,'2026-02-03 12:00:22'),(144,3799.98,'2026-02-03 12:02:02'),(145,1099.00,'2026-02-03 12:11:42'),(146,2599.98,'2026-02-03 12:35:23'),(147,1898.00,'2026-02-03 14:23:22'),(148,2198.00,'2026-02-03 14:23:53'),(149,2198.00,'2026-02-04 13:38:26'),(150,9194.92,'2026-02-04 13:49:33'),(151,1389.98,'2026-02-04 17:27:09'),(152,1999.98,'2026-02-08 11:59:32'),(153,7499.97,'2026-02-08 12:37:28'),(154,602.97,'2026-02-08 12:53:22'),(155,10499.97,'2026-02-08 13:13:39'),(156,6999.98,'2026-02-08 13:16:44'),(157,5999.98,'2026-02-09 10:39:53'),(158,3594.98,'2026-02-10 10:02:36'),(159,2599.98,'2026-02-10 10:43:48'),(160,4999.98,'2026-02-11 11:36:31'),(161,4999.98,'2026-02-11 11:55:45'),(162,3799.98,'2026-02-11 12:54:58'),(163,4999.98,'2026-02-11 12:55:26'),(164,1598.00,'2026-02-11 13:06:57'),(165,1099.00,'2026-02-11 13:07:48'),(167,1899.99,'2026-02-21 11:57:29'),(168,3499.99,'2026-02-21 11:58:24'),(169,5.00,'2026-03-02 08:52:22'),(170,4298.98,'2026-03-05 12:06:20'),(171,2499.99,'2026-03-05 12:08:48'),(172,4999.98,'2026-03-07 09:30:29'),(173,3299.98,'2026-03-09 12:39:14'),(174,6999.98,'2026-03-10 09:41:44'),(175,2499.99,'2026-03-10 09:55:25'),(176,3299.98,'2026-03-13 16:37:49'),(177,1649.99,'2026-03-13 16:37:58'),(178,1598.00,'2026-03-13 16:46:14'),(179,799.00,'2026-03-15 10:57:38'),(180,1898.00,'2026-03-15 10:57:48'),(181,10499.97,'2026-03-15 11:32:45'),(182,799.00,'2026-03-15 11:33:02'),(183,4999.98,'2026-03-17 11:11:48'),(184,3799.98,'2026-03-24 12:55:06'),(185,4999.98,'2026-03-24 12:55:54'),(186,6999.98,'2026-03-24 12:59:17'),(187,6999.98,'2026-03-24 13:00:59'),(188,3499.99,'2026-03-24 13:01:10'),(189,799.00,'2026-03-24 13:01:22'),(190,417.87,'2026-03-25 11:42:36'),(191,1799.98,'2026-03-28 13:02:42'),(192,499.00,'2026-03-28 13:02:55'),(193,2599.98,'2026-03-28 13:11:07'),(194,4999.98,'2026-03-28 13:11:40'),(195,2599.98,'2026-03-28 13:23:20'),(196,2499.99,'2026-03-28 13:23:26'),(197,1299.99,'2026-03-28 13:25:47'),(198,4999.98,'2026-04-05 12:52:54'),(199,4999.98,'2026-04-07 15:44:12'),(200,2499.99,'2026-04-09 10:49:57'),(201,244.00,'2026-04-09 13:06:54'),(202,1.00,'2026-04-09 13:07:00'),(205,2.00,'2026-04-09 13:09:25'),(206,5199.96,'2026-04-09 13:38:40'),(207,998.00,'2026-04-09 14:08:31');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_permission`
--

DROP TABLE IF EXISTS `page_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `page_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `page_key` varchar(100) DEFAULT NULL,
  `permission_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `page_key` (`page_key`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `page_permission_ibfk_1` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_permission`
--

LOCK TABLES `page_permission` WRITE;
/*!40000 ALTER TABLE `page_permission` DISABLE KEYS */;
INSERT INTO `page_permission` VALUES (1,'products',2),(2,'orders',NULL),(3,'categories',3),(4,'payments',1),(5,'settings',1);
/*!40000 ALTER TABLE `page_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `order_price` decimal(10,2) NOT NULL,
  `method` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `paid_price` varchar(20) DEFAULT NULL,
  `money_left` int DEFAULT NULL,
  `first_paid_price` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_order` (`order_id`),
  CONSTRAINT `fk_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,109,2499.99,'Cash',NULL,NULL,NULL,NULL),(2,110,10499.97,'Cash','Paid',NULL,NULL,NULL),(3,111,6098.98,'Cash','Paid',NULL,NULL,NULL),(4,112,5247.97,'Cash','Paid',NULL,NULL,NULL),(5,113,5697.97,'Cash','Paid',NULL,NULL,NULL),(6,114,7299.97,'Cash','Paid',NULL,NULL,NULL),(7,117,8249.96,'Cash','Paid',NULL,NULL,NULL),(8,118,2499.99,'Cash','Paid',NULL,NULL,NULL),(9,119,2499.99,'Cash','Paid',NULL,NULL,NULL),(10,120,3799.98,'Cash','Paid',NULL,NULL,NULL),(11,116,5099.97,'Cash','Paid',NULL,NULL,NULL),(12,115,8897.96,'Cash','Paid',NULL,NULL,NULL),(13,121,4048.98,'Cash','Paid',NULL,NULL,NULL),(14,122,2599.98,'Cash','Partially Paid','100',NULL,NULL),(15,123,3499.99,'Cash','Paid','3500',0,NULL),(16,124,1299.99,'Cash','Partially Paid','22',1278,NULL),(17,124,1299.99,'Cash','Partially Paid','1100',178,NULL),(18,124,1299.99,'Cash','Paid','178',0,NULL),(19,125,3499.99,'Cash','Partially Paid','2500',1000,NULL),(20,125,3499.99,'Cash','Paid','1000',0,NULL),(21,128,2198.00,'Cash','Paid','2198',0,NULL),(22,129,6945.97,'Cash','Paid','65765',0,NULL),(23,127,2599.98,'Cash','Partially Paid','2599',1,NULL),(24,127,2599.98,'Cash','Paid','1',0,NULL),(25,126,1649.99,'Cash','Paid','1650',0,NULL),(26,122,2599.98,'Cash','Partially Paid','0',2500,NULL),(27,122,2599.98,'Cash','Partially Paid','0',2500,NULL),(28,130,2599.98,'Cash','Partially Paid','2000',600,NULL),(29,130,2599.98,'Cash','Partially Paid','0',600,NULL),(30,130,2599.98,'Cash','Paid','600',0,NULL),(31,131,3698.98,'Cash','Partially Paid','67',3632,NULL),(32,131,3698.98,'Cash','Partially Paid','0',3632,NULL),(33,131,3698.98,'Cash','Paid','3632',0,NULL),(34,132,3698.98,'Cash','Partially Paid','3698',1,NULL),(35,132,3698.98,'Cash','Paid','1',0,NULL),(36,133,998.00,'Cash','Paid','999',0,NULL),(37,134,1899.99,'Cash','Partially Paid','1899',1,NULL),(38,134,1899.99,'Cash','Paid','1',0,NULL),(39,135,4697.98,'Cash','Paid','4698',0,NULL),(40,137,2949.98,'Cash','Paid','2950',0,NULL),(41,136,2599.98,'Cash','Paid','2600',0,NULL),(42,138,1299.99,'Cash','Paid','1300',0,NULL),(43,139,1299.99,'Cash','Paid','1300',0,NULL),(44,122,2599.98,'Cash','Paid','2500',0,NULL),(45,140,2398.99,'Cash','Paid','2399',0,NULL),(46,141,2599.98,'Cash','Paid','2600',0,NULL),(47,142,2599.98,'Cash','Paid','2600',0,NULL),(48,143,3797.99,'Cash','Paid','3798',0,NULL),(49,144,3799.98,'Cash','Partially Paid','82',3718,NULL),(50,144,3799.98,'Cash','Paid','3718',0,NULL),(51,145,1099.00,'Cash','Partially Paid','100',999,NULL),(52,146,2599.98,'Cash','Partially Paid','98',2502,NULL),(53,147,1898.00,'Cash','Paid','1899',0,NULL),(54,148,2198.00,'Cash','Paid','2199',0,NULL),(55,150,9194.92,'Cash','Partially Paid','1211',7984,NULL),(56,151,1389.98,'Cash','Paid','1390',0,NULL),(57,150,9194.92,'Cash','Paid','7984',0,NULL),(58,149,2198.00,'Cash','Partially Paid','2192',6,NULL),(59,149,2198.00,'Cash','Paid','121212',0,NULL),(60,153,7499.97,'Cash','Paid','7500',0,NULL),(61,152,1999.98,'Cash','Paid','2000',0,NULL),(62,156,6999.98,'Cash','Partially Paid','443',6557,NULL),(63,156,6999.98,'Cash','Paid','6557',0,NULL),(64,157,5999.98,'Cash','Paid','6000',0,NULL),(65,158,3594.98,'Cash','Paid','3595',0,NULL),(66,159,2599.98,'Cash','Partially Paid','123',2477,NULL),(67,159,2599.98,'Cash','Partially Paid','977',1500,NULL),(68,159,2599.98,'Cash','Partially Paid','100',1400,NULL),(69,159,2599.98,'Cash','Partially Paid','100',1300,NULL),(70,159,2599.98,'Cash','Partially Paid','200',1100,NULL),(71,154,602.97,'Cash','Paid','603',0,NULL),(72,154,602.97,'Cash','Paid','603',0,NULL),(73,155,10499.97,'Cash','Paid','10500',0,NULL),(74,159,2599.98,'Cash','Paid','2600',0,NULL),(75,160,4999.98,'Cash','Partially Paid','2500',2500,NULL),(76,160,4999.98,'Cash','Paid','2500',0,NULL),(77,161,4999.98,'Cash','Partially Paid','2300',2700,NULL),(78,161,4999.98,'Cash','Partially Paid','200',2500,NULL),(79,161,4999.98,'Cash','Paid','2500',0,NULL),(80,162,3799.98,'Cash','Partially Paid','87',3713,NULL),(81,162,3799.98,'Cash','Paid','3713',0,NULL),(82,163,4999.98,'Cash','Paid','5000',0,NULL),(83,164,1598.00,'Cash','Partially Paid','200',1398,NULL),(84,164,1598.00,'Cash','Partially Paid','189',1209,NULL),(85,164,1598.00,'Cash','Partially Paid','89',1120,NULL),(86,168,3499.99,'Cash','Paid','3500',0,NULL),(87,170,4298.98,'Cash','Paid','4299',0,NULL),(88,167,1899.99,'Cash','Paid','1900',0,NULL),(89,169,5.00,'Cash','Paid','6',0,NULL),(90,171,2499.99,'Cash','Paid','2500',0,NULL),(91,174,6999.98,'Cash','Paid','7000',0,NULL),(92,175,2499.99,'Cash','Paid','2500',0,NULL),(93,180,1898.00,'Cash','Partially Paid','787',1111,NULL),(94,181,10499.97,'Cash','Paid','10500',0,NULL),(95,182,799.00,'Cash','Partially Paid','200',599,NULL),(96,183,4999.98,'Cash','Paid','5000',0,NULL),(97,180,1898.00,'Cash','Paid','1111',0,NULL),(98,182,799.00,'Cash','Paid','599',0,NULL),(99,178,1598.00,'Cash','Paid','1599',0,NULL),(100,177,1649.99,'Cash','Paid','1650',0,NULL),(101,179,799.00,'Cash','Partially Paid','322',477,NULL),(102,179,799.00,'Cash','Partially Paid','233',244,NULL),(103,179,799.00,'Cash','Partially Paid','233',11,NULL),(104,176,3299.98,'Cash','Partially Paid','332',2968,NULL),(105,176,3299.98,'Cash','Partially Paid','0',2968,NULL),(106,176,3299.98,'Cash','Partially Paid','0',2968,NULL),(107,176,3299.98,'Cash','Paid','2968',0,NULL),(108,179,799.00,'Cash','Paid','3300',0,NULL),(109,172,4999.98,'Cash','Partially Paid','800',4200,NULL),(110,172,4999.98,'Cash','Paid','35453453',0,NULL),(111,184,3799.98,'Cash','Partially Paid','0',3800,NULL),(112,184,3799.98,'Cash','Partially Paid','3799',1,NULL),(113,184,3799.98,'Cash','Paid','11',0,NULL),(114,197,1299.99,'Cash','Paid','12122',0,NULL),(115,195,2599.98,'Cash','Partially Paid','0',2600,NULL),(116,195,2599.98,'Cash','Paid','777667766776677',0,NULL),(117,194,4999.98,'Cash','Paid','9899',0,NULL),(118,198,4999.98,'Cash','Partially Paid','0',5000,NULL),(119,198,4999.98,'Cash','Paid','23423',0,NULL),(120,199,4999.98,'Cash','Partially Paid','0',5000,NULL),(121,199,4999.98,'Cash','Partially Paid','1500',3500,NULL),(122,200,2499.99,'Cash','Paid','2342342342342342144',0,NULL),(123,199,4999.98,'Cash','Paid','3500',0,NULL),(124,207,998.00,'Cash','Partially Paid','200',798,NULL);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `permission` varchar(40) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`permission`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES (3,'can edit categories'),(2,'can edit products'),(1,'is admin');
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `storage_quantity` int DEFAULT '0',
  `is_archived` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `image_url` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pagination` (`is_archived`,`id` DESC),
  CONSTRAINT `product_chk_1` CHECK ((`price` > 0)),
  CONSTRAINT `product_chk_2` CHECK ((`storage_quantity` >= 0)),
  CONSTRAINT `product_chk_3` CHECK ((`is_archived` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=191 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'Derby',1.00,11,1,'2025-12-19 06:21:47',NULL),(2,'Noodles',2.00,0,1,'2025-12-19 09:48:32',NULL),(3,'Noodles',2.00,0,1,'2025-12-19 09:49:46',NULL),(4,'Derby',1.00,5,1,'2025-12-22 09:56:31',NULL),(5,'test',1.00,19,1,'2025-12-26 07:44:26',NULL),(6,'Test',1.00,0,1,'2025-12-26 09:37:42',NULL),(7,'Test',1.00,5,1,'2025-12-26 09:57:08',NULL),(8,'Test',1.00,11,1,'2025-12-26 10:00:11',NULL),(9,'dfhbdfgbh',4444.00,26,1,'2025-12-26 10:30:54',NULL),(10,'dfhbdfgbh',4444.00,29,1,'2025-12-26 10:35:45',NULL),(11,'dfhbdfgbh',4444.00,33,1,'2025-12-26 10:40:55',NULL),(12,'xcvb ',343.00,33,1,'2025-12-26 10:44:29',NULL),(13,'xcvb ',343.00,33,1,'2025-12-26 10:45:23',NULL),(14,'xcvb ',343.00,13,1,'2025-12-26 10:45:29',NULL),(15,'Test',122.00,200,1,'2025-12-29 18:34:27',NULL),(16,'ds',22.00,1,1,'2025-12-29 18:35:00',NULL),(17,'ImageTest',122.00,197,1,'2025-12-29 18:36:15','http://127.0.0.1:5000/api/uploads/products/25312b028f1c4f16ae09f41507154871.png'),(18,'dsfsdf',221.00,2,1,'2026-01-01 11:25:25',NULL),(19,'test',12.00,22,1,'2026-01-01 11:32:50',NULL),(20,'test image koby',1.00,10,1,'2026-01-01 16:14:58','http://127.0.0.1:5000/api/uploads/products/af1bb830226f464db40f5e9006e0ad90.png'),(21,'test image hamza',1.00,898,1,'2026-01-01 16:16:25','http://127.0.0.1:5000/api/uploads/products/fba6028b838b424180c831c1c3c69ae4.png'),(22,'je veux',12.00,19,1,'2026-01-02 04:18:35','http://127.0.0.1:5000/api/uploads/products/329541fe35fa4a6eabfb44711b83c952.png'),(23,'iPhone 15 Pro Max',1299.99,41,1,'2026-01-02 09:42:52',NULL),(24,'iPhone 15 Pro',999.99,52,1,'2026-01-02 09:42:52',NULL),(25,'iPhone 15',799.99,57,1,'2026-01-02 09:42:52',NULL),(26,'iPhone 14',699.99,34,1,'2026-01-02 09:42:52',NULL),(27,'Samsung Galaxy S24 Ultra',1199.99,24,1,'2026-01-02 09:42:52',NULL),(28,'Samsung Galaxy S24+',999.99,41,1,'2026-01-02 09:42:52',NULL),(29,'Samsung Galaxy S24',799.99,56,1,'2026-01-02 09:42:52',NULL),(30,'Google Pixel 8 Pro',999.00,27,1,'2026-01-02 09:42:52',NULL),(31,'Google Pixel 8',699.00,43,1,'2026-01-02 09:42:52',NULL),(32,'OnePlus 12',799.99,33,1,'2026-01-02 09:42:52',NULL),(33,'Apple MacBook Pro 16\" M3 Max',3499.99,39,0,'2026-01-02 09:42:52','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161241/412423-15-to-16-inch-laptops-apple-macbook-pro-16-14-core-m3-max-1tb-10037403_mkbkjz.png'),(34,'Apple MacBook Pro 14\" M3 Pro',2499.99,84,0,'2026-01-02 09:42:52','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161254/AppleM2_919c0df4-dbfb-4f37-b6c0-b243df947506.png_cideie.webp'),(35,'Apple MacBook Air 15\" M2',1299.99,5,0,'2026-01-02 09:42:52',NULL),(36,'Apple MacBook Air 13\" M2',999.99,49,1,'2026-01-02 09:42:52',NULL),(37,'Dell XPS 15 OLED',1899.99,0,0,'2026-01-02 09:42:52','http://res.cloudinary.com/df3uhshzy/image/upload/v1771048693/images-3_ryz0vu.jpg'),(38,'Dell XPS 13',1199.99,41,1,'2026-01-02 09:42:52',NULL),(39,'HP Spectre x360 14',1399.99,27,1,'2026-01-02 09:42:52',NULL),(40,'Lenovo ThinkPad X1 Carbon',1649.99,19,0,'2026-01-02 09:42:52',NULL),(41,'Microsoft Surface Laptop 5',1299.99,13,0,'2026-01-02 09:42:52',NULL),(42,'ASUS ROG Zephyrus G14',1599.99,18,1,'2026-01-02 09:42:52',NULL),(43,'iPad Pro 12.9\" M2',1099.00,1,0,'2026-01-02 09:42:52',NULL),(44,'iPad Pro 11\" M2',799.00,22,0,'2026-01-02 09:42:52',NULL),(45,'iPad Air (5th Generation)',749.99,36,0,'2026-01-02 09:42:52',NULL),(46,'iPad (10th Generation)',449.00,53,0,'2026-01-02 09:42:52',NULL),(47,'iPad mini 6',499.00,19,0,'2026-01-02 09:42:52',NULL),(48,'Samsung Galaxy Tab S9 Ultra',1199.99,16,1,'2026-01-02 09:42:52',NULL),(49,'Samsung Galaxy Tab S9+',899.99,18,0,'2026-01-02 09:42:52',NULL),(50,'Microsoft Surface Pro 9',999.99,29,0,'2026-01-02 09:42:52',NULL),(51,'Amazon Fire HD 10',149.99,88,0,'2026-01-02 09:42:52',NULL),(52,'Lenovo Tab P12 Pro',899.99,20,0,'2026-01-02 09:42:52',NULL),(53,'Sony WH-1000XM5 Headphones',399.99,66,0,'2026-01-02 09:42:52',NULL),(54,'Apple AirPods Pro (2nd Gen)',249.99,88,0,'2026-01-02 09:42:52',NULL),(55,'Apple AirPods Max',549.00,34,0,'2026-01-02 09:42:52',NULL),(56,'Apple AirPods (3rd Gen)',169.00,72,0,'2026-01-02 09:42:52',NULL),(57,'Bose QuietComfort Ultra',429.00,28,0,'2026-01-02 09:42:52',NULL),(58,'Bose QuietComfort 45',329.00,42,0,'2026-01-02 09:42:52',NULL),(59,'Sony WF-1000XM5 Earbuds',299.99,51,0,'2026-01-02 09:42:52',NULL),(60,'Sennheiser Momentum 4',349.95,36,0,'2026-01-02 09:42:52',NULL),(61,'Beats Studio Pro',349.99,44,0,'2026-01-02 09:42:52',NULL),(62,'JBL Flip 6 Bluetooth Speaker',129.95,68,0,'2026-01-02 09:42:52',NULL),(63,'PlayStation 5 Console',499.99,15,0,'2026-01-02 09:42:52',NULL),(64,'Xbox Series X',499.99,22,0,'2026-01-02 09:42:52',NULL),(65,'Xbox Series S',299.99,38,0,'2026-01-02 09:42:52',NULL),(66,'Nintendo Switch OLED',349.99,29,0,'2026-01-02 09:42:52',NULL),(67,'Nintendo Switch',299.99,42,0,'2026-01-02 09:42:52',NULL),(68,'Steam Deck 512GB',649.99,18,0,'2026-01-02 09:42:52',NULL),(69,'Logitech G Pro X Gaming Headset',129.99,55,0,'2026-01-02 09:42:52',NULL),(70,'Razer BlackWidow V4 Keyboard',189.99,33,0,'2026-01-02 09:42:52',NULL),(71,'Logitech G502 X Gaming Mouse',79.99,62,0,'2026-01-02 09:42:52',NULL),(72,'DualSense Edge Wireless Controller',199.99,41,0,'2026-01-02 09:42:52',NULL),(73,'Amazon Echo Dot (5th Gen)',49.99,156,0,'2026-01-02 09:42:52',NULL),(74,'Amazon Echo Show 10',249.99,38,0,'2026-01-02 09:42:52',NULL),(75,'Google Nest Hub (2nd Gen)',99.99,67,0,'2026-01-02 09:42:52',NULL),(76,'Google Nest Doorbell',179.99,42,0,'2026-01-02 09:42:52',NULL),(77,'Ring Video Doorbell Pro 2',249.99,31,0,'2026-01-02 09:42:52',NULL),(78,'Apple HomePod (2nd Gen)',299.00,27,0,'2026-01-02 09:42:52',NULL),(79,'Apple HomePod mini',99.00,84,0,'2026-01-02 09:42:52',NULL),(80,'Philips Hue Starter Kit',199.99,52,0,'2026-01-02 09:42:52',NULL),(81,'Nest Learning Thermostat',249.99,37,1,'2026-01-02 09:42:52',NULL),(82,'Eero Pro 6E Mesh WiFi',399.99,26,1,'2026-01-02 09:42:52',NULL),(83,'Apple Watch Series 9',399.00,58,0,'2026-01-02 09:42:52',NULL),(84,'Apple Watch Ultra 2',799.00,24,0,'2026-01-02 09:42:52',NULL),(85,'Apple Watch SE (2nd Gen)',249.00,72,0,'2026-01-02 09:42:52',NULL),(86,'Samsung Galaxy Watch 6 Classic',399.99,36,0,'2026-01-02 09:42:52',NULL),(87,'Fitbit Charge 6',159.95,89,0,'2026-01-02 09:42:52',NULL),(88,'Garmin Forerunner 265',449.99,31,0,'2026-01-02 09:42:52',NULL),(89,'Oculus Quest 3',499.99,19,0,'2026-01-02 09:42:52',NULL),(90,'Meta Quest 2',299.99,45,0,'2026-01-02 09:42:52',NULL),(91,'Whoop 4.0 Fitness Tracker',299.00,42,0,'2026-01-02 09:42:52',NULL),(92,'Amazfit GTR 4',199.99,53,0,'2026-01-02 09:42:52',NULL),(93,'Sony Alpha 7 IV Camera',2499.99,12,0,'2026-01-02 09:42:52',NULL),(94,'Canon EOS R5',3899.00,8,0,'2026-01-02 09:42:52',NULL),(95,'Fujifilm X-T5',1699.00,16,0,'2026-01-02 09:42:52',NULL),(96,'GoPro HERO12 Black',399.99,23,0,'2026-01-02 09:42:52',NULL),(97,'DJI Mini 4 Pro Drone',759.00,27,0,'2026-01-02 09:42:52',NULL),(98,'DJI Osmo Pocket 3',669.00,31,0,'2026-01-02 09:42:52',NULL),(99,'Insta360 X3',449.99,34,0,'2026-01-02 09:42:52',NULL),(100,'Sony ZV-E10 Vlogging Camera',799.99,41,0,'2026-01-02 09:42:52',NULL),(101,'Canon PowerShot G7 X III',749.99,38,0,'2026-01-02 09:42:52',NULL),(102,'Nikon Z fc',999.95,25,0,'2026-01-02 09:42:52',NULL),(103,'NVIDIA GeForce RTX 4090',1599.99,9,0,'2026-01-02 09:42:52',NULL),(104,'NVIDIA GeForce RTX 4080',1199.99,14,0,'2026-01-02 09:42:52',NULL),(105,'AMD Radeon RX 7900 XTX',999.99,18,0,'2026-01-02 09:42:52',NULL),(106,'Intel Core i9-14900K',589.99,31,0,'2026-01-02 09:42:52',NULL),(107,'AMD Ryzen 9 7950X',699.99,28,0,'2026-01-02 09:42:52',NULL),(108,'Corsair Vengeance DDR5 32GB',124.99,76,0,'2026-01-02 09:42:52',NULL),(109,'Samsung 980 Pro 2TB SSD',159.99,88,0,'2026-01-02 09:42:52',NULL),(110,'WD Black SN850X 2TB SSD',149.99,92,0,'2026-01-02 09:42:52',NULL),(111,'ASUS ROG Strix B650E-F Motherboard',349.99,41,0,'2026-01-02 09:42:52',NULL),(112,'Corsair RM850x Power Supply',149.99,56,0,'2026-01-02 09:42:52',NULL),(113,'Samsung Odyssey G9 49\"',1299.99,17,0,'2026-01-02 09:42:52',NULL),(114,'LG UltraGear 45\" OLED',1699.99,12,0,'2026-01-02 09:42:52',NULL),(115,'Dell UltraSharp U2723QE',699.99,38,0,'2026-01-02 09:42:52',NULL),(116,'Apple Studio Display',1599.00,22,1,'2026-01-02 09:42:52',NULL),(117,'ASUS ProArt PA329CV',899.99,26,0,'2026-01-02 09:42:52',NULL),(118,'Alienware AW3423DWF',999.99,19,0,'2026-01-02 09:42:52',NULL),(119,'Samsung M8 Smart Monitor',699.99,31,1,'2026-01-02 09:42:52',NULL),(120,'LG 27GP850-B',449.99,47,1,'2026-01-02 09:42:52',NULL),(121,'MSI MAG 274QRF-QD',399.99,53,1,'2026-01-02 09:42:52',NULL),(122,'Gigabyte M32U',749.99,24,0,'2026-01-02 09:42:52',NULL),(123,'TP-Link Deco XE75 Mesh System',299.99,62,0,'2026-01-02 09:42:52',NULL),(124,'NETGEAR Nighthawk RAXE300',449.99,26,0,'2026-01-02 09:42:52',NULL),(125,'ASUS ROG Rapture GT-AXE16000',699.99,16,0,'2026-01-02 09:42:52',NULL),(126,'Ubiquiti UniFi Dream Machine',299.00,34,0,'2026-01-02 09:42:52',NULL),(127,'Synology DS923+ NAS',599.99,22,0,'2026-01-02 09:42:52',NULL),(128,'QNAP TS-464 NAS',549.99,26,0,'2026-01-02 09:42:52',NULL),(129,'Zyxel Multy X Mesh WiFi',199.99,58,0,'2026-01-02 09:42:52',NULL),(130,'Google Nest Wifi Pro',199.99,47,0,'2026-01-02 09:42:52',NULL),(131,'Linksys Velop AX4200',349.99,33,0,'2026-01-02 09:42:52',NULL),(132,'Arris Surfboard S33 Modem',199.99,42,0,'2026-01-02 09:42:52',NULL),(133,'Apple MagSafe Charger',39.00,156,0,'2026-01-02 09:42:52',NULL),(134,'Anker 737 Power Bank',149.99,88,0,'2026-01-02 09:42:52',NULL),(135,'Logitech MX Keys Keyboard',99.99,72,0,'2026-01-02 09:42:52',NULL),(136,'Logitech MX Master 3S Mouse',99.99,68,0,'2026-01-02 09:42:52',NULL),(137,'Samsung T7 Shield 2TB SSD',149.99,92,0,'2026-01-02 09:42:52',NULL),(138,'Apple Pencil (2nd Gen)',129.00,84,0,'2026-01-02 09:42:52',NULL),(139,'Samsung 45W Fast Charger',49.99,124,0,'2026-01-02 09:42:52',NULL),(140,'HyperDrive USB-C Hub',89.99,76,1,'2026-01-02 09:42:52',NULL),(141,'Belkin BoostCharge Pro 3-in-1',159.95,58,1,'2026-01-02 09:42:52',NULL),(142,'Corsair K100 RGB Keyboard',229.99,41,1,'2026-01-02 09:42:52',NULL),(143,'Amazon Kindle Paperwhite',139.99,78,1,'2026-01-02 09:42:52',NULL),(144,'Amazon Kindle Oasis',249.99,36,1,'2026-01-02 09:42:52',NULL),(145,'Amazon Kindle Scribe',339.99,28,1,'2026-01-02 09:42:52',NULL),(146,'Kobo Libra 2',179.99,42,1,'2026-01-02 09:42:52',NULL),(147,'Kobo Sage',259.99,26,1,'2026-01-02 09:42:52',NULL),(148,'PocketBook InkPad Color',299.99,24,1,'2026-01-02 09:42:52',NULL),(149,'Onyx Boox Note Air3',499.99,18,1,'2026-01-02 09:42:52',NULL),(150,'Nook GlowLight 4',149.99,46,1,'2026-01-02 09:42:52',NULL),(151,'Remarkable 2 Tablet',299.00,33,1,'2026-01-02 09:42:52',NULL),(152,'Supernote A5 X',419.00,27,1,'2026-01-02 09:42:52',NULL),(153,'test',11.00,222,1,'2026-01-02 14:08:26','http://127.0.0.1:5000/api/uploads/products/1af7cc3f154a4429b78389e4a11ce8d2.png'),(154,'Slave ',2.00,0,1,'2026-01-02 14:12:35','http://127.0.0.1:5000/api/uploads/products/dd814edd7fb846a0adf1ef4422bc8215.png'),(155,'Slave ',2.00,1,1,'2026-01-02 14:14:39','http://127.0.0.1:5000/api/uploads/products/6f3f517ab73148e0b5c3d38ab78d182c.heic'),(156,'hh',5.00,86,1,'2026-01-03 05:32:06',NULL),(157,'hello ',5.00,99,1,'2026-01-03 06:44:12','http://127.0.0.1:5000/api/uploads/products/9a278c1f8a1c4e8d9fdf572835c4a79c.png'),(158,'iPhone 16 plus',1100.00,18,1,'2026-01-03 07:21:59','http://127.0.0.1:5000/api/uploads/products/2308d4408cd44bb9a291f656fd46cc7e.png'),(159,'iPhone 16 plus',859.88,18,0,'2026-01-03 07:23:10','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161769/c6b445c1351f4fe29ad951cee1d8baa6_bwyu3h.jpg'),(160,'iPhone 15 pro max',1000.00,29,0,'2026-01-03 07:24:30','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161783/539dce9ae5c94679a9dcf388b4e2b3e2_jtr3rw.jpg'),(161,'iPhone 17 pro max',1399.00,0,0,'2026-01-03 07:24:59','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161795/6cf6b390729845ad9ff93e44deb13619_poqiqm.webp'),(162,'Samsung Galaxy S24 Ultra',1099.00,18,0,'2026-01-03 07:25:59','http://127.0.0.1:5000/api/uploads/products/ee42ba0497ab4f65b3adb06436d88b4d.jpg'),(163,'iPhone 15',899.00,24,0,'2026-01-03 07:26:35','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161805/742cd748c69b40678f7d74971e80aed6_qrpzuh.jpg'),(164,'Kobo Libra 2',179.00,20,0,'2026-01-03 07:28:37','http://127.0.0.1:5000/api/uploads/products/c812142e91ba45818608d3f5a1d75b5d.jpg'),(165,'Remarkable 2 Tablet',200.99,31,0,'2026-01-03 07:35:01','http://127.0.0.1:5000/api/uploads/products/619bc0c158024cc19b2ebe2b2aa509de.jpg'),(166,'Supernote A5 X2',417.87,38,0,'2026-01-03 07:37:00','http://127.0.0.1:5000/api/uploads/products/3ce371bab80d4d9eb0327deaf70cb6b2.webp'),(167,'Nook Glowlight 4 Plus',143.00,28,1,'2026-01-03 07:38:26','http://127.0.0.1:5000/api/uploads/products/a7ab55fbbcfa49169d29cc7b954327bb.jpg'),(168,'Google Pixel 8 Pro',999.99,18,0,'2026-01-03 07:40:05','http://127.0.0.1:5000/api/uploads/products/d8948df7606242df821ae308401cef44.webp'),(169,'Apple Studio Display',1599.99,2,0,'2026-01-03 07:41:40','http://res.cloudinary.com/df3uhshzy/image/upload/v1771161820/174cea659fba45be9dfe25c2539f74f7_ls632a.jpg'),(170,'test',22.00,2,1,'2026-01-03 10:27:36',NULL),(171,'jj',87.00,88,1,'2026-01-06 12:24:18',NULL),(172,'jj',87.00,88,1,'2026-01-06 12:25:22',NULL),(173,'ojnon',667.00,7,1,'2026-01-06 12:59:48',NULL),(174,'jnj',66.00,44,1,'2026-01-06 13:19:42',NULL),(175,'test',22.00,0,1,'2026-01-07 05:02:10','http://127.0.0.1:5000/api/uploads/products/b95f287830594140a410e472dcfa762f.jpg'),(176,'Test categories',22.00,12,1,'2026-01-14 05:45:14',NULL),(177,'1312',11.00,7,1,'2026-01-15 12:21:06',NULL),(179,'Test Product',19.99,50,1,'2026-01-15 12:27:45',NULL),(180,'tetafta',121.00,6,1,'2026-01-15 12:30:18',NULL),(181,'TEST LGGG',12.00,1111,1,'2026-01-15 13:05:17',NULL),(182,'newc orod 1',200.00,24,1,'2026-01-15 13:34:25','http://127.0.0.1:5000/api/uploads/products/89d6c03d54114236928303dbf9d9638b.webp'),(183,'v cx',34.00,0,1,'2026-01-16 07:17:58',NULL),(184,'test laptop and apple category',23.00,22,1,'2026-01-20 18:32:12',NULL),(185,'test_lenovo_delete_category',1212.00,23,1,'2026-01-21 12:34:40',NULL),(186,'test google laptops',564.00,6776,1,'2026-01-21 12:47:06',NULL),(187,'test laptops apple samsung lg',2323.00,22,1,'2026-01-22 06:54:11',NULL),(188,'iubiu',87.00,8,1,'2026-01-22 06:55:30',NULL),(189,'Wireless Mouse',35.99,50,0,'2026-03-02 08:52:22',NULL),(190,'hhh',12.00,121,1,'2026-03-27 11:24:50',NULL);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_category_rel`
--

DROP TABLE IF EXISTS `product_category_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_category_rel` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `product_category_rel_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  CONSTRAINT `product_category_rel_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_category_rel`
--

LOCK TABLES `product_category_rel` WRITE;
/*!40000 ALTER TABLE `product_category_rel` DISABLE KEYS */;
INSERT INTO `product_category_rel` VALUES (1,23,7),(3,24,7),(4,25,7),(5,26,7),(9,36,7),(10,43,7),(12,45,7),(13,46,7),(14,47,7),(15,54,7),(16,55,7),(17,56,7),(19,79,7),(20,83,7),(21,84,7),(22,85,7),(23,133,7),(24,138,7),(25,158,7),(31,118,24),(32,36,24),(36,125,24),(37,111,24),(38,42,24),(39,115,24),(40,38,24),(42,39,24),(43,40,24),(44,184,7),(45,184,24),(46,185,23),(47,186,17),(48,186,24),(49,187,24),(50,187,7),(51,187,15),(52,187,16),(53,188,17),(54,188,15),(55,188,19),(56,188,23),(57,188,18),(58,188,22),(59,188,20),(75,78,7),(76,41,24),(89,34,7),(90,34,24),(91,159,7),(92,160,7),(93,161,7),(94,163,7),(95,169,7),(109,37,24),(110,44,7),(111,33,7),(112,33,24),(113,35,7),(114,35,24);
/*!40000 ALTER TABLE `product_category_rel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'admin'),(41,'cashier'),(3,'manager');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permission_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
INSERT INTO `role_permission` VALUES (1,1),(1,2),(3,2),(41,2),(1,3),(3,3),(41,3);
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_phone_numbers`
--

DROP TABLE IF EXISTS `user_phone_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_phone_numbers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user` (`user_id`),
  CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_phone_numbers`
--

LOCK TABLES `user_phone_numbers` WRITE;
/*!40000 ALTER TABLE `user_phone_numbers` DISABLE KEYS */;
INSERT INTO `user_phone_numbers` VALUES (89,30,'987897987'),(90,30,'23423423223'),(91,30,'97865443324567'),(92,30,'+8765432345678'),(99,36,''),(100,36,''),(105,57,''),(106,57,''),(113,61,''),(114,61,'');
/*!40000 ALTER TABLE `user_phone_numbers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_email` (`email`),
  KEY `FK_user_role` (`role_id`),
  CONSTRAINT `FK_user_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (30,'hamzakkad@pos.com','$2b$12$skia8l0phA.nfFRrNH.n7.PF4zCsz874.ZgfF5Ttfp7JsYYLeoRsm','Hamza Al-Akkad',1),(36,'manager@pos.com','$2b$12$CnlubTHuM1ReH1QKX/37X.IEkPtdx1pqrCkhY.o6D5KD9C901frMq','manager',3),(57,'cashier@pos.com','$2b$12$p0K3mQ7sMZjfwZkviX0/M.C6y7NvWgmRPm.GP4cEvuLUlZBjUBBJK','Cashier',41),(61,'hamza@pos.com','$2b$12$WbrT8o7N7lHWCs0yL3JVWe8p0Z3UuDkMrNL7ZliN2KsBQymra5MXq','hamzakkad',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-02 14:03:09

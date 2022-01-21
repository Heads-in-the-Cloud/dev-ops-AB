-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: utopia
-- ------------------------------------------------------
-- Server version	8.0.26

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
-- Dumping data for table `airplane`
--

LOCK TABLES `airplane` WRITE;
/*!40000 ALTER TABLE `airplane` DISABLE KEYS */;
INSERT INTO `airplane` VALUES (5,1),(10,2),(4,3),(11,4),(1,5),(12,5),(2,6),(3,7),(7,9),(13,10),(15,10),(6,11),(9,12),(8,13),(14,14);
/*!40000 ALTER TABLE `airplane` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `airplane_type`
--

LOCK TABLES `airplane_type` WRITE;
/*!40000 ALTER TABLE `airplane_type` DISABLE KEYS */;
INSERT INTO `airplane_type` VALUES (1,130),(2,57),(3,45),(4,77),(5,89),(6,104),(7,73),(8,123),(9,95),(10,64),(11,89),(12,97),(13,72),(14,176),(15,129);
/*!40000 ALTER TABLE `airplane_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `airport`
--

LOCK TABLES `airport` WRITE;
/*!40000 ALTER TABLE `airport` DISABLE KEYS */;
INSERT INTO `airport` VALUES ('BER','Berlin'),('CXH','Vancouver'),('DFW','Dallas'),('HKG','Hong Kong'),('IAD','Washington DC'),('JFK','New York City'),('LAX','Los Angeles'),('MEX','Mexico City'),('MIA','Miami'),('PDX','Portland'),('PHX','Phoenix'),('RNO','Reno'),('SEA','Seattle'),('TYO','Tokyo'),('YBZ','Toronto');
/*!40000 ALTER TABLE `airport` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `booking`
--

LOCK TABLES `booking` WRITE;
/*!40000 ALTER TABLE `booking` DISABLE KEYS */;
INSERT INTO `booking` VALUES (1,1,'3d3fc466-b17d-4785-9373-4004d5f53be8'),(2,1,'b93fc0e0-c3ff-41f6-b564-744894e7d446'),(3,1,'d3ff8afd-8f30-4159-8c56-9d73fd85df7b'),(4,1,'cf1e5a66-ab18-492c-98db-ac97b6c6f097'),(5,1,'fc45dfef-8395-409b-9599-dfe92858b719'),(6,1,'845f4c4d-99f8-408d-8448-990b42b0f308'),(7,1,'46ff2ca8-b964-424d-9961-3920af9eb5b3'),(8,1,'237c7f83-db01-4358-a7b1-4a641fca6b78'),(9,1,'c31c4f93-bb9c-4197-8245-443a0b1786da'),(10,1,'913ec432-a188-4718-9bbd-74f68d50aad6'),(11,1,'064b0881-c90f-4f39-8154-de3b9a0fbca3'),(12,1,'afb84015-0426-4dfe-b5ba-a456b1e26456'),(13,1,'e721554f-3ffa-4289-acc6-56a827a2599d'),(14,1,'59e8a5e9-d39a-47c0-b40d-a7cfc07e741d'),(15,1,'93ab0091-d96a-4cce-b3d8-6989e80a8d6a'),(16,1,'5ef77274-0bb4-42df-a2a5-73e630b14811'),(17,1,'317efef5-72dd-4172-b298-7046f96c5e4a'),(18,1,'0413b400-fe00-479b-bed1-f36801c87966'),(19,1,'ff959df4-d449-4170-a6da-b28d70dad41f'),(20,1,'adf546ad-3db6-4b8b-97ed-f615dc3afcf1');
/*!40000 ALTER TABLE `booking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `booking_agent`
--

LOCK TABLES `booking_agent` WRITE;
/*!40000 ALTER TABLE `booking_agent` DISABLE KEYS */;
INSERT INTO `booking_agent` VALUES (1,1),(2,4),(3,5),(4,6),(10,9),(7,11),(8,13),(5,14),(6,17),(9,18);
/*!40000 ALTER TABLE `booking_agent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `booking_guest`
--

LOCK TABLES `booking_guest` WRITE;
/*!40000 ALTER TABLE `booking_guest` DISABLE KEYS */;
/*!40000 ALTER TABLE `booking_guest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `booking_payment`
--

LOCK TABLES `booking_payment` WRITE;
/*!40000 ALTER TABLE `booking_payment` DISABLE KEYS */;
INSERT INTO `booking_payment` VALUES (1,'card_pTtBPjz2SwhLCcQ583hBMSoC',0),(2,'card_ek8DC5tMMkFXZ4YBk42c9LD7',0),(3,'card_YCzklBxZ3KlmfXRQSAkCo5DE',0),(4,'card_4gn1yfYyNWyaFwsM6SzrmaXK',0),(5,'card_FbZ3ZjJLcfYfZZJA27VcZgpt',0),(6,'card_DHeitRDtFR6kwShS4bABY6Zh',0),(7,'card_ni4yRaIDdj5tCHfpjsteJpfA',0),(8,'card_BChqyjqL0rOatLIr8XlLhCMZ',0),(9,'card_KDDMtzzTt9a1bWf6sjegpbVb',0),(10,'card_dEEYLMhmYmzYJ6nFvbJ4ok5o',0),(11,'card_XmSCvr6l5JleV8PBFluUTKTW',0),(12,'card_5vhprlQIRofUU5oSc7xOndMa',0),(13,'card_GRVct1g9rxOCJZYKDw022t7j',0),(14,'card_CqqBWVOJOeBezVxoe97b0TWj',0),(15,'card_ZhkHjsCKy9a11wCKYrNKFXR1',0),(16,'card_hEcfNLSjZi8HIk10ixFOGZHh',0),(17,'card_MMZAfHd4ca9jeqpXvf3xnOFY',0),(18,'card_CSLSZx7kGC5gbmASeo71z9zU',0),(19,'card_bIMQfnVvqDmeNw0GAvBT3okX',0),(20,'card_JeEKa2T4VUPwuvZyHvLBuPEP',0);
/*!40000 ALTER TABLE `booking_payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `booking_user`
--

LOCK TABLES `booking_user` WRITE;
/*!40000 ALTER TABLE `booking_user` DISABLE KEYS */;
INSERT INTO `booking_user` VALUES (11,2),(12,3),(13,7),(14,8),(15,10),(16,12),(17,15),(18,16),(19,19),(20,20);
/*!40000 ALTER TABLE `booking_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `flight`
--

LOCK TABLES `flight` WRITE;
/*!40000 ALTER TABLE `flight` DISABLE KEYS */;
INSERT INTO `flight` VALUES (1,4,13,'2021-09-21 03:33:40',12,150.25),(2,6,4,'2021-09-22 06:04:12',5,200),(3,1,3,'2021-09-23 13:23:09',7,430.5),(4,9,12,'2021-09-24 10:16:23',2,500.75),(5,2,2,'2021-09-21 15:25:51',2,325.75),(6,2,1,'2021-09-22 16:54:32',1,400.5),(7,8,11,'2021-09-28 03:30:00',4,250),(8,2,5,'2021-09-28 15:45:00',3,200),(9,4,7,'2021-09-29 07:00:00',3,400),(10,1,3,'2021-09-29 18:15:00',2,300.25);
/*!40000 ALTER TABLE `flight` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `flight_bookings`
--

LOCK TABLES `flight_bookings` WRITE;
/*!40000 ALTER TABLE `flight_bookings` DISABLE KEYS */;
INSERT INTO `flight_bookings` VALUES (1,1),(1,2),(1,3),(1,4),(2,5),(2,6),(3,7),(4,8),(4,9),(4,10),(4,11),(4,12),(5,13),(5,14),(6,15),(6,16),(7,17),(9,18),(9,19),(10,20);
/*!40000 ALTER TABLE `flight_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `passenger`
--

LOCK TABLES `passenger` WRITE;
/*!40000 ALTER TABLE `passenger` DISABLE KEYS */;
INSERT INTO `passenger` VALUES (1,1,'Michaela','Mcdonald','1984-10-28','Female','9342 Cherry St.\nBerwyn, IL 60402'),(2,11,'Adah','Farrell','1939-09-17','Female','117 SW. Roehampton Ave.\nBlacksburg, VA 24060'),(3,12,'Darrell','Hill','1962-10-25','Male','798 Shub Farm Road\nHuntsville, AL 35803'),(4,2,'Travis','Johnston','1997-06-06','Male','755 Gonzales Dr.\nPataskala, OH 43062'),(5,3,'Alijah','Pitts','1996-04-02','Male','8779 Thorne Ave.\nKings Mountain, NC 28086'),(6,4,'Mac','Meyer','1973-07-27','Male','358 Lafayette Ave.\nOcoee, FL 34761'),(7,13,'Sammy','Hampton','1981-12-23','Other','58 Tarkiln Hill Lane\nDelaware, OH 43015'),(8,14,'Yoselin','Trujillo','1956-10-27','Female','603 Howard Lane\nHephzibah, GA 30815'),(9,5,'Jensen','Werner','1948-02-07','Male','619 NE. Walt Whitman Rd.\nFairmont, WV 26554'),(10,15,'Camren','West','1992-11-15','Male','69 Holly Street\nAliquippa, PA 15001'),(11,6,'Francisco','Ellis','1962-04-07','Male','542 Golden Star Drive\nBayside, NY 11361'),(12,16,'Matthew','Miller','1984-06-02','Other','8625 Campfire Road\nNew Kensington, PA 15068'),(13,7,'Kamryn','Anderson','1943-08-28','Male','9 Parker Rd.\nFort Mill, SC 29708'),(14,8,'John','Smith','1999-12-30','Male','1337 Forgotton Blvd. Boston, MA 80808'),(15,17,'Christina','Owens','1931-12-01','Female','58 Sutor Circle\nBay Shore, NY 11706'),(16,18,'Mitchell','Harvey','1962-03-22','Male','9784 Tailwater Rd.\nMoorhead, MN 56560'),(17,9,'Cason','Chambers','1950-10-14','Non-binary','22 Golf St.\nMaspeth, NY 11378'),(18,10,'Ariel','Mendez','1981-07-09','Female','97 West Delaware Lane\nBeltsville, MD 20705'),(19,19,'Neil','Rangel','1966-07-28','Male','537 Lexington St.\nElgin, IL 60120'),(20,20,'Drake','Swanson','1990-06-15','Male','9242 South Evergreen Dr.\nHarlingen, TX 78552');
/*!40000 ALTER TABLE `passenger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `route`
--

LOCK TABLES `route` WRITE;
/*!40000 ALTER TABLE `route` DISABLE KEYS */;
INSERT INTO `route` VALUES (1,'JFK','LAX'),(2,'CXH','YBZ'),(3,'YBZ','SEA'),(4,'MEX','BER'),(5,'RNO','PDX'),(6,'PHX','MIA'),(7,'TYO','JFK'),(8,'LAX','RNO'),(9,'PDX','LAX'),(10,'IAD','MIA'),(11,'HKG','TYO');
/*!40000 ALTER TABLE `route` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,1,'Alexander','Walter','awalter','jandrese@msn.com','$2a$12$rKnLAxDg2MFs7qwvoTEOeO2/vi3lK5ZgQL712Fjzv44NJE0RKUCNa','(445) 995-8776'),(2,2,'Adah','Farrell','afarrell','thowell@optonline.net','rCX1MEJlMX6NgJiR','(474) 442-5801'),(3,2,'Darrell','Hill','dhill','yfreund@msn.com','jo7rUz1k25lTl2Bm','(697) 523-2353'),(4,1,'Nella','Harbor','nharbor','doche@aol.com','KPh6pFCGrNMMC8DF','(208) 276-5733'),(5,1,'Leola','Welch','lwelch','gozer@yahoo.com','j0zcGLC9G6xxqEQ5','(427) 319-3337'),(6,1,'Randall','Hunt','rhunt','heine@aol.com','R3nnoH1o77QCGwUF','(362) 666-9750'),(7,2,'Sammy','Hampton','shampton','mstrout@hotmail.com','EhZo8PWjfNaAn8nG','(350) 613-2763'),(8,2,'Yoselin','Trujillo','ytrujillo','tfinniga@yahoo.com','quP2C5l36G9PAa7Q','(727) 934-5708'),(9,1,'Natalee','Alexander','nalexander','bdbrown@me.com','4i6zizS8r9c2yiNY','(289) 934-1373'),(10,2,'Camren','West','cwest','fviegas@mac.com','9h2Cam2neBjGD2zH','(319) 875-6907'),(11,1,'Caden','Bass','cbass','ajlitt@outlook.com','IejkRGgiHItrnlP8','(747) 662-9049'),(12,2,'Matthew','Miller','mmiller','jespley@verizon.net','PSxpwwlNwHP7SrIV','(470) 653-2765'),(13,1,'Madelyn','Miller','mmiller2','janneh@verizon.net','WMUn4FJKLeQj35kI','(331) 939-0691'),(14,1,'Keaton','Wilcox','kwilcox','emmanuel@aol.com','q08o5Z1PuKT5jkUe','(938) 930-0937'),(15,2,'Christina','Owens','cowens','chaffar@sbcglobal.net','MyFWuwHz8jEpYCYl','(204) 435-2863'),(16,2,'Mitchell','Harvey','mharvey','sassen@yahoo.com','DgOQUVBwOerKVOP8','(329) 529-2931'),(17,1,'Lea','Ward','lward','qmacro@gmail.com','XLMpkHaXlPTf7Tlu','(330) 712-3387'),(18,1,'Julissa','Tucker','jtucker','sburke@gmail.com','FUtgPGOabIKPtO5P','(439) 231-0047'),(19,2,'Neil','Rangel','nrangel','dhrakar@hotmail.com','Qnmwt8vzpfLZ07CN','(838) 625-6123'),(20,2,'Drake','Swanson','dswanson','chunzi@optonline.net','8hVINFqzRTTMikYJ','(900) 396-0382');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
INSERT INTO `user_role` VALUES (3,'Admin'),(1,'Employee'),(2,'Traveler');
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-01-02 17:52:52

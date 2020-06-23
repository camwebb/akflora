-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 23, 2020 at 10:14 AM
-- Server version: 10.4.13-MariaDB
-- PHP Version: 7.4.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tcm`
--

-- --------------------------------------------------------

--
-- Table structure for table `irank`
--

CREATE TABLE `irank` (
  `id` int(11) NOT NULL,
  `label` varchar(10) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `irank`
--

INSERT INTO `irank` (`id`, `label`) VALUES
(1, 'ssp.'),
(2, 'var.'),
(3, 'f.');

-- --------------------------------------------------------

--
-- Table structure for table `name`
--

CREATE TABLE `name` (
  `id` int(11) NOT NULL,
  `code` varchar(50) COLLATE utf8_bin NOT NULL,
  `pubID` int(11) NOT NULL,
  `genus` varchar(100) COLLATE utf8_bin NOT NULL,
  `species` varchar(100) COLLATE utf8_bin NOT NULL,
  `irankID` int(11) DEFAULT NULL,
  `infrasp` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `author` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `show` int(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `name`
--

INSERT INTO `name` (`id`, `code`, `pubID`, `genus`, `species`, `irankID`, `infrasp`, `author`, `url`, `notes`, `ts`, `show`) VALUES
(10, 'Claytonia arctica Adams', 18, 'Claytonia', 'arctica', NULL, NULL, 'Adams', 'https://biodiversitylibrary.org/page/10128719', NULL, '2020-06-23 16:41:32', 1),
(11, 'Claytonia porsildii Jurtz.', 17, 'Claytonia', 'porsildii', NULL, NULL, 'Jurtz.', NULL, 'Claytonia porsildii Jurtz.', '2020-06-23 16:41:32', 1),
(13, 'Montia scammaniana (Hultén) Welsh', 19, 'Montia', 'scammaniana', NULL, NULL, '(Hultén) Welsh', NULL, NULL, '2020-06-23 16:41:32', 1);

-- --------------------------------------------------------

--
-- Table structure for table `pub`
--

CREATE TABLE `pub` (
  `id` int(11) NOT NULL,
  `code` varchar(50) COLLATE utf8_bin NOT NULL,
  `cite` varchar(300) COLLATE utf8_bin DEFAULT NULL,
  `doi` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `pub`
--

INSERT INTO `pub` (`id`, `code`, `cite`, `doi`, `url`, `notes`, `ts`) VALUES
(15, 'Adams 1817', 'Adams, J. F. H. 1817. Mém. Soc. Imp. Naturalistes Moscou 5: 94. ', '', 'https://biodiversitylibrary.org/page/10128719', NULL, '2020-06-22 23:51:33'),
(16, 'Porsild 1974', 'Porsild, A. E. 1974. Publications in Botany. Canadian Museum of Nature', NULL, 'https://biodiversitylibrary.org/page/36177530', NULL, '2020-06-22 23:51:33'),
(17, 'Yurtsez 1981', 'Yurtsev, B. 1981. Bot. Zhurn. (Moscow & Leningrad) 66: 1043.', NULL, NULL, NULL, '2020-06-22 23:51:33'),
(18, 'Miller & Chambers 2006', 'Miller, J.M., Chambers, K.L. 2006. Systematics of Claytonia (Portulacaceae). Systematic Botany Monographs 78: 1-236.', NULL, NULL, NULL, '2020-06-22 23:51:33'),
(19, 'Welsh 1974', 'Welsh, S. 1974. Anderson\'s Flora of Alaska', NULL, NULL, NULL, '2020-06-22 23:56:14'),
(21, 'Cody 2000', 'Cody, W.J. 2000. Flora of the Yukon Territory.', NULL, NULL, NULL, '2020-06-23 03:00:46');

--
-- Triggers `pub`
--
DELIMITER $$
CREATE TRIGGER `pubinfo_i` BEFORE INSERT ON `pub` FOR EACH ROW BEGIN IF NEW.cite IS NULL AND NEW.doi IS NULL AND NEW.url IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add or update row: either cite or DOI or URL is needed'; END IF; END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `pubinfo_u` BEFORE UPDATE ON `pub` FOR EACH ROW BEGIN IF NEW.cite IS NULL AND NEW.doi IS NULL AND NEW.url IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add or update row: either cite or DOI or URL is needed'; END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `rel`
--

CREATE TABLE `rel` (
  `id` int(11) NOT NULL,
  `label` varchar(50) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `rel`
--

INSERT INTO `rel` (`id`, `label`) VALUES
(1, 'intersects'),
(2, 'is congruent with'),
(3, 'overlaps'),
(4, 'includes'),
(5, 'is included in'),
(6, 'is disjunct with');

-- --------------------------------------------------------

--
-- Table structure for table `syn`
--

CREATE TABLE `syn` (
  `id` int(11) NOT NULL,
  `label` varchar(30) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `syn`
--

INSERT INTO `syn` (`id`, `label`) VALUES
(1, 'same name as'),
(2, 'is synonym for'),
(3, 'has synonym'),
(4, 'is pro parte synonym for'),
(5, 'has pro parte synonym');

-- --------------------------------------------------------

--
-- Table structure for table `tc`
--

CREATE TABLE `tc` (
  `id` int(11) NOT NULL,
  `code` varchar(50) COLLATE utf8_bin NOT NULL,
  `nameID` int(11) NOT NULL,
  `pubID` int(11) NOT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `show` int(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `tc`
--

INSERT INTO `tc` (`id`, `code`, `nameID`, `pubID`, `notes`, `ts`, `show`) VALUES
(6, 'C. arctica sec Adams', 10, 15, NULL, '2020-06-23 16:41:32', 1),
(7, 'C. arctica sec Porsild', 10, 16, NULL, '2020-06-23 16:41:32', 1),
(8, 'C. porsildii sec. Yurtsev', 11, 17, NULL, '2020-06-23 16:41:32', 1),
(9, 'C. arctica sec. Welsh', 10, 19, NULL, '2020-06-23 16:41:32', 1),
(11, 'M. scammaniana sec. Cody', 13, 21, NULL, '2020-06-23 16:41:32', 1);

-- --------------------------------------------------------

--
-- Table structure for table `tcm`
--

CREATE TABLE `tcm` (
  `id` int(11) NOT NULL,
  `tc1ID` int(11) NOT NULL,
  `relID` int(11) NOT NULL,
  `synID` int(11) DEFAULT NULL,
  `tc2ID` int(11) NOT NULL,
  `pubID` int(11) NOT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `show` int(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `tcm`
--

INSERT INTO `tcm` (`id`, `tc1ID`, `relID`, `synID`, `tc2ID`, `pubID`, `notes`, `ts`, `show`) VALUES
(7, 7, 4, NULL, 6, 16, NULL, '2020-06-23 16:41:32', 1),
(8, 8, 5, NULL, 7, 17, NULL, '2020-06-23 16:41:32', 1),
(9, 8, 6, NULL, 6, 17, NULL, '2020-06-23 16:41:32', 1),
(15, 11, 1, 3, 7, 21, NULL, '2020-06-23 16:41:32', 1);

--
-- Triggers `tcm`
--
DELIMITER $$
CREATE TRIGGER `tc1_ne_tc2` BEFORE INSERT ON `tcm` FOR EACH ROW BEGIN
          IF NEW.tc1ID = NEW.tc2ID
          THEN
               SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot add or update row: tc1 must not equal tc2';
          END IF;
     END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tc1_ne_tc2_u` BEFORE UPDATE ON `tcm` FOR EACH ROW BEGIN IF NEW.tc1ID = NEW.tc2ID THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add or update row: tc1 must not equal tc2'; END IF; END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `irank`
--
ALTER TABLE `irank`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `name`
--
ALTER TABLE `name`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD UNIQUE KEY `genus` (`genus`,`species`,`author`),
  ADD KEY `pubID` (`pubID`),
  ADD KEY `irankID` (`irankID`);

--
-- Indexes for table `pub`
--
ALTER TABLE `pub`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `rel`
--
ALTER TABLE `rel`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `syn`
--
ALTER TABLE `syn`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tc`
--
ALTER TABLE `tc`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nameID_2` (`nameID`,`pubID`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `nameID` (`nameID`),
  ADD KEY `pubID` (`pubID`);

--
-- Indexes for table `tcm`
--
ALTER TABLE `tcm`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tc1ID_2` (`tc1ID`,`relID`,`tc2ID`),
  ADD KEY `tc1ID` (`tc1ID`),
  ADD KEY `relID` (`relID`),
  ADD KEY `tc2ID` (`tc2ID`),
  ADD KEY `pubID` (`pubID`),
  ADD KEY `synID` (`synID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `irank`
--
ALTER TABLE `irank`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `name`
--
ALTER TABLE `name`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `pub`
--
ALTER TABLE `pub`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `rel`
--
ALTER TABLE `rel`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `syn`
--
ALTER TABLE `syn`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tc`
--
ALTER TABLE `tc`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `tcm`
--
ALTER TABLE `tcm`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `name`
--
ALTER TABLE `name`
  ADD CONSTRAINT `name_ibfk_1` FOREIGN KEY (`pubID`) REFERENCES `pub` (`id`),
  ADD CONSTRAINT `name_ibfk_2` FOREIGN KEY (`irankID`) REFERENCES `irank` (`id`);

--
-- Constraints for table `tc`
--
ALTER TABLE `tc`
  ADD CONSTRAINT `tc_ibfk_1` FOREIGN KEY (`nameID`) REFERENCES `name` (`id`),
  ADD CONSTRAINT `tc_ibfk_2` FOREIGN KEY (`pubID`) REFERENCES `pub` (`id`);

--
-- Constraints for table `tcm`
--
ALTER TABLE `tcm`
  ADD CONSTRAINT `tcm_ibfk_1` FOREIGN KEY (`tc1ID`) REFERENCES `tc` (`id`),
  ADD CONSTRAINT `tcm_ibfk_2` FOREIGN KEY (`tc2ID`) REFERENCES `tc` (`id`),
  ADD CONSTRAINT `tcm_ibfk_3` FOREIGN KEY (`relID`) REFERENCES `rel` (`id`),
  ADD CONSTRAINT `tcm_ibfk_4` FOREIGN KEY (`pubID`) REFERENCES `pub` (`id`),
  ADD CONSTRAINT `tcm_ibfk_5` FOREIGN KEY (`synID`) REFERENCES `syn` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

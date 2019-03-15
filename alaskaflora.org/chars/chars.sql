
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `akchars`
--

-- --------------------------------------------------------

--
-- Table structure for table `chars`
--

CREATE TABLE `chars` (
  `id` int(11) NOT NULL,
  `char` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apw` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `flopo` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chars`
--

INSERT INTO `chars` (`id`, `char`, `state`, `notes`, `apw`, `flopo`) VALUES
(1, 'Leaf insertion', 'alternate', 'Leaves inserted on stem singly. Does not imply information about rotational symmetry (planar, spiral, etc); subopposite coded as alternate.', 'Leaf insertion : spiral, 2-ranked, 3-ranked', 'FLOPO_0001032 - leaf alternate placement'),
(2, 'Leaf insertion', 'opposite', 'Leaves inserted on stem in pairs, threesomes, etc. Included the term \"whorled\"', 'Leaf insertion : opposite', 'FLOPO_0000420 - leaf opposite'),
(3, 'Leaf margin', 'entire', 'Leaf margin smooth, with naked eye, and by running finger along margin', 'Blade margin : entire', 'FLOPO_0900073 - leaf margin entire'),
(4, 'Leaf margin', 'not entire', 'Any teeth on margin detectable by naked eye, or finger', 'Blade margin : toothed', NULL),
(5, 'Plant stem', 'caul.', 'Whole plant has a well-developed vegetative stem above ground. Not a character of the infl. Aka with cauline leaves.', NULL, 'FLOPO_0980079 - whole plant caulescent'),
(6, 'Plant stem', 'not caul.', 'Whole plant has no stem or caulis. May have very short stem concealed in the ground.', NULL, 'FLOPO_0980080 - whole plant acaulescent'),
(9, 'Plant habit', 'forb', NULL, NULL, 'FLOPO_0900037 - whole plant forbacious'),
(10, 'Plant habit', 'grass-like', NULL, NULL, 'FLOPO_0900036 - whole plant graminoid'),
(12, 'Plant habit', 'shrub', NULL, NULL, 'FLOPO_0900034 - whole plant frutescent'),
(13, 'Plant habit', 'tree', NULL, NULL, 'FLOPO_0900033 - whole plant arborescent'),
(14, 'Leaf form', 'simple', NULL, 'Leaf type : simple', 'FLOPO_0000693 - leaf simple'),
(15, 'Leaf form', 'trifoliate', 'poss later combine into compound', 'Leaf type : compound', 'FLOPO_0900067 - leaf trifoliolate'),
(16, 'Leaf form', 'pinnate', 'poss later combine into compound', 'Leaf type : compound', 'FLOPO_0907004 - leaf pinnately compound'),
(17, 'Leaf form', 'palmate', 'poss later combine into compound', 'Leaf type : compound', 'FLOPO_0900068 - leaf palmately compound'),
(18, 'Leaf venation', 'not parallel', 'Not parallel fine veins', NULL, NULL),
(19, 'Leaf venation', 'parallel', NULL, 'Lamina venation : parallel', 'FLOPO_0900072 - leaf vascular system parallel'),
(20, 'Flower symmetry', 'actin.', NULL, 'Flower symmetrym : polysymmetric', 'FLOPO_0009052 - corolla actinomorphic'),
(21, 'Flower symmetry', 'zygo.', NULL, 'Flower symmetry : monosymmetric', 'FLOPO_0004017 - corolla zygomorphic'),
(22, 'Ovary position', 'superior', NULL, 'Ovary Position : superior', 'n/a'),
(23, 'Ovary position', 'inferior', NULL, 'Ovary Position : inferior', 'n/a'),
(24, 'Ovary position', 'semi-inferior', NULL, 'Ovary Position : semi-inferior', 'n/a'),
(25, 'Flower color', 'white', NULL, 'n/a', 'FLOPO_0001722 - flower white'),
(26, 'Flower color', 'yellow', NULL, 'n/a', 'FLOPO_0004976 - flower yellow'),
(27, 'Flower color', 'orange', NULL, 'n/a', 'FLOPO_0018524 - flower orange'),
(28, 'Flower color', 'pink', NULL, 'n/a', 'FLOPO_0001659 - flower pink'),
(29, 'Flower color', 'red', NULL, 'n/a', 'FLOPO_0007599 - flower red'),
(30, 'Flower color', 'blue', NULL, 'n/a', 'FLOPO_0015261 - flower blue'),
(32, 'Flower color', 'purple', NULL, 'n/a', 'FLOPO_0001220 - flower purple'),
(33, 'Flower color', 'green', NULL, 'n/a', 'FLOPO_0004148 - flower green'),
(34, 'Flower color', 'brown', NULL, NULL, NULL),
(35, 'Fruit type', 'dry', NULL, NULL, NULL),
(36, 'Fruit type', 'fleshy', NULL, NULL, NULL),
(37, 'Inflor.', 'single flower', NULL, NULL, NULL),
(38, 'Inflor.', 'multiple flowers', NULL, NULL, NULL),
(39, 'Flower pedicel', 'yes', NULL, NULL, NULL),
(40, 'Flower pedicel', 'no', NULL, NULL, NULL),
(41, 'Flower color', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(42, 'Flower pedicel', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(43, 'Flower symmetry', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(44, 'Fruit type', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(45, 'Inflor.', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(46, 'Leaf form', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(47, 'Leaf insertion', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(48, 'Leaf margin', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(49, 'Leaf venation', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(50, 'Ovary position', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(51, 'Plant habit', 'X', 'Dummy state to store notes for a T x C', NULL, NULL),
(52, 'Plant stem', 'X', 'Dummy state to store notes for a T x C', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `taxa`
--

CREATE TABLE `taxa` (
  `id` int(11) NOT NULL,
  `fam` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `genID` int(11) DEFAULT NULL,
  `guid` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `syn` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tnote` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tnoteauth` enum('Brian','Cam','Steffi') COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `taxa`
--

INSERT INTO `taxa` (`id`, `fam`, `name`, `genID`, `guid`, `syn`, `tnote`, `tnoteauth`) VALUES
(1, 'Pinaceae', 'Abies', NULL, 'akg-1', NULL, NULL, NULL),
(2, 'Pinaceae', 'Abies amabilis Douglas ex J.Forbes', 1, 'ala-838', NULL, NULL, NULL),
(3, 'Pinaceae', 'Abies lasiocarpa (Hook.) Nutt.', 1, 'ala-2917', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `TxC`
--

CREATE TABLE `TxC` (
  `id` int(11) NOT NULL,
  `taxaID` int(11) NOT NULL,
  `charID` int(11) NOT NULL,
  `sources` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `person` enum('Brian','Cam','Steffi') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Brian'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `TxC`
--

INSERT INTO `TxC` (`id`, `taxaID`, `charID`, `sources`, `notes`, `timestamp`, `person`) VALUES
(1, 2, 32, 'hult, fna', 'bracts. FNA: Pollen cones at pollination red, becoming reddish yellow. Seed cones purple.', '2018-02-06 09:00:00', 'Brian'),
(2, 2, 1, 'fna', NULL, '2018-02-06 09:00:00', 'Brian');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chars`
--
ALTER TABLE `chars`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `char` (`char`,`state`);

--
-- Indexes for table `taxa`
--
ALTER TABLE `taxa`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `guid` (`guid`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `fam` (`fam`),
  ADD KEY `genID` (`genID`);

--
-- Indexes for table `TxC`
--
ALTER TABLE `TxC`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `TC` (`taxaID`,`charID`),
  ADD KEY `taxaID` (`taxaID`),
  ADD KEY `charID` (`charID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chars`
--
ALTER TABLE `chars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `taxa`
--
ALTER TABLE `taxa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `TxC`
--
ALTER TABLE `TxC`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `TxC`
--
ALTER TABLE `TxC`
  ADD CONSTRAINT `TxC_ibfk_2` FOREIGN KEY (`taxaID`) REFERENCES `taxa` (`id`),
  ADD CONSTRAINT `TxC_ibfk_3` FOREIGN KEY (`charID`) REFERENCES `chars` (`id`);


COMMIT;


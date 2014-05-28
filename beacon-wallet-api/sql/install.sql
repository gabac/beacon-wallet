CREATE TABLE `accounts` (
  `card` varchar(255) NOT NULL,
  `pin` varchar(255) NOT NULL,
  `cc_nr` varchar(255) DEFAULT NULL,
  `cc_date` varchar(5) DEFAULT NULL,
  `cc_ccv` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `accounts` (
  `card` varchar(255) NOT NULL,
  `pin` varchar(255) NOT NULL,
  `cc_nr` varchar(255) DEFAULT NULL,
  `cc_date` varchar(5) DEFAULT NULL,
  `cc_ccv` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `products_info` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product` (`product`),
  CONSTRAINT `products_info_ibfk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `barcodes` (
  `barcode` varchar(255) NOT NULL,
  `products_id` int(11) NOT NULL,
  PRIMARY KEY (`barcode`),
  KEY `fk_barcodes_products_idx` (`products_id`),
  CONSTRAINT `fk_barcodes_products` FOREIGN KEY (`products_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

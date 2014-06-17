CREATE TABLE `accounts` (
  `card` varchar(255) NOT NULL,
  `pin` varchar(255) NOT NULL,
  `cc_nr` varchar(255) DEFAULT NULL,
  `cc_date` varchar(5) DEFAULT NULL,
  `cc_ccv` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `products` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `products_info` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product` int(11) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product` (`product`),
  CONSTRAINT `products_info_ibfk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `barcodes` (
  `barcode` varchar(255) NOT NULL,
  `product` int(11) unsigned NOT NULL,
  PRIMARY KEY (`barcode`),
  KEY `product` (`product`),
  CONSTRAINT `fk_barcodes_products` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `branches` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `city` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `transactions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(255) NOT NULL DEFAULT '',
  `card` varchar(255) NOT NULL,
  `branch` int(11) unsigned NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `card` (`card`),
  KEY `branch` (`branch`),
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`branch`) REFERENCES `branches` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`card`) REFERENCES `accounts` (`card`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `transactions_products` (
  `transaction` int(11) unsigned NOT NULL,
  `product` int(11) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL DEFAULT '1',
  `amount` decimal(12,2) NOT NULL,
  PRIMARY KEY (`transaction`,`product`),
  KEY `product` (`product`),
  CONSTRAINT `transactions_products_ibfk_2` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transactions_products_ibfk_1` FOREIGN KEY (`transaction`) REFERENCES `transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `accounts` (`card`, `pin`, `cc_nr`, `cc_date`, `cc_ccv`)
VALUES
    ('2501032235098', '1234', '510143256345234', '08-15', '521');

INSERT INTO `products` (`id`, `name`, `price`, `updated`)
VALUES
    (1, 'Kellogg\'s Frosties', 5.50, '2014-11-09 08:53:12'),
    (2, 'Rivella Rot', 2.40, '2014-02-24 09:01:42'),
    (3, 'Heinz Tomato Ketchup', 3.40, '2014-02-02 13:42:11');

INSERT INTO `barcodes` (`barcode`, `products_id`)
VALUES
    ('4003994152744', 1),
    ('5050083122347', 1),
    ('7610097111188', 2),
    ('8715700406251', 3);

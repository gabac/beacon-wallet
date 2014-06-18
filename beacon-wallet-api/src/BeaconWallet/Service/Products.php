<?php

namespace BeaconWallet\Service;

/**
 * Storage access for accounts.
 */
class Products
{
    protected $database;

    public function __construct($database)
    {
        $this->database = $database;
    }

    public function getProducts()
    {
        $sql = 'SELECT p.id FROM `products` p';

        // execute query
        $products = $this->database->fetchAll($sql);

        return $products;
    }

    public function getProduct($id)
    {
        // product
        $sql = 'SELECT p.id, p.name, p.price, p.updated FROM `products` p WHERE p.id = ?';

        $product = $this->database->fetchAssoc($sql, array($id));

        // info
        $sql = 'SELECT i.name, i.value FROM `products_info` i WHERE i.product = ?';

        $info = $this->database->fetchAll($sql, array($id));

        // add info to product
        $product['info'] = $info;

        // barcodes
        $sql = 'SELECT b.barcode FROM `barcodes` b WHERE b.product = ?';

        $barcodes = $this->database->fetchArray($sql, array($id), 0);

        // add barcodes to product
        $product['barcodes'] = $barcodes;

        return $product;
    }

    public function addProduct($name, $price, $info = array())
    {
        $sql = 'INSERT INTO `products` (`name`, `price`, `updated`) VALUES (?, ?, NOW())';

        // add product
        $result = $this->database->executeUpdate($sql, array(
            $name,
            $price,
        ));

        // get product ID
        $id = $this->database->lastInsertId();

        // add product info
        $sql = 'INSERT INTO `products_info` (`product`, `name`, `value`) VALUES (?, ?, ?)';

        foreach ($info as $name => $value) {

            $result = $this->database->executeUpdate($sql, array(
                $id,
                $name,
                $value,
            ));
        }

        return $id;
    }
}

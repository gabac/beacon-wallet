<?php

namespace BeaconWallet\Service;

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

        $products = $this->database->fetchAll($sql);

        return $products;
    }

    public function getProduct($id)
    {
        $sql = 'SELECT p.id, p.name, p.price, p.updated FROM `products` p WHERE p.id = ?';

        $product = $this->database->fetchAssoc($sql, array($id));

        $sql = 'SELECT i.name, i.value FROM `products_info` i WHERE i.product = ?';

        $info = $this->database->fetchAll($sql, array($id));

        $product['info'] = $info;

        return $product;
    }

    public function addProduct($name, $price, $info = array())
    {
        $sql = 'INSERT INTO `products` (`name`, `price`, `updated`) VALUES (?, ?, NOW())';

        $result = $this->database->executeUpdate($sql, array(
            $name,
            $price,
        ));

        $id = $this->database->lastInsertId();

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

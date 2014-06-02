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
}

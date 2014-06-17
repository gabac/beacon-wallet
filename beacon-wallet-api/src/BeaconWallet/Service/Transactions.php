<?php

namespace BeaconWallet\Service;

class Transactions
{
    const STATUS_PENDING = 'pending';

    const STATUS_COMPLETE = 'complete';

    protected $database;

    public function __construct($database)
    {
        $this->database = $database;
    }

    public function getTransaction($id)
    {
        // transaction
        $sql = 'SELECT t.id, t.status, t.card, t.branch FROM `transactions` t WHERE t.id = ?';

        $transaction = $this->database->fetchAssoc($sql, array($id));

        // products
        $sql = 'SELECT p.product, p.quantity, p.amount FROM `transactions_products` p WHERE p.transaction = ?';

        $products = $this->database->fetchAll($sql, array($id));

        $transaction['products'] = $products;

        return $transaction;
    }

    public function createTransaction($card, $branch, $products = array())
    {
        $transactionId = null;

        $this->database->transactional(function($database) use ($card, $branch, $products, &$transactionId) {

            $sql = 'INSERT INTO `transactions` (`status`, `card`, `branch`, `created`) VALUES (?, ?, ?, NOW())';

            $result = $database->executeUpdate($sql, array(
                self::STATUS_PENDING,
                $card,
                $branch,
            ));

            $transactionId = $database->lastInsertId();

            $sql = 'INSERT INTO `transactions_products` (`transaction`, `product`, `quantity`, `amount`) VALUES (?, ?, ?, (SELECT p.price * ? FROM `products` p WHERE p.id = ?))';

            foreach ($products as $product) {

                $id = isset($product->id) ? $product->id : null;
                $quantity = isset($product->quantity) ? $product->quantity : 1;

                $result = $database->executeUpdate($sql, array(
                    $transactionId,
                    $id,
                    $quantity,
                    $quantity,
                    $id,
                ));
            }
        });

        return $transactionId;
    }

    public function payTransaction($id, $card)
    {
        $sql = 'UPDATE `transactions` SET `status` = ? WHERE `id` = ? AND `card` = ?';

        $result = $this->database->executeUpdate($sql, array(
            self::STATUS_COMPLETE,
            $id,
            $card,
        ));
    }
}

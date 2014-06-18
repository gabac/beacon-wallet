<?php

namespace BeaconWallet\Service;

/**
 * Storage access for transactions.
 */
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
        $sql = 'SELECT t.id, t.status, t.card FROM `transactions` t WHERE t.id = ?';

        $transaction = $this->database->fetchAssoc($sql, array($id));

        // products
        $sql = 'SELECT p.product, p.quantity, p.amount FROM `transactions_products` p WHERE p.transaction = ?';

        $products = $this->database->fetchAll($sql, array($id));

        // add products to transaction
        $transaction['products'] = $products;

        return $transaction;
    }

    public function createTransaction($card, $products = array())
    {
        // variable for closure
        $transactionId = null;

        // start database transaction
        $this->database->transactional(function($database) use ($card, $products, &$transactionId) {

            $sql = 'INSERT INTO `transactions` (`status`, `card`, `created`) VALUES (?, ?, NOW())';

            // create transaction with status pending
            $result = $database->executeUpdate($sql, array(
                self::STATUS_PENDING,
                $card,
            ));

            // get transaction ID
            $transactionId = $database->lastInsertId();

            $sql = 'INSERT INTO `transactions_products` (`transaction`, `product`, `quantity`, `amount`) VALUES (?, ?, ?, (SELECT p.price * ? FROM `products` p WHERE p.id = ?))';

            // look products
            foreach ($products as $product) {

                $id = isset($product->id) ? $product->id : null;
                $quantity = isset($product->quantity) ? $product->quantity : 1;

                // add products to database
                $result = $database->executeUpdate($sql, array(
                    $transactionId,
                    $id,
                    $quantity,
                    $quantity,
                    $id,
                ));
            }
        });

        // finally return the transaction ID from closure
        return $transactionId;
    }

    public function payTransaction($id, $card)
    {
        $sql = 'UPDATE `transactions` SET `status` = ? WHERE `id` = ? AND `card` = ?';

        // set status of transaction to complete
        $result = $this->database->executeUpdate($sql, array(
            self::STATUS_COMPLETE,
            $id,
            $card,
        ));
    }
}

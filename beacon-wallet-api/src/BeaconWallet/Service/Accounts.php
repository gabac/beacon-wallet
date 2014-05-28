<?php

namespace BeaconWallet\Service;

class Accounts
{
    protected $database;

    public function __construct($database)
    {
        $this->database = $database;
    }

    public function getAccount($card)
    {
        $sql = 'SELECT card, pin, cc_nr, cc_date, cc_ccv FROM `accounts` WHERE `card` = ?';

        $account = $this->database->fetchAssoc($sql, array($card));

        return $account;
    }
}

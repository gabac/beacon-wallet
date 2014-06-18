<?php

namespace BeaconWallet\Service;

/**
 * Storage access for accounts.
 */
class Accounts
{
    protected $database;

    public function __construct($database)
    {
        $this->database = $database;
    }

    public function getAccount($card)
    {
        $sql = 'SELECT a.card, a.pin, a.cc_nr, a.cc_date, a.cc_ccv FROM `accounts` a WHERE a.card = ?';

        $account = $this->database->fetchAssoc($sql, array($card));

        return $account;
    }

    /**
     * @return boolean true for a valid pin, false otherwise
     */
    public function verifyPin($card, $pin)
    {
        $sql = 'SELECT a.card, a.pin FROM `accounts` a WHERE a.card = ?';

        $account = $this->database->fetchAssoc($sql, array($card));

        if ($account == null) {
            return false;
        }

        if ($account['pin'] !== $pin) {
            return false;
        }

        return true;
    }
}

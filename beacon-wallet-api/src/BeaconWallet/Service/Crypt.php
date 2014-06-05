<?php

namespace BeaconWallet\Service;

class Crypt
{
    protected $privateKey;

    public function __construct($privateKey)
    {
        $this->privateKey = $privateKey;
    }

    private function loadPrivateKey()
    {
        $privateKey = openssl_pkey_get_private('file://' . $this->privateKey);
        if (!$privateKey) {
            throw new \Exception('Failed to load private key');
        }
        return $privateKey;
    }

    public function sign($data)
    {
        $privateKey = $this->loadPrivateKey();

        openssl_sign($data, $signature, $privateKey);

        openssl_free_key($privateKey);

        return base64_encode($signature);
    }

    public function decrypt($encrypted)
    {
        $privateKey = $this->loadPrivateKey();

        $encrypted = base64_decode($encrypted);

        openssl_private_decrypt($encrypted, $decrypted, $privateKey);

        openssl_free_key($privateKey);

        return $decrypted;
    }
}

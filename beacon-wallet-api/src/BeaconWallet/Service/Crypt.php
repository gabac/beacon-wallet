<?php

namespace BeaconWallet\Service;

/**
 * Helper class for cryptography.
 */
class Crypt
{
    /**
     * @var string path to private key
     */
    protected $privateKey;

    public function __construct($privateKey)
    {
        $this->privateKey = $privateKey;
    }

    /**
     * Internal helper to load the private key file.
     *
     * @throws \Exception if private key failed to load
     */
    private function loadPrivateKey()
    {
        $privateKey = openssl_pkey_get_private('file://' . $this->privateKey);
        if (!$privateKey) {
            throw new \Exception('Failed to load private key');
        }
        return $privateKey;
    }

    /**
     * Create a signature for the passed data.
     */
    public function sign($data)
    {
        $privateKey = $this->loadPrivateKey();

        openssl_sign($data, $signature, $privateKey);

        openssl_free_key($privateKey);

        return base64_encode($signature);
    }

    /**
     * Decrypt encrypted data.
     */
    public function decrypt($encrypted)
    {
        $privateKey = $this->loadPrivateKey();

        $encrypted = base64_decode($encrypted);

        openssl_private_decrypt($encrypted, $decrypted, $privateKey);

        openssl_free_key($privateKey);

        return $decrypted;
    }
}

<?php

namespace BeaconWallet\Tests;

class TransactionsTest extends ApiTest
{
    public function testCreateTransaction()
    {
        $encrypted = file_get_contents(__DIR__ . '/fixtures/createTransaction.txt');

        $client = $this->createClient();
        $crawler = $client->request('POST', '/transactions', array('cart' => $encrypted));

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertJsonStringEqualsJsonFile(__DIR__ . '/fixtures/createTransaction.json', $client->getResponse()->getContent());
    }
}

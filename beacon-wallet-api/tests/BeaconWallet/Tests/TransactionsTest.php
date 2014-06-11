<?php

namespace BeaconWallet\Tests;

class TransactionsTest extends ApiTest
{
    public function testCreateTransaction()
    {
        $encrypted = file_get_contents(__DIR__ . '/fixtures/createTransaction.txt');

        $client = $this->createClient();
        $crawler = $client->request('POST', '/transactions', array(), array(), array(), $encrypted);

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertEquals(file_get_contents(__DIR__ . '/fixtures/createTransaction.json'), $client->getResponse()->getContent());
    }
}

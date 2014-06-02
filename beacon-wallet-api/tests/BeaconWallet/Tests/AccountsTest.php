<?php

namespace BeaconWallet\Tests;

class AccountsTest extends ApiTest
{
    public function testGetAccount()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/accounts/2501032235098');

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertEquals(file_get_contents(__DIR__ . '/fixtures/getAccount.json'), $client->getResponse()->getContent());
    }
}

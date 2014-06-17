<?php

namespace BeaconWallet\Tests;

class AccountsTest extends ApiTest
{
    public function testGetAccount()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/accounts/2501032235098', array(), array(), array(
            'PHP_AUTH_USER' => '2501032235098',
            'PHP_AUTH_PW'   => '1234',
        ));

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertJsonStringEqualsJsonFile(__DIR__ . '/fixtures/getAccount.json', $client->getResponse()->getContent());
    }
}

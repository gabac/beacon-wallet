<?php

namespace BeaconWallet\Tests;

class HomeTest extends ApiTest
{
    public function testindex()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/');

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertJsonStringEqualsJsonFile(__DIR__ . '/fixtures/index.json', $client->getResponse()->getContent());
    }
}

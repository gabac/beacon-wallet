<?php

namespace BeaconWallet\Tests;

class ProductsTest extends ApiTest
{
    public function testGetProducts()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/products');

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertEquals(file_get_contents(__DIR__ . '/fixtures/getProducts.json'), $client->getResponse()->getContent());
    }
}

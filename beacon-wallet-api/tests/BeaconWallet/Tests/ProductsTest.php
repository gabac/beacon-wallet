<?php

namespace BeaconWallet\Tests;

class ProductsTest extends ApiTest
{
    public function testGetProducts()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/products');

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertJsonStringEqualsJsonFile(__DIR__ . '/fixtures/getProducts.json', $client->getResponse()->getContent());
    }

    public function testGetProduct()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/products/37');

        $this->assertTrue($client->getResponse()->isOk());
        $this->assertEquals('Thu, 12 Jun 2014 22:57:48 GMT', $client->getResponse()->headers->get('Last-Modified'));
        $this->assertJsonStringEqualsJsonFile(__DIR__ . '/fixtures/getProduct.json', $client->getResponse()->getContent());
    }

    public function testGetProductNotModified()
    {
        $client = $this->createClient();
        $crawler = $client->request('GET', '/products/37', array(), array(), array('HTTP_If-Modified-Since' => 'Thu, 12 Jun 2014 22:57:48 GMT'));

        $this->assertEquals(304, $client->getResponse()->getStatusCode());
        $this->assertEquals('', $client->getResponse()->getContent());
    }
}

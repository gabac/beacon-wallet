<?php

namespace BeaconWallet\Tests;

use Silex\WebTestCase;
use BeaconWallet\Application;

abstract class ApiTest extends WebTestCase
{
    public function createApplication()
    {
        $app = new Application();

        $app['debug'] = false;
        $app['exception_handler']->disable();

        return $app;
    }

    public function setUp()
    {
        parent::setUp();

        $database = $this->app['db'];
        $database->query('SET FOREIGN_KEY_CHECKS=0');
        $database->query('TRUNCATE TABLE transactions_products');
        $database->query('TRUNCATE TABLE transactions');
        $database->query('SET FOREIGN_KEY_CHECKS=1');
    }
}

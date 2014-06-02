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
}

<?php

namespace BeaconWallet;

class Application extends \Silex\Application
{
    public function __construct()
    {
        parent::__construct();

        $app = $this;

        // load config
        $app['config'] = require __DIR__ . '/../../config.php';

        $app['debug'] = $app['config']['debug'];

        // silex providers
        $app->register(new \Silex\Provider\UrlGeneratorServiceProvider());
        $app->register(new \Silex\Provider\ServiceControllerServiceProvider());

        // application service and controller provider
        $app->register(new ServiceProvider());
        $app->mount('/', new ControllerProvider());
    }
}

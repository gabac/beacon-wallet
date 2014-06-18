<?php

namespace BeaconWallet;

/**
 * Main Silex application.
 */
class Application extends \Silex\Application
{
    public function __construct()
    {
        parent::__construct();

        $app = $this;

        // load config
        $app['config'] = require __DIR__ . '/../../config.php';

        $app['debug'] = $app['config']['debug'];

        // Exception handler
        $app->error(function (\Exception $e, $code) use ($app) {
            if ($app['debug']) {
                return;
            }
            $result = array('errors' => array(array('message' => $e->getMessage())));
            return $app->json($result, $code);
        });

        // silex providers
        $app->register(new \Silex\Provider\UrlGeneratorServiceProvider());
        $app->register(new \Silex\Provider\ServiceControllerServiceProvider());
        $app->register(new \Silex\Provider\DoctrineServiceProvider(), array(
            'dbs.options' => $app['config']['database'],
        ));

        // application service and controller provider
        $app->register(new ServiceProvider());
        $app->mount('/', new ControllerProvider());
    }
}

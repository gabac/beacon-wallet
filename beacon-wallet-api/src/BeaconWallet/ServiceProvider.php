<?php

namespace BeaconWallet;

class ServiceProvider implements \Silex\ServiceProviderInterface
{
    public function register(\Silex\Application $app)
    {
        $app['controller.home'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Controller\HomeController(
                $app['url_generator']
            );
        });
    }

    public function boot(\Silex\Application $app)
    {
    }
}

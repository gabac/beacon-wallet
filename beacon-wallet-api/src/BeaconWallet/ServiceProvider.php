<?php

namespace BeaconWallet;

class ServiceProvider implements \Silex\ServiceProviderInterface
{
    public function register(\Silex\Application $app)
    {
        $app['service.accounts'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Service\Accounts(
                $app['db']
            );
        });
        
        $app['controller.home'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Controller\HomeController(
                $app['url_generator']
            );
        });

        $app['controller.accounts'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Controller\AccountsController(
                $app['service.accounts'],
                $app['url_generator']
            );
        });
    }

    public function boot(\Silex\Application $app)
    {
    }
}

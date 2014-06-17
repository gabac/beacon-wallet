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

        $app['service.products'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Service\Products(
                $app['db']
            );
        });

        $app['service.transactions'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Service\Transactions(
                $app['db']
            );
        });

        $app['service.crypt'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Service\Crypt(
                $app['config']['encryption']['private_key']
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

        $app['controller.products'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Controller\ProductsController(
                $app['service.products'],
                $app['url_generator']
            );
        });

        $app['controller.transactions'] = $app->share(function() use ($app) {
            return new \BeaconWallet\Controller\TransactionsController(
                $app['service.transactions'],
                $app['service.accounts'],
                $app['service.crypt'],
                $app['url_generator']
            );
        });
    }

    public function boot(\Silex\Application $app)
    {
    }
}

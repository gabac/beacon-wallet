<?php

namespace BeaconWallet;

/**
 * Mapping of URLs to controllers (router).
 */
class ControllerProvider implements \Silex\ControllerProviderInterface
{
    public function connect(\Silex\Application $app)
    {
        $controllers = $app['controllers_factory'];

        $controllers->get('/', 'controller.home:indexAction')->bind('home');
        $controllers->get('/accounts/{card}', 'controller.accounts:getAccount')->bind('account');
        $controllers->get('/products', 'controller.products:getProducts')->bind('products');
        $controllers->get('/products/{id}', 'controller.products:getProduct')->bind('product');
        $controllers->post('/transactions', 'controller.transactions:createTransaction');
        $controllers->post('/transactions/payment', 'controller.transactions:payTransaction');

        return $controllers;
    }
}

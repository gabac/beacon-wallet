<?php

namespace BeaconWallet;

class ControllerProvider implements \Silex\ControllerProviderInterface
{
    public function connect(\Silex\Application $app)
    {
        $controllers = $app['controllers_factory'];

        $controllers->get('/', 'controller.home:indexAction')->bind('home');
        $controllers->get('/accounts/{card}', 'controller.accounts:getAccount')->bind('account');
        $controllers->get('/products', 'controller.products:getProducts')->bind('products');
        $controllers->post('/transactions', 'controller.transactions:createTransaction');
        $controllers->get('/transactions', 'controller.transactions:getTransactions')->bind('transactions');

        return $controllers;
    }
}

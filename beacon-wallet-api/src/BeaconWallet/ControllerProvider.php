<?php

namespace BeaconWallet;

class ControllerProvider implements \Silex\ControllerProviderInterface
{
    public function connect(\Silex\Application $app)
    {
        $controllers = $app['controllers_factory'];

        // home
        $controllers->get('/', 'controller.home:indexAction')->bind('home');

        return $controllers;
    }
}

<?php

require_once __DIR__ . '/../vendor/autoload.php';

// create Silex application
$app = new BeaconWallet\Application();

// add error handlers
Symfony\Component\Debug\ErrorHandler::register();
Symfony\Component\HttpKernel\Debug\ExceptionHandler::register($app['debug']);

// run Silex application
$app->run();

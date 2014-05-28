<?php

require_once __DIR__ . '/../vendor/autoload.php';

$app = new BeaconWallet\Application();

Symfony\Component\Debug\ErrorHandler::register();
Symfony\Component\HttpKernel\Debug\ExceptionHandler::register($app['debug']);

$app->run();

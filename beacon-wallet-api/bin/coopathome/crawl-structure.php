<?php

require_once __DIR__ . '/../../vendor/autoload.php';

$client = new GuzzleHttp\Client(['base_url' => 'http://www.coopathome.ch/b2c_coop/api/']);

$response = $client->post('catalogstructure.do', [
    'body' => [
        'language' => 'de',
        'version' => '3.1',
        'shop' => 'DIREKT_DE',
    ]
]);

echo $response->getBody();


<?php

require_once __DIR__ . '/../../vendor/autoload.php';

$app = new BeaconWallet\Application();

$client = new GuzzleHttp\Client([
    'base_url' => 'http://www.coopathome.ch/b2c_coop/api/',
    'defaults' => [
        'body' => [
            'language' => 'de',
            'version' => '3.1',
            'shop' => 'DIREKT_DE',
        ],
    ],
]);

$areas = [
    '4AD598439F98028BE10000000A030109', // Teigwaren
    '4D992A6A66E46DB3E10000000A030109', // Chips
    '4AD50CDFBD564590E10000000A030109', // Tafelschokolade
    '4AD5942BC3EB6849E10000000A030109', // Müsli / Cerealien
    '4AD6CB3EA0EA59CCE10000000A030109', // Zahnpflege
];

foreach ($areas as $area) {

    echo "Getting catalog for area $area\n";

    $offset = 0;
    $totalItems = 0;

    do {

        $response = $client->post('catalog.do', [
            'body' => [
                'area' => $area,
                'offset' => $offset,
            ]
        ]);

        $catalog = simplexml_load_string($response->getBody());

        $totalItems = (int) $catalog->totalItems;
        $items = $catalog->items->item;

        foreach ($items as $item) {

            echo "Getting product $item->id ($offset/$totalItems)\n";

            $response = $client->post('article.do', [
                'body' => [
                    'area' => $area,
                    'item' => (string) $item->id,
                ]
            ]);

            $article = simplexml_load_string($response->getBody());

            $name = html_entity_decode((string) $article->name, ENT_QUOTES | ENT_HTML5);
            $price = (string) $article->price;

            $info = [];

            if (count($article->tabs->tab) > 0) {

                foreach ($article->tabs->tab as $tab) {

                    foreach ($tab->attributes->attribute as $attribute) {

                        $info[(string) $attribute->name] = (string) $attribute->value;
                    }
                }
            }

            $app['service.products']->addProduct($name, $price, $info);

            $offset++;
        }

    } while ($offset < $totalItems);
}


<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

class TransactionsController
{
    protected $crypt;

    /**
     * @var \Symfony\Component\Routing\Generator\UrlGenerator
     */
    protected $url;

    public function __construct($crypt, $url)
    {
        $this->crypt = $crypt;
        $this->url = $url;
    }

    public function createTransaction(Request $request)
    {
        $encrypted = $request->getContent();

        $decrypted = $this->crypt->decrypt($encrypted);

        $data = json_decode($decrypted);

        // TODO process transaction

        $json = json_encode($data);

        $signature = $this->crypt->sign($json);

        return new JsonResponse(array(
            'transaction' => $json,
            'signature' => $signature,
        ));
    }

    public function getTransactions(Request $request)
    {
        $transaction = array(
            'id' => 42,
        );
        $json = json_encode($transaction);

        $encrypted = 'Wezl9GKjvdoGrbVjV20iMApNoQpckL7DDkB1eQOkhrTIjCAV7cMvtWMa+VWUKgiVPr0tsl+dOvg413NEIWFuwuaMjLQJ8u+ZuBKVGRvic/MV0bLDefNAk03wbFEtHtRdqxLeVV0igbELc7rzkXPF6E/QYKZf/AGz+Nh5gkyVznNBaZ+0MwEifABwQRauSNmJb6ZG3Ze8jidgjSyyn/Jbzxllr58rhkbKnutuDnDpCGytPz87ZtoaEiyPBzOAb8OlxYKh5zNhI8jIc7V2lGk1/4ZnsTId15YdCfbu6eLvEK6fOXzPTLgzOPXm4dRu952vgbAfvVj5XKUC23nHcxojhg==';

        // prepare and return response
        $data = array(
            'transaction' => $json,
            'signature' => $this->crypt->sign($json),
            'decrypted' => $this->crypt->decrypt($encrypted),
        );

        return new JsonResponse(array(
            'transactions' => $data
        ));
    }
}

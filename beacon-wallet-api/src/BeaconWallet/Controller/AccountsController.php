<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

class AccountsController
{
    protected $accounts;

    /**
     * @var \Symfony\Component\Routing\Generator\UrlGenerator
     */
    protected $url;

    public function __construct($accounts, $url)
    {
        $this->accounts = $accounts;
        $this->url = $url;
    }

    public function getAccount($card, Request $request)
    {
        $card = $request->getUser();
        $pin = $request->getPassword();

        if (!$this->accounts->verifyPin($card, $pin)) {
            throw new AccessDeniedHttpException('Invalid card and pin');
        }

        $account = $this->accounts->getAccount($card);

        if ($account) {

            $data = array(
                'card' => $account['card'],
                'cc_nr' => $account['cc_nr'],
                'cc_date' => $account['cc_date'],
            );

            return new JsonResponse($data);

        } else {

            throw new HttpException(404, 'Account not found');

        }
    }
}

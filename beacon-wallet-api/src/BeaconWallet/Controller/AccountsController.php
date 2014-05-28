<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
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

    public function getAccountAction($card, Request $request)
    {
        $account = $this->accounts->getAccount($card);

        if ($account) {

            return new JsonResponse($account);

        } else {

            throw new HttpException(404, 'Account not found');

        }
    }
}

<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * REST resource for accounts.
 */
class AccountsController
{
    /**
     * @var \BeaconWallet\Service\Accounts
     */
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

    /**
     * Returns JSON response of an account, identified by the card number.
     */
    public function getAccount($card, Request $request)
    {
        $card = $request->getUser();
        $pin = $request->getPassword();

        // security check
        if (!$this->accounts->verifyPin($card, $pin)) {
            throw new AccessDeniedHttpException('Invalid card and pin');
        }

        // fetch account from storage
        $account = $this->accounts->getAccount($card);

        // check if account was found
        if ($account) {

            // only return specific data
            $data = array(
                'card' => $account['card'],
                'cc_nr' => $account['cc_nr'],
                'cc_date' => $account['cc_date'],
            );

            return new JsonResponse($data);

        } else {

            // account not found
            throw new HttpException(404, 'Account not found');

        }
    }
}

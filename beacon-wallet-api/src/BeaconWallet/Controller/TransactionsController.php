<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * REST resource for transactions.
 */
class TransactionsController
{
    /**
     * @var \BeaconWallet\Service\Transactions
     */
    protected $transactions;

    /**
     * @var \BeaconWallet\Service\Accounts
     */
    protected $accounts;

    /**
     * @var \BeaconWallet\Service\Crypt
     */
    protected $crypt;

    /**
     * @var \Symfony\Component\Routing\Generator\UrlGenerator
     */
    protected $url;

    public function __construct($transactions, $accounts, $crypt, $url)
    {
        $this->transactions = $transactions;
        $this->accounts = $accounts;
        $this->crypt = $crypt;
        $this->url = $url;
    }

    /**
     * Creates a new transaction.
     */
    public function createTransaction(Request $request)
    {
        $encrypted = $request->get('cart');

        // decrypt cart
        $decrypted = $this->crypt->decrypt($encrypted);

        $data = json_decode($decrypted);

        $card = isset($data->card) ? $data->card : null;
        $products = isset($data->products) && is_array($data->products) ? $data->products : array();

        // create transaction
        $transactionId = $this->transactions->createTransaction($card, $products);

        // prepare transaction response
        $json = $this->getTransactionJson($transactionId);

        // sign response
        $signature = $this->crypt->sign($json);

        return new JsonResponse(array(
            'transaction' => $json,
            'signature' => $signature,
        ));
    }

    protected function getTransactionJson($transactionId)
    {
        $transaction = $this->transactions->getTransaction($transactionId);

        $data = array(
            'id' => (int) $transaction['id'],
            'status' => $transaction['status'],
            'card' => $transaction['card'],
            'amount' => 0.0,
            'products' => array(),
        );

        foreach ($transaction['products'] as $product) {

            $data['products'][] = array(
                'id' => (int) $product['product'],
                'quantity' => (int) $product['quantity'],
                'amount' => (float) $product['amount'],
            );

            $data['amount'] += (float) $product['amount'];
        }

        return json_encode($data);
    }

    public function payTransaction(Request $request)
    {
        // encrypt payment
        $encrypted = $request->get('payment');

        $decrypted = $this->crypt->decrypt($encrypted);

        $data = json_decode($decrypted);

        $id = isset($data->id) ? $data->id : null;
        $card = isset($data->card) ? $data->card : null;
        $pin = isset($data->pin) ? $data->pin : null;

        if (!$this->accounts->verifyPin($card, $pin)) {
            throw new AccessDeniedHttpException('Invalid card and pin');
        }

        $this->transactions->payTransaction($id, $card);

        // prepare transaction response
        $json = $this->getTransactionJson($id);

        // sign response
        $signature = $this->crypt->sign($json);
        
        return new JsonResponse(array(
            'transaction' => $json,
            'signature' => $signature,
        ));
    }

}

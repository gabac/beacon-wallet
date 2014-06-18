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

        // read parameters from decoded request
        $card = isset($data->card) ? $data->card : null;
        $products = isset($data->products) && is_array($data->products) ? $data->products : array();

        // create transaction
        $transactionId = $this->transactions->createTransaction($card, $products);

        // return transaction response
        return $this->getTransactionResponse($transactionId);
    }

    /**
     * Complete transaction with payment.
     */
    public function payTransaction(Request $request)
    {
        $encrypted = $request->get('payment');

        // decrypt payment
        $decrypted = $this->crypt->decrypt($encrypted);

        $data = json_decode($decrypted);

        // read parameters from decoded request
        $id = isset($data->id) ? $data->id : null;
        $card = isset($data->card) ? $data->card : null;
        $pin = isset($data->pin) ? $data->pin : null;

        // security check
        if (!$this->accounts->verifyPin($card, $pin)) {
            throw new AccessDeniedHttpException('Invalid card and pin');
        }

        // complete transaction
        $this->transactions->payTransaction($id, $card);

        // return transaction response
        return $this->getTransactionResponse($id);
    }

    /**
     * Internal method to prepare transaction JSON response with a signature.
     */
    protected function getTransactionResponse($transactionId)
    {
        // fetch transaction from storage
        $transaction = $this->transactions->getTransaction($transactionId);

        // prepare transaction response
        $data = array(
            'id' => (int) $transaction['id'],
            'status' => $transaction['status'],
            'card' => $transaction['card'],
            'amount' => 0.0,
            'products' => array(),
        );

        // loop products
        foreach ($transaction['products'] as $product) {

            // add product to transaction response
            $data['products'][] = array(
                'id' => (int) $product['product'],
                'quantity' => (int) $product['quantity'],
                'amount' => (float) $product['amount'],
            );

            // add product amount to total
            $data['amount'] += (float) $product['amount'];
        }

        $json = json_encode($data);

        // sign response
        $signature = $this->crypt->sign($json);

        return new JsonResponse(array(
            'transaction' => $json,
            'signature' => $signature,
        ));
    }

}

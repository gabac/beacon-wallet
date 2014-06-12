<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

class ProductsController
{
    protected $products;

    /**
     * @var \Symfony\Component\Routing\Generator\UrlGenerator
     */
    protected $url;

    public function __construct($products, $url)
    {
        $this->products = $products;
        $this->url = $url;
    }

    public function getProducts(Request $request)
    {
        $products = $this->products->getProducts();

        return new JsonResponse(array(
            'products' => $products
        ));
    }

    public function getProduct($id, Request $request)
    {
        $product = $this->products->getProduct($id);

        $updated = new \DateTime($product['updated']);

        $response = new JsonResponse();
        $response->setLastModified($updated);
        $response->setPublic();

        if ($response->isNotModified($request)) {
            return $response;
        }

        $response->setData($product);

        return $response;
    }
}

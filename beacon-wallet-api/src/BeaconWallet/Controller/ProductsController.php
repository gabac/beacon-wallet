<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * REST resource for products.
 */
class ProductsController
{
    /**
     * @var \BeaconWallet\Service\Products
     */
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

    /**
     * Returns a list of product IDs.
     */
    public function getProducts(Request $request)
    {
        $products = $this->products->getProducts();

        return new JsonResponse(array(
            'products' => $products
        ));
    }

    /**
     * Returns a JSON response of the complete product.
     */
    public function getProduct($id, Request $request)
    {
        // fetch product from storage
        $product = $this->products->getProduct($id);

        // parse product updated date
        $updated = new \DateTime($product['updated']);

        // create response with Last-Modified and Cache-Control headers
        $response = new JsonResponse();
        $response->setLastModified($updated);
        $response->setPublic();

        // if product has not been modified since last call, return empty response
        if ($response->isNotModified($request)) {
            return $response;
        }

        // prepare product data for response
        $data = array(
            'id' => (int) $product['id'],
            'name' => $product['name'],
            'price' => (float) $product['price'],
            'info' => $product['info'],
            'barcodes' => $product['barcodes'],
        );

        $response->setData($data);

        return $response;
    }
}

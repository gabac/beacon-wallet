<?php

namespace BeaconWallet\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

class HomeController
{
    /**
     * @var \Symfony\Component\Routing\Generator\UrlGenerator
     */
    protected $url;

    public function __construct($url)
    {
        $this->url = $url;
    }

    public function indexAction(Request $request)
    {
        $data = array(
            'links' => array(
                'home' => $this->url->generate('home', array(), true),
            ),
        );

        return new JsonResponse($data);
    }
}

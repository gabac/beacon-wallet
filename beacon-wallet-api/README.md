# Beacon Wallet API

## Setup

```
git clone git@github.com:gabac/beacon-wallet.git
cd beacon-wallet/beacon-wallet-api
php composer.phar install
cp config.php.dist config.php
mysql < sql/install.sql
```

## Development

```
php -S localhost:8000 -t web/
```

For development you can use the built-in PHP server by running the previous 
command and accessing the API at [http://localhost:8000/](http://localhost:8000/).

## Tests

To run the test suite use the PHPUnit binary from the Composer vendors.

```
vendor/bin/phpunit
```

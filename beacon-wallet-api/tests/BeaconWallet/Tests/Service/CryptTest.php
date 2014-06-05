<?php

namespace BeaconWallet\Tests\Service;

use BeaconWallet\Service\Crypt;

class CryptTest extends \PHPUnit_Framework_TestCase
{
    protected function setUp()
    {
        $this->crypt = new Crypt(__DIR__ . '/private_key.pem');
    }

    public function testSign()
    {
        $signature = 'CE3sX1gamLOrU5zzjXqL6Qck0G7u3XD5lQASD0DuIrAqfyXhvspklt1gd9VWzQCE/zyhvtQ95UzgHHtCCY2uucC4ezufEF+zT0ror822k+i6iCvTdhZ08BolOd6Ruumx2CuZ8PidmKpP84nJvk6+V7O6qm3sWZBZi4mTChc9knwWxuAEqg0Pczm7UjBeAVC2MIi6b0/jkS+yfXOExMTm5i65DfBfuDZuJ/B2PIl6wDb5P55ci1Z2nVjKexMy/YtpkrvapOAEhn25/R2hgoPLnYJFr+mMpP5rs3eZXT2jkA0KucoFd9JHfkfFSAZ6EjfIeKXqZTiYjyPBc1CMR07d0A==';

        $this->assertEquals($signature, $this->crypt->sign('{"id":42}'));
    }

    public function testEncrypt()
    {
        $encrypted = 'Wezl9GKjvdoGrbVjV20iMApNoQpckL7DDkB1eQOkhrTIjCAV7cMvtWMa+VWUKgiVPr0tsl+dOvg413NEIWFuwuaMjLQJ8u+ZuBKVGRvic/MV0bLDefNAk03wbFEtHtRdqxLeVV0igbELc7rzkXPF6E/QYKZf/AGz+Nh5gkyVznNBaZ+0MwEifABwQRauSNmJb6ZG3Ze8jidgjSyyn/Jbzxllr58rhkbKnutuDnDpCGytPz87ZtoaEiyPBzOAb8OlxYKh5zNhI8jIc7V2lGk1/4ZnsTId15YdCfbu6eLvEK6fOXzPTLgzOPXm4dRu952vgbAfvVj5XKUC23nHcxojhg==';

        $this->assertEquals('{"nr":"1234567890","pin":"1234"}', $this->crypt->decrypt($encrypted));
    }
}

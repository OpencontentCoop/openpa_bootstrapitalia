<?php

use Opencontent\Ckan\DatiTrentinoIt\Client as BaseClient;
use OCOpenDataRequestException as Exception;

class OpenPABootstrapItaliaCkanClient extends BaseClient
{
	protected function setHeaders()
    {
        $date = new \DateTime( null, new \DateTimeZone( 'UTC' ) );
        $this->chHeaders = array(
            'Date: ' . $date->format( 'D, d M Y H:i:s' ) . ' GMT', // RFC 1123
            'Accept: application/json;q=1.0, application/xml;q=0.5, */*;q=0.0',
            'Accept-Charset: utf-8',
            'Accept-Encoding: gzip'
        );
    }

	protected function setUserAgent()
    {        
        $this->userAgent = sprintf( $this->userAgent, $this->version );
    }	
}
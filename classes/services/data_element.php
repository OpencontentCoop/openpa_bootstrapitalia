<?php

class ObjectHandlerServiceDataElement extends ObjectHandlerServiceBase
{
    private $dataElement;

    function run()
    {
        $this->fnData['value'] = 'getDataElement';
    }

    protected function getDataElement()
    {
        if ($this->dataElement === null) {
            $this->dataElement = $this->mapValue();
        }
        return $this->dataElement;
    }

    private function mapValue()
    {
        $value = $this->mapValueByRemoteId($this->container->getContentObject()->attribute('remote_id'));
        if (!$value){
            $value = $this->mapValueByClassIdentifier($this->container->getContentObject()->attribute('class_identifier'));
        }

        return $value;
    }

    private function mapValueByRemoteId($remoteId)
    {
        // Amministrazione @todo
        if (in_array($remoteId, [
            'organi_politici',
            '899b1ac505747c0d8523dfe12751eaae',
            'a9d783ef0712ac3e37edb23796990714',
            '50f295ca2a57943b195fa8ffc6b909d8',
            '3da91bfec50abc9740f0f3d62c8aaac4',
            '10742bd28e405f0e83ae61223aea80cb',
            //'ba268b968e339cca487ce2110c04b924', Luoghi
            'cb945b1cdaad4412faaa3a64f7cdd065',
        ])){
            return 'amministration-element';
        }

        if (in_array($remoteId, [
            'b04a731ca8cc79de8b7cf9f6c2f37705',
            'all-services'
        ])){
            return 'all-services';
        }

        if (in_array($remoteId, [
            'topics',
            'all-topics'
        ])){
            return 'all-topics';
        }

        return false;
    }

    private function mapValueByClassIdentifier($classIdentifier)
    {
        switch ($classIdentifier) {
            case 'public_service':
                return 'service-link';

            case 'political_body':
            case 'office':
            case 'administrative_area':
                return 'amministration-element';

            case 'topic':
                return 'topic-element';
        }

        return $classIdentifier;
    }
}
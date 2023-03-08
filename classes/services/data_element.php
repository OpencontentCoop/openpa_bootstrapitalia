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
        $remoteId = $this->container->getContentObject()->attribute('remote_id');
        $value = $this->mapValueByRemoteId($remoteId);
        if (!$value){
            $value = $this->mapValueByClassIdentifier($this->container->getContentObject()->attribute('class_identifier'));
        }
        if (!$value){
            $value = $remoteId;
        }

        return $value;
    }

    private function mapValueByRemoteId($remoteId)
    {
        // Amministrazione
        if (in_array($remoteId, [
            'organi_politici', // Organi di governo
            '899b1ac505747c0d8523dfe12751eaae', // Aree
            'a9d783ef0712ac3e37edb23796990714', // Uffici
            '50f295ca2a57943b195fa8ffc6b909d8', // Politici
            '3da91bfec50abc9740f0f3d62c8aaac4', // Personale amministrativo
            '10742bd28e405f0e83ae61223aea80cb', // Enti e fondazioni
            'cb945b1cdaad4412faaa3a64f7cdd065', // Documenti e dati
        ])){
//            return 'amministration-element';
            return 'management-category-link';
        }

        // Novità
        if (in_array($remoteId, [
            '9a1756e11164d0d550ee950657154db8', // Avvisi
            '16a65071f99a1be398a677e5e4bef93f', // Comunicati stampa
            'ea708fa69006941b4dc235a348f1431d', // Notizie
        ])){
            return 'news-category-link';
        }

        // Luoghi
        if (in_array($remoteId, [
            'ba268b968e339cca487ce2110c04b924', // bc
            'all-places',
        ])){
            return 'live-button-locations';
        }

        // Eventi
        if ($remoteId === 'all-events'){
            return 'live-button-events';
        }

        // Note Legali
        if ($remoteId === '931779762484010404cf5fa08f77d978'){
            return 'legal-notes-section';
        }

        if (in_array($remoteId, [
            'b04a731ca8cc79de8b7cf9f6c2f37705', // Servizi (bc)
            'all-services' // Servizi
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
                return 'management-category-link';

            case 'topic':
                return 'topic-element';
        }

        return false;
    }
}
<?php

use Opencontent\OpenApi\Exceptions\InternalException;
use Opencontent\OpenApi\Exceptions\InvalidPayloadException;

class CollectInefficiency
{
    const REMOTE_ID = 'inefficiency-dataset';

    private static $instance;

    /**
     * @var eZContentObject
     */
    private $datasetObject;

    /**
     * @var eZContentObjectAttribute
     */
    protected $datasetAttribute;

    /**
     * @var OpendataDatasetDefinition
     */
    protected $datasetDefinition;

    private function __construct()
    {
        $this->datasetObject = eZContentObject::fetchByRemoteID(self::REMOTE_ID);
        $dataMap = $this->datasetObject ? $this->datasetObject->dataMap() : [];
        if (isset($dataMap['csv_resource'])
            && $dataMap['csv_resource']->attribute('data_type_string') === OpendataDatasetType::DATA_TYPE_STRING) {
            $this->datasetAttribute = $dataMap['csv_resource'];
            $this->datasetDefinition = $dataMap['csv_resource']->content();
        }
    }

    public static function instance(): CollectInefficiency
    {
        if (self::$instance === null) {
            self::$instance = new CollectInefficiency();
        }

        return self::$instance;
    }

    public function collect(array $data): array
    {
        if (!$this->datasetObject instanceof eZContentObject
            || !$this->datasetDefinition instanceof OpendataDatasetDefinition) {
            throw new InternalException(sprintf('Missing %s dataset configuration', self::REMOTE_ID));
        }

        if (isset($data['backoffice_data']['is_public'])) {
            $data = $this->collectFromApplication($data);
        } elseif (isset($data['moderation_status'])) {
            $data = $this->collectFromSensorPost($data);
        } else {
            throw new InvalidPayloadException();
        }

        $dataset = $this->datasetDefinition->create($data['payload'], $this->datasetAttribute);
        try {
            $currentDataset = $this->datasetDefinition->getDataset(
                $this->datasetDefinition->generateDatasetGuid($dataset),
                $this->datasetAttribute
            );
        } catch (Throwable $exception) {
            $currentDataset = null;
        }

        if ($data['action'] === 'upsert') {
            if ($currentDataset instanceof OpendataDataset) {
                $dataset->setGuid($currentDataset->getGuid());
                $dataset->setCreatedAt($currentDataset->getCreatedAt());
                $dataset->setCreator($currentDataset->getCreator());

                $this->datasetDefinition->updateDataset($dataset);
                $data['action'] = 'update';
            } else {
                $this->datasetDefinition->createDataset($dataset);
                $data['action'] = 'create';
            }
        } elseif ($data['action'] === 'delete') {
            if ($currentDataset instanceof OpendataDataset) {
                $this->datasetDefinition->deleteDataset($currentDataset);
            }
        }

        return $data;
    }

    private function collectFromApplication(array $data): array
    {
        $status = 'Aperta';
        switch ($data['status']) {
            case 7000:
            case 9000:
                $status = 'Chiusa';
                break;
            case 4000:
                $status = 'Presa in carico';
                break;
        }

        $payload = [
            'uuid' => $data['id'],
            'subject' => $data['data']['subject'],
            'category' => $data['data']['type']['label'] ?? '',
            'text' => $data['data']['details'],
            'address' => $data['data']['address']['display_name'] ?? '',
            'geo' => isset($data['data']['address']['lat'], $data['data']['address']['lon']) ? sprintf(
                '%s,%s',
                $data['data']['address']['lat'],
                $data['data']['address']['lon']
            ) : '',
            'published' => date('d/M/Y H:i', $data['creation_time']),
            'status' => $status,
            'image1' => $data['data']['images'][0]['url'] ?? '',
            'image2' => $data['data']['images'][1]['url'] ?? '',
            'image3' => $data['data']['images'][2]['url'] ?? '',
            'source' => sprintf('application:%s', $data['tenant']),
        ];

        if ($data['backoffice_data']['is_public']) {
            return [
                'action' => 'upsert',
                'payload' => $payload,
            ];
        } else {
            return [
                'action' => 'delete',
                'payload' => $payload,
            ];
        }
    }

    private function collectFromSensorPost(array $data): array
    {
        $status = 'Aperta';
        switch ($data['status']) {
            case 'closed':
                $status = 'Chiusa';
                break;
            case 'pending':
                $status = 'Presa in carico';
                break;
        }
        
        $payload = [
            'uuid' => $data['address_meta_info']['application']['id'] ?? $data['id'],
            'subject' => $data['subject'],
            'category' => $data['category'] ?? '',
            'text' => $data['description'],
            'address' => $data['address']['address'] ?? '',
            'geo' => isset($data['address']['latitude'], $data['address']['longitude']) ? sprintf(
                '%s,%s',
                $data['address']['latitude'],
                $data['address']['longitude']
            ) : '',
            'published' => date('d/M/Y H:i', $data['creation_time']),
            'status' => $status,
            'image1' => $data['images'][0] ?? '',
            'image2' => $data['images'][1] ?? '',
            'image3' => $data['images'][2] ?? '',
            'source' => sprintf('post:%s', ($data['tenant'] ?? '')),
        ];

        $isPublic = $data['privacy_status'] == 'public';
        $isModerated = in_array($data['moderation_status'], ['skipped', 'accepted']);

        if ($isPublic && $isModerated) {
            return [
                'action' => 'upsert',
                'payload' => $payload,
            ];
        } else {
            return [
                'action' => 'delete',
                'payload' => $payload,
            ];
        }
    }

    public function passthroughImage($guid, $imageIndex)
    {
        try {
            $currentDataset = $this->datasetDefinition->getDataset(
                $guid,
                $this->datasetAttribute
            );
            $uid = $currentDataset->getData('uuid');
            $source = $currentDataset->getData('source');
            $imageUrl = $currentDataset->getData('image' . $imageIndex);

            if (!empty($imageUrl)) {
                if (strpos($source, 'application:') !== false
                    && strpos($imageUrl, '/api/applications/' . $uid . '/attachments/') !== false
                    && !empty(OpenPAINI::variable('StanzaDelCittadinoBridge', 'ApiUserLogin', false))) {
                    $remoteUrl = parse_url($imageUrl);
                    $scheme = $remoteUrl['scheme'];
                    $host = $remoteUrl['host'];
                    $pathParts = explode('/', $remoteUrl['path']);
                    array_shift($pathParts); // initial slash
                    $prefix = array_shift($pathParts);
                    $client = new StanzaDelCittadinoClient("$scheme://$host/$prefix");
                    $client->getBearerToken(
                        OpenPAINI::variable('StanzaDelCittadinoBridge', 'ApiUserLogin', ''),
                        OpenPAINI::variable('StanzaDelCittadinoBridge', 'ApiUserPassword', '')
                    );
                    $requestPath = '/' . implode('/', $pathParts);
                    $data = $client->request(
                        'GET',
                        $requestPath,
                        null,
                        function ($info, $headers, $body, $requestUrl) {
                            if ($info['http_code'] > 299) {
                                throw new Exception(
                                    sprintf('Request: %s - Response code: %s', $requestUrl, $info['http_code'])
                                );
                            }
                            return $body;
                        }
                    );
                } elseif (strpos($source, 'post:') !== false) {
                    $username = OpenPAINI::variable('OpensegnalazioniBridge', 'ApiUserLogin', 'username');
                    $password = OpenPAINI::variable('OpensegnalazioniBridge', 'ApiUserPassword', 'password');
                    $auth = base64_encode("$username:$password");
                    $context = stream_context_create([
                        "http" => [
                            "header" => "Authorization: Basic $auth"
                        ]
                    ]);
                    $data = file_get_contents($imageUrl, false, $context);
                } else {
                    $data = file_get_contents($imageUrl);
                }

                if (!empty($data)) {
                    $mimeType = null;
                    if (class_exists('finfo')) {
                        $finfo = new finfo(FILEINFO_MIME_TYPE);
                        $mimeType = $finfo->buffer($data);
                    }
                    header("HTTP/1.1 200 OK");
                    if ($mimeType){
                        header("Content-Type: " . $mimeType);
                    }
                    echo $data;
                    return true;
                }
            }
        } catch (Throwable $exception) {
            eZDebug::writeError($exception->getMessage(), __METHOD__);
        }

        header("HTTP/1.1 200 OK");
        $fallback = 'iVBORw0KGgoAAAANSUhEUgAAAsEAAAGQCAYAAABPi727AAAcgUlEQVR4Xu3dS4zV5RnH8ReVAdGCYMQKAVeExMTERV3VC5VYE0kQo3bE1BW4QRLF4KpWqK5MvLGsYmMkXmLrrq6sjU3spi5caFxoYrwgGECq4aao0POfRus4o06mnPnNnOdzEpOmM5znPJ/3XXxzMnNm1smTJ042DwIECBAgQIAAAQKFBGaJ4EKnbVUCBAgQIECAAIERARHsIhAgQIAAAQIECJQTEMHljtzCBAgQIECAAAECItgdIECAAAECBAgQKCcggssduYUJECBAgAABAgREsDtAgAABAgQIECBQTkAElztyCxMgQIAAAQIECIhgd4AAAQIECBAgQKCcgAgud+QWJkCAAAECBAgQEMHuAAECBAgQIECAQDkBEVzuyC1MgAABAgQIECAggt0BAgQIECBAgACBcgIiuNyRW5gAAQIECBAgQEAEuwMECBAgQIAAAQLlBERwuSO3MAECBAgQIECAgAh2BwgQIECAAAECBMoJiOByR25hAgQIECBAgAABEewOECBAgAABAgQIlBMQweWO3MIECBAgQIAAAQIi2B0gQIAAAQIECBAoJyCCyx25hQkQIECAAAECBESwO0CAAAECBAgQIFBOQASXO3ILEyBAgAABAgQIiGB3gAABAgQIECBAoJyACC535BYmQIAAAQIECBAQwe4AAQIECBAgQIBAOQERXO7ILUyAAAECBAgQICCC3QECBAgQIECAAIFyAiK43JFbmAABAgQIECBAQAS7AwQIECBAgAABAuUERHC5I7cwAQIECBAgQICACHYHCBAgQIAAAQIEygmI4HJHbmECBAgQIECAAAER7A4QIECAAAECBAiUExDB5Y7cwgQIECBAgAABAiLYHSBAgAABAgQIECgnIILLHbmFCRAgQIAAAQIERLA7QIAAAQIECBAgUE5ABJc7cgsTIECAAAECBAiIYHeAAAECBAgQIECgnIAILnfkFiZAgAABAgQIEBDB7gABAgQIECBAgEA5ARFc7sgtTIAAAQIECBAgIILdAQIECBAgQIAAgXICIrjckVuYAAECBAgQIEBABLsDBAgQIECAAAEC5QREcLkjtzABAgQIECBAgIAIdgcIECBAgAABAgTKCYjgckduYQIECBAgQIAAARHsDhAgQIAAAQIECJQTEMHljtzCBAgQIECAAAECItgdIECAAAECBAgQKCcggssduYUJECBAgAABAgREsDtAgAABAgQIECBQTkAElztyCxMgQIAAAQIECIhgd4AAAQIECBAgQKCcgAgud+QWJkCAAAECBAgQEMHuAAECBAgQIECAQDkBEVzuyC1MgAABAgQIECAggt0BAgQIECBAgACBcgIiuNyRW5gAAQIECBAgQEAEuwMECBAgQIAAAQLlBERwuSO3MAECBAgQIECAgAh2BwgQIECAAAECBMoJiOByR25hAgQIECBAgAABEewOECBAgAABAgQIlBMQweWO3MIECBAgQIAAAQIi2B0gQIAAAQIECBAoJyCCyx25hQkQIECAAAECBESwO0CAAAECBAgQIFBOQASXO3ILEyBAgAABAgQIiGB3gAABAgQIECBAoJyACC535BYmQIAAAQIECBAQwe4AAQIECBAgQIBAOQERXO7ILUyAAAECBAgQICCC3QECBAgQIECAAIFyAiK43JFbmAABAgQIECBAQAS7AwQIECBAgAABAuUERHC5I7cwAQIECBAgQICACHYHCBAgQIAAAQIEygmI4HJHbmECBAgQIECAAAER7A4QIECAAAECBAiUExDB5Y7cwgQIECBAgAABAiLYHSBAgAABAgQIECgnIILLHbmFCRAgQIAAAQIERLA7QIAAAQIECBAgUE5ABJc7cgsTIECAAAECBAiIYHeAAAECBAgQIECgnIAILnfkFiZAgAABAgQIEBDB7gABAgQIECBAgEA5ARFc7sgtTIAAAQIECBAgIILdAQIECBAgQIAAgXICIrjckVuYAAECBAgQIEBABLsDBAgQIECAAAEC5QREcLkjtzABAgQIECBAgIAIdgcIECBAgAABAgTKCYjgckduYQIECBAgQIAAARHsDhAgQIAAAQIECJQTEMHljtzCBAgQIECAAAECItgdIECAAAECBAgQKCcggssduYUJECBAgAABAgREsDtAgAABAgQIECBQTkAElztyCxMgQIAAAQIECIhgd4AAAQIECBAgQKCcgAgud+QWJkCAAAECBAgQEMHuAAECBAgQIECAQDkBEVzuyC1MgAABAgQIECAggt0BAgQIECBAgACBcgIiuNyRW5gAAQIECBAgQEAEuwMECBAgQIAAAQLlBERwuSO3MAECBAgQIECAgAh2BwgQIECAAAECBMoJiOByR25hAgQIECBAgAABEewOECBAgAABAgQIlBMQweWO3MIECBAgQIAAAQIi2B0gQIAAAQIECBAoJyCCyx25hQkQIECAAAECBESwO0CAAAECBAgQIFBOQASXO3ILEyBAgAABAgQIiGB3gAABAgQIECBAoJyACC535BYmQIAAAQIECBAQwe4AAQIECBAgQIBAOQERXO7ILUyAAAECBAgQICCC3QECBAgQIECAAIFyAiK43JFbmAABAgQIECBAQAS7AwQIECBAgAABAuUERHC5I7cwAQIECBAgQICACHYHCBAgQIAAAQIEygmI4HJHbmECBAgQIECAAAER7A4QIECAAAECBAiUExDB5Y7cwgQIECBAgAABAiLYHSBAgAABAgQIECgnIILLHbmFCRAgQIAAAQIERLA7QIAAAQIECBAgUE5ABJc7cgsTIECAAAECBAiIYHeAAAECBAgQIECgnIAILnfkFiZAgAABAgQIEBDB7gABAgQIECBAgEA5ARFc7sgtTIAAAQIECBAgIILdAQIECBAgQIAAgXICIrjckVuYAAECBAgQIEBABLsDBAgQIECAAAEC5QREcLkjtzABAgQIECBAgIAIdgcIECBAgAABAgTKCYjgckduYQIECBAgQIAAARHsDhAgQIAAAQIECJQTEMHljtzCBAgQIECAAAECItgdIECAAAECBAgQKCcggssduYUJECBAgAABAgREsDtAgAABAgQIECBQTkAElztyCxMgQIAAAQIECIhgd4AAAQIECBAgQKCcgAgud+QWJkCAAAECBAgQEMHuAAECBAgQIECAQDkBEVzuyC1MgAABAgQIECAggt0BAgQIECBAgACBcgIiuNyRW5gAAQIECBAgQEAEuwMECBAgQIAAAQLlBERwuSO3MAECBAgQIECAgAh2BwgQIECAAAECBMoJiOByR25hAgQIECBAgAABEewOECBAgAABAgQIlBMQweWO3MIECBAgQIAAAQIi2B0gQIAAAQIECBAoJyCCyx25hQkQIECAAAECBESwO0CAAAECBAgQIFBOQASXO3ILEyBAgAABAgQIiGB3gAABAlMg8OWXX7Zjx461L774os2aNavNmTNn5L+hoaEpmG4EAQIECHxfQAS7EwQIEOiDwIkTJ9rBgwfb3r1726efftY+++zTtm/f/pH/77TTZrVzzz23LVq0qJ1zzsK2fPnytnTpknbGGWf04ZV4SgIECBAYT0AEuxcECBA4hQJfffVVL3w/bu+//3577bV/tVde+Ud7++23R94BHu/RvRO8Zs2ads01v26XXHJJW7x48Sl8NZ6KAAECBH5IQAS7GwQIEDhFAidPnmz79+9vjzzySHv55b+3AwcOTPiZ586d2zZs2NBuu21jmz9//oT/nW8kQIAAgckJiODJuflXBAgQGCPQ/QjEW2+91dauvW5SOvPmzWv33PO7duONN/rRiEkJ+kcECBCYuIAInriV7yRAgMCPCvxUBHe/ENe943v8+PH29ddfj3mu7utLly5tzz33bFuyZAltAgQIEOijgAjuI66nJkCglsD3I7iL2oULF7bzzz+/nX322e2ss+a18847r/fLcf9uH3zwQXvnnXfGAHXf99BDD7arr766Fp5tCRAgMMUCIniKwY0jQGBwBb6J4OuuW9e6H21YsWJFu+yyX/b+u6wtW7a8F8OLe58McVrvl+SOt1dffbVt27at7dmzZxTImWee2TZt2tRuv33T4ELZjAABAtNAQARPg0PwEggQGAyBLoLffffdduedW0Y+6WF4+Dft4osvHne5o0ePtgcffKg9+eSTo77efXbw8PBw275922Cg2IIAAQLTVEAET9OD8bIIEJh5At2nQxw5crS9+eab7dJLf9FOP/30H1ziyJEj7f7772/PP//nMe8Eb9lyZ9u4cePMA/CKCRAgMIMERPAMOiwvlQCBwRDofinujTfeGHnHuPvZ4O8+5s//WXv88Z0jEe1BgAABAv0TEMH9s/XMBAgQGCPQ/cjEe++91x544IH20kt/G/X17ueFL7roorZr1662YIHPCnZ9CBAg0E8BEdxPXc9NgACB7wh0Ady987tz5872zDPPjrLpPkniggt+3rZuvbutWze5zxmGTYAAAQITFxDBE7fynQQIEJi0QBfAH374YS+An2hPP/30mABetGhRu+WW9W3z5s1t9uzZk57jHxIgQIDAxARE8MScfBcBAgQmLdD9wtzevR+3xx77Y3vqqV3jBvC6devaXXdtad1HpHkQIECAQP8FRHD/jU0gQKC4wOHDh9sTT/yp7dixY9wAvv76de2OO+7o/TGNs4pLWZ8AAQJTJyCCp87aJAIECgp0nwTx+uuvtw0bNrRDhw5/K9D9DPCCBQvaDTfc0LqPROv+uIYHAQIECEydgAieOmuTCBAoKHDs2LH26KM7eh979vio7YeGhtratWt7fzXuXu8AF7wXViZAIC8ggvNn4BUQIDDAAocOHer9CeTNI38m+buP7hfhXnjhL+3CCy8c4O2tRoAAgekrIIKn79l4ZQQIDIDAwYMH27XXrmn79u37dpvu84BXrlzZXnzxrwOwoRUIECAwMwVE8Mw8N6+aAIEZINB9KsSePXva5ZdfMerVDg3N7oXxte3hhx+eAVt4iQQIEBhMARE8mOdqKwIEpoFAF8HdZwOvWvWrUa9mzpw57aabbmr33feHafAqvQQCBAjUFBDBNc/d1gQITIHAfyN4dy+CV42J4JtvHu79Uty2KXgVRhAgQIDAeAIi2L0gQIBAnwS6CD5w4EDvI9C2tN7//PbR/UW41atXt1tv/W2fJntaAgQIEPgpARH8U0K+ToAAgf9DoAvh7hMiuj+b/M2j+4zguXPntu7HIjwIECBAICMggjPuphIgUETg888/73082j972/7vreDu0yGWLVvWVqxYUUTBmgQIEJh+AiJ4+p2JV0SAwIAIdO8Cf/TRR+2KK64ctVH3DvD69evbvff+fkA2tQYBAgRmnoAInnln5hUTIDBDBH7s0yGGh4fb9u1+MW6GHKWXSYDAAAqI4AE8VCsRIDA9BETw9DgHr4IAAQLjCYhg94IAAQJ9EhDBfYL1tAQIEDgFAiL4FCB6CgIECIwn0EXw7t2725VXrhr1ZT8T7L4QIEAgLyCC82fgFRAgMKACXQR/8sknbevWu0dt2P3Z5KuuWt26P5jhQYAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhkBEZxxN5UAAQIECBAgQCAoIIKD+EYTIECAAAECBAhkBERwxt1UAgQIECBAgACBoIAIDuIbTYAAAQIECBAgkBEQwRl3UwkQIECAAAECBIICIjiIbzQBAgQIECBAgEBGQARn3E0lQIAAAQIECBAICojgIL7RBAgQIECAAAECGQERnHE3lQABAgQIECBAICgggoP4RhMgQIAAAQIECGQERHDG3VQCBAgQIECAAIGggAgO4htNgAABAgQIECCQERDBGXdTCRAgQIAAAQIEggIiOIhvNAECBAgQIECAQEZABGfcTSVAgAABAgQIEAgKiOAgvtEECBAgQIAAAQIZARGccTeVAAECBAgQIEAgKCCCg/hGEyBAgAABAgQIZAREcMbdVAIECBAgQIAAgaCACA7iG02AAAECBAgQIJAREMEZd1MJECBAgAABAgSCAiI4iG80AQIECBAgQIBARkAEZ9xNJUCAAAECBAgQCAqI4CC+0QQIECBAgAABAhmB/wCnoLcq4Az2gQAAAABJRU5ErkJggg==';
        header("Content-Type: image/png");
        echo base64_decode($fallback);
        return false;
    }
}
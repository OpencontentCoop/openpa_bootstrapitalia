<?php

/**
 * @see https://docs.google.com/spreadsheets/d/1c_-K3IPdyfYVutWRVl775rIv8GzQhsBHxf7zqxyxjHA/edit#gid=0
 */
class OpenAgendaTopicMapper
{
    public static function generateTopicQueryFilter(eZContentObject $websiteTopic, $openagendaVersion)
    {
        $useName = version_compare((string)$openagendaVersion, '2.0.3', 'gt') or
        OpenPAINI::variable('OpenpaAgenda', 'UseTopicMapper', 'enabled') === 'disabled';

        if ($useName) {
            $topicsFilter = 'topics.name = "' . addcslashes($websiteTopic->attribute('name'), "')(") . '"';
        } else {
            $remoteTopicIdList = OpenAgendaTopicMapper::findTopicRemoteIdList($websiteTopic);
            if (empty($remoteTopicIdList)) {
                return false;
            }
            $topicsFilter = "raw[submeta_topics___remote_id____ms] in ['" . implode("','", $remoteTopicIdList) . "']";
        }

        return $topicsFilter;
    }

    public static function findTopicRemoteIdList(eZContentObject $websiteTopic): array
    {
        $name = trim($websiteTopic->attribute('name'));
        $agendaIdList = [];
        if (in_array($name, self::$agendaToWebsite)) {
            foreach (self::$agendaToWebsite as $agendaName => $websiteName) {
                if ($websiteName === $name && isset(self::$agenda[$agendaName])) {
                    $agendaIdList[] = self::$agenda[$agendaName];
                }
            }
        }

        return $agendaIdList;
    }

    private static $agendaToWebsite = [
        "Abitazione" => "Casa",
        "Acqua" => "Acqua",
        "Acquisizione di conoscenza" => "Istruzione",
        "Animale domestico" => "Animale domestico",
        "Anziano" => "Politica sociale",
        "Area di parcheggio" => "Parcheggi",
        "Associazione" => "Associazioni",
        "Comune" => "Comunicazione istituzionale",
        "Comunicazione" => "Comunicazione istituzionale",
        "Condizioni e organizzazione del lavoro" => "Lavoro",
        "Cultura" => "Patrimonio culturale",
        "Edificio urbano" => "Urbanizzazione",
        "Energia" => "Energia",
        "Famiglia" => "Politica familiare",
        "Fanciullo" => "Politica della gioventù",
        "Formazione professionale" => "Formazione professionale",
        "Gestione dei rifiuti" => "Gestione rifiuti",
        "Giovane" => "Politica della gioventù",
        "Immigrazione" => "Immigrazione",
        "Imprese e attività produttive" => "Economia",
        "Informatica e trattamento dei dati" => "Accesso all'informazione",
        "Inquinamento" => "Inquinamento",
        "Integrazione sociale" => "Integrazione sociale",
        "Istruzione" => "Istruzione",
        "Matrimonio" => "Matrimonio",
        "Procedura elettorale e voto" => "Elezioni",
        "Programma d'azione" => "Programma d'azione",
        "Protezione sociale" => "Integrazione sociale",
        "Salute" => "Politica sociale",
        "Sicurezza internazionale" => "Relazioni internazionali",
        "Sicurezza pubblica" => "Sicurezza pubblica",
        "Spazio verde" => "Spazio verde",
        "Sport" => "Sport",
        "Studente" => "Istruzione",
        "Tempo libero" => "Tempo libero",
        "Traffico urbano" => "Traffico urbano",
        "Trasporto" => "Trasporto pubblico",
        "Trasporto stradale" => "Rete stradale",
        "Turismo" => "Turismo",
        "Urbanistica ed edilizia" => "Urbanizzazione",
    ];

    private static $agenda = [
        "Abitazione" => "topic_1",
        "Acqua" => "topic_2",
        "Acquisizione di conoscenza" => "topic_3",
        "Animale domestico" => "topic_4",
        "Anziano" => "topic_5",
        "Area di parcheggio" => "topic_6",
        "Associazione" => "topic_7",
        "Comune" => "cf8eb21cf8b5c6743ae1caa2bc050c88",
        "Comunicazione" => "topic_9",
        "Condizioni e organizzazione del lavoro" => "topic_10",
        "Cultura" => "bd5192a42244b7e5a0dc4ac0830bce83",
        "Edificio urbano" => "topic_12",
        "Energia" => "topic_13",
        "Famiglia" => "2eb5ffa8cfbb467dee3026fd6ab7464c",
        "Fanciullo" => "topic_15",
        "Formazione professionale" => "topic_16",
        "Gestione dei rifiuti" => "topic_17",
        "Giovane" => "topic_18",
        "Immigrazione" => "topic_19",
        "Imprese e attività produttive" => "dfa6ed0f6ceeddbc718c6280e53b9385",
        "Informatica e trattamento dei dati" => "topic_20",
        "Inquinamento" => "topic_21",
        "Integrazione sociale" => "topic_22",
        "Istruzione" => "topic_23",
        "Matrimonio" => "topic_24",
        "Procedura elettorale e voto" => "fe63739f7047ad84533d1055c9380444",
        "Programma d'azione" => "topic_26",
        "Protezione sociale" => "topic_27",
        "Salute" => "topic_28",
        "Sicurezza internazionale" => "topic_29",
        "Sicurezza pubblica" => "topic_30",
        "Spazio verde" => "topic_31",
        "Sport" => "topic_32",
        "Studente" => "topic_33",
        "Tempo libero" => "fc5ef422eef5373ea6019423b5ad55a0",
        "Traffico urbano" => "topic_35",
        "Trasporto" => "topic_36",
        "Trasporto stradale" => "topic_37",
        "Turismo" => "158a858d0fe4b8a9d0fe5d50c3605cb2",
        "Urbanistica ed edilizia" => "topic_39",
    ];

    private static $website = [
        "Accesso all'informazione" => "30308859ca4274ad266ae1b38666ae1e",
        "Acqua" => "topic_2",
        "Agricoltura" => "topic_2_agricoltura",
        "Agricoltura, silvicoltura e pesca" => "topic_1_agricoltura_e_alimentazione",
        "Ambiente" => "topic_1_ambiente",
        "Animale domestico" => "topic_4",
        "Aria" => "17722a57fb20ca1210125d2bdd8323ec",
        "Assistenza agli invalidi" => "topic_3_assistenza_agli_invalidi",
        "Assistenza sociale" => "topic_3_assistenza_sociale",
        "Associazioni" => "topic_7",
        "Biblioteca" => "f85cb496baed09fae468f041ae275a37",
        "Bilancio" => "topic_2_costi_bilanci_spese_dell_ente",
        "Casa" => "topic_1",
        "Catasto" => "topic_2_catasto",
        "Città intelligente" => "topic_2_citta_intelligente",
        "Commercio al minuto" => "6df6d993b921ba5585b2c992b3ab4d5e",
        "Commercio all'ingrosso" => "9e9c6c0a4f25bad956def349e7ba7548",
        "Commercio ambulante" => "91bc19e1e6201bcb0a246791bad4d888",
        "Comunicazione istituzionale" => "topic_9",
        "Comunicazione politica" => "topic_2_politica",
        "Comunità europea" => "topic_2_comunita_europea",
        "Concorsi" => "topic_2_impiego_nella_pa",
        "Covid-19" => "topic_2_covid_19",
        "Dati aperti" => "topic_20",
        "Demografia" => "topic_24",
        "Demografia e popolazione" => "topic_1_popolazione_e_societa",
        "Diritto" => "topic_1_giustizia_sistema_giuridico_e_sicurezza_pubblica",
        "Economia" => "topic_1_economia_e_finanze",
        "Elezioni" => "fe63739f7047ad84533d1055c9380444",
        "Energia" => "topic_13",
        "Energie rinnovabili" => "topic_2_energia_rinnovabile",
        "Estero" => "901ac93a6d4baaa901cc17ac155101ca",
        "Foreste" => "topic_2_foreste",
        "Formazione professionale" => "topic_16",
        "Gemellaggi" => "topic_2_gemellaggi",
        "Gestione rifiuti" => "topic_17",
        "Giustizia" => "03247490a219ea48d754b8ffe0218429",
        "Igiene pubblica" => "0b43588c71719126304e8aaae9e6438d",
        "Immigrazione" => "topic_19",
        "Imposte" => "topic_2_tributi",
        "Imprese" => "dfa6ed0f6ceeddbc718c6280e53b9385",
        "Innovazione" => "topic_1_scienza_e_tecnologia",
        "Inquinamento" => "topic_21",
        "Integrazione sociale" => "topic_22",
        "Isolamento termico" => "ff27f221bb1a1105319f758da98f1005",
        "Istruzione" => "topic_1_istruzione_cultura_e_sport",
        "Lavori pubblici" => "topic_3_lavori_pubblici",
        "Lavoro" => "topic_10",
        "Matrimonio" => "520467b8e456dd71a0df06701267ec62",
        "Mercato" => "7a508ac8d8ede77941d382c758a99042",
        "Mobilità sostenibile" => "d5ffcb9ed91fa49cfdc42a7ee6fb4d81",
        "Morte" => "a01a8345c4dd069454bd23f4a131b8ec",
        "Nascita" => "2585c8de2079feb3db29f85d3293de15",
        "Parcheggi" => "topic_6",
        "Patrimonio culturale" => "bd5192a42244b7e5a0dc4ac0830bce83",
        "Pesca" => "2b67071267460acb651dab78c5937290",
        "Pianificazione del territorio" => "topic_1_territorio",
        "Piano di sviluppo" => "9642f556d5f52562385a6ff83f342b78",
        "Pista ciclabile" => "64e2943f2b139bbe825a1ec700cb24fc",
        "PNRR - Piano nazionale di ripresa e resilienza" => "9ae5cd81473dfde92d2a5048fcd52e7e",
        "Politica" => "topic_1_governo_e_settore_pubblico",
        "Politica commerciale" => "82f3daf9f172801c57f13d95000facfb",
        "Politica della gioventù" => "topic_15",
        "Politica familiare" => "2eb5ffa8cfbb467dee3026fd6ab7464c",
        "Polizia" => "topic_3_polizia",
        "Prima infanzia" => "f85de55bbafcd80eeed201a2d99d2351",
        "Prodotti alimentari" => "303df154b15e47f7986343c30ba57637",
        "Programma d'azione" => "topic_26",
        "Protezione civile" => "087e4fb8eb71d06eb6edbfe6aaee6ecf",
        "Protezione delle minoranze" => "topic_3_protezione_delle_minoranze",
        "PUMS - Piano Urbano della Mobilità Sostenibile" => "8e282dbec5f654adac4396391cbc25bf",
        "Questioni sociali" => "18e6e1013c2999465c05b2ad41b364cf",
        "Relazioni internazionali" => "topic_1_tematiche_internazionali",
        "Residenza" => "a600b3fb2825c2e6c688c4bde8c3f961",
        "Rete stradale" => "topic_37",
        "Ricerca" => "topic_2_ricerca",
        "Risparmio energetico" => "topic_2_risparmio_energetico",
        "Risposta alle emergenze" => "c60b70f9d0f4bcb8dd1c0ff34ac90d16",
        "Scuola materna" => "6b101d7978a415884679d24a9afcec17",
        "Sicurezza pubblica" => "topic_30",
        "Sistema giuridico" => "468a42f92ac4acd1543f830f630fe1dd",
        "Spazio verde" => "topic_31",
        "Sport" => "topic_32",
        "Sviluppo sostenibile" => "f9646a846cd5c0cc94e576fe3250d502",
        "Tassa sui servizi" => "0dfc780404e1e86d3013c942f812e262",
        "Tempo libero" => "6b9adcbc7ca00d48590c2c0122d45873",
        "Traffico urbano" => "topic_35",
        "Trasparenza amministrativa" => "0afb9385587fd6f9fdff39d9dd5e3142",
        "Trasporto pubblico" => "topic_36",
        "Turismo" => "158a858d0fe4b8a9d0fe5d50c3605cb2",
        "Urbanizzazione" => "topic_39",
        "Viaggi" => "6c62b4913df2ea2b739dae5cc04f70da",
        "Vita istituzionale" => "topic_2_vita_istituzionale",
        "Volontariato" => "topic_2_volontariato",
        "Zone pedonali" => "fdfafe70890f994101c6a56d9928ef69",
        "ZTL" => "abc9ab5b22d6f4a06ba477b75dafd075",
    ];

    public static function migrateAgendaTopicNames($logToCli = true)
    {
        $cli = $logToCli ? eZCLI::instance() : false;

        $mergeDuplicates = [];
        foreach (self::$agenda as $name => $remoteId) {
            $newName = self::$agendaToWebsite[$name] ?? false;
            if ($newName) {
                $object = eZContentObject::fetchByRemoteID($remoteId);
                if ($object instanceof eZContentObject) {
                    $mergeDuplicates[$newName][] = $object->mainNodeID();
                    if ($object instanceof eZContentObject) {
                        if ($cli) {
                            $cli->output("$name => $newName");
                        }
                        if ($object->attribute('name') != $newName) {
                            eZContentFunctions::updateAndPublishObject($object, [
                                'attributes' => [
                                    'name' => $newName,
                                ],
                            ]);
                        }
                    }
                }
            }
        }
        foreach ($mergeDuplicates as $name => $nodeIdList) {
            $countNodeIdList = count($nodeIdList);
            if ($countNodeIdList > 1) {
                if ($cli) {
                    $cli->output("Merge $countNodeIdList duplicates of $name");
                }
                $masterNodeId = array_shift($nodeIdList);
                foreach ($nodeIdList as $slaveNodeId) {
                    try {
                        $mergeTool = new \Opencontent\Installer\MergeTool((int)$masterNodeId, (int)$slaveNodeId);
                        $mergeTool->run();
                    } catch (Throwable $e) {
                        if ($cli) {
                            $cli->error($e->getMessage());
                        }
                    }
                }
            }
        }
    }

}
<?php
require 'autoload.php';

$script = eZScript::instance(array('description' => ("OpenPA Warmup tagtree\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true));

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();
$languageList = eZINI::instance()->variable('RegionalSettings', 'SiteLanguageList');

try {
    $avoidDuplicates = [];
    $classIds = eZContentClass::fetchIDListContainingDatatype(eZTagsType::DATA_TYPE_STRING);
    if (count($classIds) > 0) {
        foreach ($classIds as $id) {
            $class = eZContentClass::fetch($id);
            /** @var eZContentClassAttribute $classAttribute */
            foreach ($class->dataMap() as $classAttribute) {
                if ($classAttribute->attribute('data_type_string') == eZTagsType::DATA_TYPE_STRING) {
                    $root = (int)$classAttribute->attribute(eZTagsType::SUBTREE_LIMIT_FIELD);
                    $view = $classAttribute->attribute(eZTagsType::EDIT_VIEW_FIELD);
                    if ($root > 0 && !isset($avoidDuplicates[$root]) && $view == 'Tree') {
                        foreach ($languageList as $language){
                            eZContentLanguage::setPrioritizedLanguages([$language]);
                            $cli->output($class->attribute('identifier') . '/' . $classAttribute->attribute('identifier') . ' ' . $root . ' ' . $language);
                            ezjscCachedTags::tree([$root]);
                        }
                        eZContentLanguage::clearPrioritizedLanguages();
                        $avoidDuplicates[$root] = true;
                    }
                }
            }
        }
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
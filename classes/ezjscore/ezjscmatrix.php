<?php

class ezjscMatrix extends ezjscServerFunctionsNode
{
    static public function addRows($args)
    {
        [$id, $version, $language, $addCount] = $args;
        $contentObjectAttribute = eZContentObjectAttribute::fetch($id, $version);
        if (!$contentObjectAttribute instanceof eZContentObjectAttribute) {
            throw new Exception('Not found');
        }
        if (!$contentObjectAttribute->object()->canEdit()) {
            throw new Exception('Forbidden');
        }
        $matrix = $contentObjectAttribute->content();
        $matrix->Cells = eZHTTPTool::instance()->postVariable('data', []);
        $addCount = (int)$addCount;
        if ($addCount > 0 && $addCount <= 40) {
            $matrix->addRow(false, $addCount);
            $contentObjectAttribute->setAttribute('data_text', $matrix->xmlString());
            $matrix->decodeXML($contentObjectAttribute->attribute('data_text'));
        }
        $contentObjectAttribute->setContent($matrix);
        $contentObjectAttribute->store();
        $tpl = eZTemplate::factory();
        $tpl->setVariable("attribute", $contentObjectAttribute);

        $content = $tpl->fetch('design:content/datatype/edit/ezmatrix_table.tpl');
        $content = trim(preg_replace(['/\s{2,}/', '/[\t\n]/'], ' ', $content));
        header('Content-Type: text/html');
        echo $content;
        eZExecution::cleanExit();
    }

    static public function removeRows($args)
    {
        [$id, $version, $language] = $args;
        $contentObjectAttribute = eZContentObjectAttribute::fetch($id, $version);
        if (!$contentObjectAttribute instanceof eZContentObjectAttribute) {
            throw new Exception('Not found');
        }
        if (!$contentObjectAttribute->object()->canEdit()) {
            throw new Exception('Forbidden');
        }
        $matrix = $contentObjectAttribute->content();
        $matrix->Cells = eZHTTPTool::instance()->postVariable('data', []);

        $arrayRemove = eZHTTPTool::instance()->postVariable('remove', []);
        rsort($arrayRemove);
        foreach ($arrayRemove as $rowNum) {
            $matrix->removeRow($rowNum);
        }
        $contentObjectAttribute->setContent($matrix);
        $contentObjectAttribute->store();

        $tpl = eZTemplate::factory();
        $tpl->setVariable("attribute", $contentObjectAttribute);

        $content = $tpl->fetch('design:content/datatype/edit/ezmatrix_table.tpl');
        $content = trim(preg_replace(['/\s{2,}/', '/[\t\n]/'], ' ', $content));
        header('Content-Type: text/html');
        echo $content;
        eZExecution::cleanExit();
    }
}
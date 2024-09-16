<?php

/** @var array $Params */

$datasetGuid = $Params['DatasetGuid'];
$imageIndex = $Params['Index'];

CollectInefficiency::instance()->passthroughImage($datasetGuid, $imageIndex);
eZExecution::cleanExit();
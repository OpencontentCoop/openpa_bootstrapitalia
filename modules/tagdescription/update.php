<?php

/** @var eZModule $Module */
/** @var array $Params */

$Module = $Params['Module'];
$http = eZHTTPTool::instance();

$tagID = (int)$Params['TagID'];
$locale = (string)$Params['Locale'];

$currentUser = eZUser::currentUser();
$tagsEditResult = $currentUser->hasAccessTo('tags', 'read');
if ($tagsEditResult['accessWord'] != 'yes') {
    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}

$tag = eZTagsObject::fetchWithMainTranslation($tagID);
if (!$tag instanceof eZTagsObject) {
    return $Module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

if ($Module->isCurrentAction('Store') && $http->hasPostVariable('TagDescriptionText')){
    $descriptionText = $http->postVariable('TagDescriptionText', '');
    $tagDescription = new eZTagsDescription([
        'keyword_id' => $tagID,
        'locale' => $locale,
        'description_text' => $descriptionText
    ]);
    $tagDescription->store();
}

$Module->redirectTo('tags/id/' . $tagID);
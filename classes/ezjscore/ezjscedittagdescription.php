<?php

class ezjscEditTagDescription extends ezjscTags
{
    static public function edit($args)
    {
        $tagID = $args[0];
        $locale = $args[1];
        $viewObjectID = $args[2];
        $descriptionText = trim(eZHTTPTool::instance()->postVariable('text', ''));
        $access = eZUser::currentUser()->hasAccessTo('bootstrapitalia', 'edit_tag_description');
        if ($access['accessWord'] == 'yes'){
            $tagDescription = new eZTagsDescription([
                'keyword_id' => $tagID,
                'locale' => $locale,
                'description_text' => $descriptionText
            ]);
            $tagDescription->store();

            eZContentCacheManager::clearContentCache($viewObjectID);

            echo json_encode([
                'result' => 'success',
                'text' => $descriptionText,
                'tag' => $tagID
            ]);
        }else {
            echo json_encode([
                'result' => 'error',
                'tag' => $tagID
            ]);
        }

        eZExecution::cleanExit();
    }
}
<?php

class ezjscSSO extends ezjscTags
{
    static public function profile()
    {
        return eZSDCSSOHandler::getCurrentProfile();
    }
}
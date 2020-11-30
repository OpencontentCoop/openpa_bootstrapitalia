<?php

interface OpenPABootstrapitaliaAutoRegistrableInterface
{
    public function canAutoRegister();

    public function onRegister(OCEditorialStuffPost $post);
}
<?php

$Module = [
    'name' => 'manifest.json',
];

$ViewList = [];

$ViewList[''] = [
    'script'                    => 'manifest.php',
    'params'                    => ['path'],
    'functions'                 => ['view'],
    'ui_context'                => 'json',
    'default_navigation_part'   => false,
];
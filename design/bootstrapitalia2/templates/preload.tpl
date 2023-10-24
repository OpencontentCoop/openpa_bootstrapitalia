<link rel="preconnect" href="https://static.opencityitalia.it">

{if fetch('user','current_user').is_logged_in|not()}
{*{preload_script($footer_script_loader)}*}
{/if}

{*{preload_css($footer_css_loader)}*}

<link rel="preload" as="style" href="{concat('stylesheets/', $theme,'.css')|ezdesign(no)|shared_asset()}"/>
{*<link rel="preload" as="script" href="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign('no')|shared_asset()}" />*}

<link rel="preload" href="https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.woff2" as="font" type="font/woff2" crossorigin>
{*<link rel="preload" href="https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-regular.woff2" as="font" type="font/woff2" crossorigin>*}
<link rel="preload" href="https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.woff2" as="font" type="font/woff2" crossorigin>
{*<link rel="preload" href="https://static.opencityitalia.it/fonts/Lora/lora-v20-latin-ext_latin-regular.woff2" as="font" type="font/woff2" crossorigin>*}
<link rel="preload" href="https://static.opencityitalia.it/fonts/Roboto_Mono/roboto-mono-v13-latin-ext_latin-700.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="https://static.opencityitalia.it/fonts/Roboto_Mono/roboto-mono-v13-latin-ext_latin-regular.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-600.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300italic.woff2" as="font" type="font/woff2" crossorigin>

{if is_set($module_result.content_info.persistent_variable.preload_images)}{foreach $module_result.content_info.persistent_variable.preload_images as $image}
    <link rel="preload" as="image" href="{$image}" />
{/foreach}{/if}

<link rel="preload" href="https://static.opencityitalia.it/fonts/FontAwesome/fontawesome-webfont.woff2?v=4.7.0" as="font" type="font/woff2" crossorigin>
{*<link rel="preload" href="{sprite_svg_href()}" as="image" type="image/svg+xml" />*}
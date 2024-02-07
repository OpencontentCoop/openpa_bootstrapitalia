<!doctype html>
<html lang="{$site.http_equiv.Content-language|wash}">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    {include uri='design:page_head.tpl'}
    <link rel="stylesheet" href="{concat('stylesheets/', current_theme(),'.css')|ezdesign(no)}" media="all"/>
    <style>#debug{ldelim}display:none !important{rdelim}html, body {ldelim}height: 100%;background:#f0f0f1{rdelim}</style>
    {ezcss_load(array('common.css'))}
    {ezscript_load(array('ezjsc::jquery','ezjsc::jqueryio','moment-with-locales.min.js','jquery.opendataTools.js','chosen.jquery.js'))}
</head>
<body class='d-flex align-items-center py-4' style="overflow-x: hidden">
    <div class="form-signin w-100 m-auto text-center p-5">
        <h4 class="text-center">{ezini('SiteSettings', 'SiteName')}</h4>
        {$module_result.content}
        <div class='text-center mt-3'>
            <a class="text-decoration-none" href="https://{ezini('SiteSettings', 'SiteURL')}">
                ← {'Return to site'|i18n( 'design/ocbootstrap/collectedinfo/form' )}
            </a>
        </div>
    </div>
    <script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )}"></script>
    <script>window.__PUBLIC_PATH__ = "https://static.opencityitalia.it/fonts";bootstrap.loadFonts()</script>
</body>
{* This comment will be replaced with actual debug report (if debug is on). *}
<!--DEBUG_REPORT-->
</html>

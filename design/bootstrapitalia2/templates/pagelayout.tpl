<!doctype html>
<html lang="{$site.http_equiv.Content-language|wash}">
<head>
    {if is_set( $extra_cache_key )|not}
        {def $extra_cache_key = ''}
    {/if}

    {if openpacontext().is_homepage}
        {set $extra_cache_key = concat($extra_cache_key, 'homepage')}
    {/if}

    {if openpacontext().is_login_page}
        {set $extra_cache_key = concat($extra_cache_key, 'login')}
    {/if}

    {if openpacontext().is_edit}
        {set $extra_cache_key = concat($extra_cache_key, 'edit')}
    {/if}

    {if openpacontext().is_area_tematica}
        {set $extra_cache_key = concat($extra_cache_key, 'areatematica_', openpacontext().is_area_tematica)}
    {/if}

    {def $has_valuation = '0'}
    {if or(and(is_set($module_result.content_info.persistent_variable.show_valuation),$module_result.content_info.persistent_variable.show_valuation),openpacontext().is_search_page)}
        {set $has_valuation = '1'}
    {/if}
    {def $current_built_in_app = ''}
    {if is_set($module_result.content_info.persistent_variable.built_in_app)}
        {set $current_built_in_app = $module_result.content_info.persistent_variable.built_in_app}
    {/if}

    {def $theme = current_theme()
         $has_container = cond(is_set($module_result.content_info.persistent_variable.has_container), true(), false())
         $has_section_menu = cond(is_set($module_result.content_info.persistent_variable.has_section_menu), true(), false())
         $has_sidemenu = cond(and(is_set($module_result.content_info.persistent_variable.has_sidemenu), $module_result.content_info.persistent_variable.has_sidemenu), true(), false())
         $avail_translation = language_switcher( $site.uri.original_uri )}

    {debug-accumulator id=page_head name=page_head}
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Language" content="{$site.http_equiv.Content-language|wash}">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    {no_index_if_needed()}
    {include uri='design:page_head.tpl' canonical_url=openpacontext().canonical_url}
    {/debug-accumulator}

    {cache-block expiry=86400 ignore_content_expiry keys=array( 'favicon' )}
    {def $pagedata = openpapagedata()}
    {include uri="design:favicon.tpl"}
    {undef $pagedata}
    {/cache-block}

    {debug-accumulator id=page_head_style name=page_head_style}
    {include uri='design:page_head_style.tpl'}
    {/debug-accumulator}

    {debug-accumulator id=page_head_script name=page_head_script}
    {include uri='design:page_head_script.tpl'}
    {include uri='design:page_head_google_tag_manager.tpl'}
    {include uri='design:page_head_google-site-verification.tpl'}
    {/debug-accumulator}

</head>

<body>

<div class="skiplink">
    <a class="visually-hidden-focusable" href="#main-container">Vai ai contenuti</a>
    <a class="visually-hidden-focusable" href="#footer">Vai al footer</a>
</div>

{if and(openpacontext().is_edit|not(),openpacontext().is_browse|not())}
    {cache-block expiry=86400 ignore_content_expiry keys=array( $access_type.name, $extra_cache_key, openpaini('GeneralSettings','theme', 'default') )}
        {debug-accumulator id=page_header_and_offcanvas_menu name=page_header_and_offcanvas_menu}
        {def $pagedata = openpapagedata()}
        {include uri='design:page_notifications.tpl'}
        {include uri='design:page_header.tpl'}
        {undef $pagedata}
    {/debug-accumulator}
    {/cache-block}
{/if}

<main>
    {if openpacontext().show_breadcrumb}
        {debug-accumulator id=breadcrumb name=breadcrumb has_sidemenu=$has_sidemenu has_container=$has_container}
        {include uri='design:breadcrumb.tpl' path_array=openpacontext().path_array}
        {/debug-accumulator}
    {/if}

    {if $has_container|not()}<div class="container px-4 my-4"{if openpacontext().show_breadcrumb|not()} id="main-container"{/if}>{/if}
        {include uri='design:page_mainarea.tpl'}
    {if $has_container|not()}</div>{/if}

</main>

{if and(openpacontext().is_login_page|not(), openpacontext().is_edit|not())}
    {debug-accumulator id=page_footer name=page_footer}
    {cache-block expiry=86400 ignore_content_expiry keys=array( $access_type.name, $has_valuation, $current_built_in_app)}
    {def $pagedata = openpapagedata()}
        {include uri='design:page_extra.tpl'}
        {include uri='design:page_footer.tpl'}
    {undef $pagedata}
    {/cache-block}
{/debug-accumulator}
{/if}

{include uri='design:page_footer_script.tpl'}

{include uri='design:parts/load_global_website_toolbar.tpl' current_user=fetch(user, current_user)}

</body>

</html>
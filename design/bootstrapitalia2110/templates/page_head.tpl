
{default enable_help=true() enable_link=true() canonical_link=true()}

{if is_set($module_result.content_info.persistent_variable.site_title)}
    {set scope=root site_title=$module_result.content_info.persistent_variable.site_title}
{else}
{let name=Path
     path=$module_result.path
     reverse_path=array()}
  {if is_set(openpacontext().path_array)}
    {set path=openpacontext().path_array}
  {elseif is_set($module_result.title_path)}
    {set path=$module_result.title_path}
  {/if}
  {section loop=$:path}
    {set reverse_path=$:reverse_path|array_prepend($:item)}
  {/section}

{set-block scope=root variable=site_title}
{if and(is_set($module_result.node_id), $module_result.node_id|eq(ezini( 'NodeSettings', 'RootNode', 'content.ini' )))}{*
  *}{$site.title|wash}{*
*}{else}{*
  *}{$Path:reverse_path[0].text|wash()} - {$site.title|wash}{*
*}{/if}
{/set-block}

{/let}
{/if}
    <title>{$site_title}</title>

    {if and(is_set($#Header:extra_data),is_array($#Header:extra_data))}
      {section name=ExtraData loop=$#Header:extra_data}
      {$:item}
      {/section}
    {/if}

    {* check if we need a http-equiv refresh *}
    {if $site.redirect}
    <meta http-equiv="Refresh" content="{$site.redirect.timer}; URL={$site.redirect.location}" />
    {/if}

    {foreach $site.http_equiv as $key => $item}
        <meta name="{$key|wash}" content="{$item|wash}" />

    {/foreach}

    {if is_set($module_result.content_info.persistent_variable.opengraph)}
        {foreach $module_result.content_info.persistent_variable.opengraph as $key => $value}
            {if is_array($value)}
                {foreach $value as $v}
                    <meta property="{$key}" content="{$v|wash()}" />
                {/foreach}
            {else}
                <meta property="{$key}" content="{$value|wash()}" />
            {/if}
        {/foreach}
    {/if}

    {include uri='design:page_head_meta.tpl'}

{if $canonical_link}
    {include uri="design:canonical_link.tpl"}
{/if}

{if $enable_link}
    {include uri="design:link.tpl" enable_help=$enable_help enable_link=$enable_link enable_print=false()}
{/if}

{include uri="design:alternate.tpl"}

{/default}

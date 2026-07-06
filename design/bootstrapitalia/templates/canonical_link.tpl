{if openpacontext().canonical_url}
    {* Multiple locations, pointing Search Engines to the original *}
    {def $canonical_href = openpacontext().canonical_url}
    {if and(is_set($module_result.view_parameters.offset), $module_result.view_parameters.offset|gt(0))}
        {set $canonical_href = concat($canonical_href, '/(offset)/', $module_result.view_parameters.offset)}
    {/if}
    <link rel="canonical" href="{$canonical_href|ezurl('no','full')}" />
    {undef $canonical_href}
{/if}

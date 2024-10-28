{def $openpa = object_handler($node)}
{include uri="design:openpa/full/_classification.tpl"}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{ezpagedata_set('is_homepage', false())}
{ezpagedata_set('show_valuation', false())}

{undef $openpa}
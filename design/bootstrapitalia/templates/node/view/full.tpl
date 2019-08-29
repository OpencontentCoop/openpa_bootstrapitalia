{def $openpa = object_handler($node)}
{include uri=$openpa.control_template.full}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{if module_params().function_name|ne('versionview')}
    {include uri='design:parts/load_website_toolbar.tpl' current_user=fetch(user, current_user)}
{/if}

{def $homepage = fetch('openpa', 'homepage')}
{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{if and( openpaini('GeneralSettings','valutation', 1), $homepage.node_id|ne($node.node_id), $node.class_identifier|ne('frontpage'), $node.class_identifier|ne('homepage') ) }
    {include name=valuation node_id=$node.node_id uri='design:openpa/valuation.tpl'}
{/if}
{undef $openpa}
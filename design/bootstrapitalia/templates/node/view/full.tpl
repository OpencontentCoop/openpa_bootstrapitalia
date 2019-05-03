{def $openpa = object_handler($node)}
{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}

{include uri=$openpa.control_template.full}

{include uri='design:parts/load_website_toolbar.tpl' current_user=fetch(user, current_user)}

{def $homepage = fetch('openpa', 'homepage')}
{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
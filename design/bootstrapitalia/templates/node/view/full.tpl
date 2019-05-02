{def $openpa = object_handler($node)}
{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}
{include uri='design:parts/load_website_toolbar.tpl' current_user=fetch(user, current_user)}
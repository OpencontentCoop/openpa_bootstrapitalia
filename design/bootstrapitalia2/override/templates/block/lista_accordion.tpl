{def $openpa = object_handler($block)}

{if $openpa.has_content}
{include uri='design:parts/block_name.tpl'}
{include uri='design:atoms/accordion.tpl' items=$openpa.content}
{include uri='design:parts/block_show_all.tpl'}
{/if}

{undef $openpa}
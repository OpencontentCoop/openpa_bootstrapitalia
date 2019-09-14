{def $openpa = object_handler($block)}

{if $openpa.has_content}
{include uri='design:parts/block_name.tpl'}
<div class="container">
    {include uri='design:atoms/accordion.tpl' items=$openpa.content}
</div>
{/if}

{undef $openpa}
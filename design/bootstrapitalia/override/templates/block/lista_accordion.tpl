{def $openpa = object_handler($block)}

{include uri='design:parts/block_name.tpl'}
<div class="container">
    {include uri='design:atoms/accordion.tpl' items=$openpa.content}
</div>


{undef $openpa}
{def $openpa = object_handler($block)}

<div class="container">
    {include uri='design:parts/block_name.tpl'}
    {include uri='design:atoms/accordion.tpl' items=$openpa.content}
</div>


{undef $openpa}
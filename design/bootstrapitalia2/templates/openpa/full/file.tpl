{ezpagedata_set( 'has_container', true() )}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h2 class="h4 py-2">{$node|attribute('short_title').content|wash()}</h2>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {attribute_view_gui attribute=$node|attribute('file') wide=true()}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>


{*<section class="container">
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</section>*}

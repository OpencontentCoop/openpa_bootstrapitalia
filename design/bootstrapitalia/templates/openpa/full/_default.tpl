{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'narrow_container', true() )}

<section id="intro">
    <div class="container">
        <div class="row">
            <div class="offset-lg-1 col-lg-6 col-md-7">
                <div class="section-title">

                    <h2>{$node.name|wash()}</h2>

                    {if is_set( $openpa.content_main.parts.abstract )}
                        {attribute_view_gui attribute=$openpa.content_main.parts.abstract.contentobject_attribute}
                    {/if}

                </div>
            </div>
            <div class="offset-lg-1 col-lg-3 offset-lg-1 offset-md-1 col-md-4">
                {include uri='design:openpa/full/parts/actions.tpl'}
                {include uri='design:openpa/full/parts/taxonomy.tpl'}
            </div>
        </div>

        {include uri='design:openpa/full/parts/date.tpl'}

    </div>
</section>

{include uri='design:openpa/full/parts/main_image.tpl'}

{include uri='design:openpa/full/parts/attributes.tpl'}

{node_view_gui content_node=$node view=children view_parameters=$view_parameters}
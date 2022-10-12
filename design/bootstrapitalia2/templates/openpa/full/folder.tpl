{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

<div class="container">
    <div class="row justify-content-center row-shadow">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-4 pb-lg-60">
                        <h1 class="text-black hero-title" data-element="page-name">{$node.name|wash()}</h1>
                        <div class="hero-text">
                            {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            {if $node|has_attribute('description')}
                                {attribute_view_gui attribute=$node|attribute('description')}
                            {/if}
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>

{include uri='design:parts/children/default.tpl' view_variation='py-5' view_parameters=$view_parameters}
{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}


<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white d-block">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-4">
                        <h1 class="text-black hero-title" data-element="page-name">
                            {$node.name|wash()}
                        </h1>
                        <div class="hero-text">
                            {include uri='design:openpa/full/parts/main_attributes.tpl'}
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>

{if $node|has_attribute('image')}
    {include uri='design:openpa/full/parts/main_image.tpl'}
{/if}

{if $node|has_attribute('description')}
    <section class="page-description">
        <div class="container">
            <div class="row justify-content-center{if $first_block_has_bg|not()} pb-lg-60 row-shadow{/if}">
                <div class="col-12 col-lg-10">
                    {attribute_view_gui attribute=$node|attribute('description')}
                </div>
            </div>
        </div>
    </section>
{/if}

{if $node|has_attribute('layout')}
    {attribute_view_gui attribute=$node|attribute('layout')}
{else}
    {def $block = page_block(
        '',
        "OpendataRemoteContents",
        "datatable",
        openpaini('ClassificationPages', $node.object.remote_id, array())
    )}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', array($block)))}
    {undef $block}
{/if}


{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

{def $parent_openpa = object_handler($node.parent)}
{if and($parent_openpa.content_tag_menu.has_tag_menu, $node|has_attribute('type'))}
    {ezpagedata_set( 'current_view_tag_keyword', $node|attribute('type').content.tags[0].keyword )}
{/if}

<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-heading pb-3 pb-lg-4">
                <div class="row">
                    <div class="col-lg-8">
                        <h1 class="title-xxxlarge" data-element="service-title">{$node.name|wash()}</h1>
                        {include uri='design:openpa/full/parts/service_status.tpl'}
                        {include uri='design:openpa/full/parts/main_attributes.tpl'}
                        {include uri='design:openpa/full/parts/service_access_button.tpl'}
                    </div>
                    <div class="col-lg-3 offset-lg-1 mt-5 mt-lg-0">
                        {include uri='design:openpa/full/parts/actions.tpl'}
                        {include uri='design:openpa/full/parts/taxonomy.tpl'}
                    </div>
                </div>
            </div>
        </div>
        {if $node|has_attribute('image')|not()}
        <hr class="d-none d-lg-block mt-2">
        {/if}
    </div>
</div>


{include uri='design:openpa/full/parts/main_image.tpl'}

<div class="container">
{include uri='design:openpa/full/parts/attributes_alt.tpl' object=$node.object}
</div>

{if $openpa['content_tree_related'].full.exclude|not()}
{include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}

{undef $parent_openpa}
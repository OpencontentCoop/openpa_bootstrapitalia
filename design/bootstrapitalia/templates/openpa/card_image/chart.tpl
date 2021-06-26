{set_defaults(hash('image_class', 'large', 'view_variation', ''))}
<div class="it-grid-item-wrapper it-grid-item-overlay {$node|access_style}">
    <a class="" title="{$node.name|wash()}" {if $view_variation|eq('gallery')}data-gallery href={$node|attribute('image').content.reference.url|ezroot}{else}href="{$openpa.content_link.full_link}"{/if}>
        <div class="img-responsive-wrapper {if and($node|has_attribute('image'), $node|attribute('image')|ne('occhart'))}bg-dark{/if}">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {if $node|has_attribute('image')}
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
                    {else}
                        <div style="min-height:300px">
                            {attribute_view_gui attribute=$node|attribute('chart') ratio="16:9" show_legend=false() show_export=false() responsive=true()}
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </a>
</div>
{unset_defaults(array('image_class', 'view_variation'))}
{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
        {set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
    {/if}
    {undef $image}
{/if}
<div class="section section-muted p-0 py-5 useful-links-section position-relative">
    <div class="block-bg bg-secondary h-100 lazyload" {if $background_image}{include name="bg" uri='design:atoms/background-image.tpl' url=$background_image options="background-position: center"}{/if}></div>
    <div class="container{if and(count($block.valid_nodes)|eq(0), $background_image)} py-5{/if}">
        <div class="row d-flex justify-content-center">
            <div class="col-12 col-lg-6">
                <div class="cmp-input-search">
                    <form action="{'/content/search/'|ezurl(no)}" method="get" class="form-group autocomplete-wrapper{if $background_image|not()} mb-2 mb-lg-4{/if}">
                        <div class="input-group">
                            <label for="autocomplete-autocomplete-three" class="visually-hidden">{'Search'|i18n('design/base')}</label>
                            <input type="search" class="autocomplete form-control" placeholder="{$block.name|wash()}" id="autocomplete-autocomplete-three" name="autocomplete-three" data-bs-autocomplete="[]" data-focus-mouse="false">

                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit" id="button-3">{'Search'|i18n('design/base')}</button>
                            </div>

                            <span class="autocomplete-icon" aria-hidden="true">
                                {display_icon('it-search', 'svg', 'icon icon-sm icon-primary', 'Search'|i18n('design/base'))}
                            </span>
                        </div>
                    </form>
                </div>
                {if count($block.valid_nodes)|gt(0)}
                <div class="link-list-wrapper bg-white p-3 position-relative">
                    <div class="link-list-heading text-uppercase mb-3 ps-0">{'Useful links'|i18n( 'bootstrapitalia' )}</div>
                    <ul class="link-list" role="list">
                        {foreach $block.valid_nodes as $valid_node}
                        <li role="listitem">
                            {node_view_gui content_node=$valid_node a_class="list-item mb-3 active ps-0" span_class="text-button-normal" view=text_linked show_icon=true()}
                        </li>
                        {/foreach}
                    </ul>
                </div>
                {/if}
            </div>
        </div>
    </div>
</div>
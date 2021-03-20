{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
        {set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
    {/if}
    {undef $image}
{/if}
<div class="py-5 position-relative">
    <div class="block-topics-bg bg-secondary h-100" {if $background_image}style="background-image: url({$background_image});background-position: center"{/if}></div>
    <div class="container">
        <div class="container py-5">
            <div class="row">
                <div class="col col-sm-10 offset-sm-1 col-md-8 offset-md-2">
                    <form action="{'/content/search/'|ezurl(no)}" method="get">
                        <div class="input-group mb-3">
                            <label for="block-search-input-{$block.id}" class="sr-only">
                                {'Search'|i18n('design/base')}
                            </label>
                            <input type="text"
                                   autocomplete="off"
                                   id="block-search-input-{$block.id}"
                                   name="SearchText"
                                   class="form-control rounded-left"
                                   placeholder="{$block.name|wash()}">
                            <div class="input-group-append">
                                <button class="btn btn-outline-secondary" type="submit" id="block-search-button-{$block.id}" aria-label="{$block.name|wash()}">
                                    {display_icon('it-search', 'svg', 'icon icon-sm')} <span class="sr-only">{'Search'|i18n('design/base')}</span>
                                </button>
                            </div>
                        </div>
                    </form>
                    {foreach $block.valid_nodes as $valid_node}
                        {node_view_gui content_node=$valid_node a_class="btn btn-primary btn-sm mt-3 text-nowrap" view=text_linked}
                    {/foreach}
                </div>
            </div>
        </div>
    </div>
</div>
{undef $background_image}
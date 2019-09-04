{if count($block.valid_nodes)|gt(0)}
{def $valid_node = $block.valid_nodes[0]}
{def $openpa = object_handler($valid_node)}
<div class="singolo-container {$valid_node|access_style}">

    <div class="singolo-image-container d-lg-flex align-items-stretch flex-nowrap">
        <div class="singolo-placeholder d-none d-lg-block flex-lg-fill"></div>
        <div class="singolo-image flex-lg-fill bg-dark">
            {include uri='design:atoms/image.tpl' node=$valid_node figure_wrapper=false() image_css_class='of-md-cover' fluid=true()}
        </div>
    </div>

    <div class="singolo-text p-2 pr-4">

        <div class="mt-5">
            {include uri='design:openpa/card/parts/category.tpl' view_variation='alt' show_icon=true() node=$valid_node}
        </div>

        <h2 class="mt-0 mb-4">
            <a href="{$openpa.content_link.full_link}" title="Link a {$valid_node.name|wash()}" class="text-primary">
                {$valid_node.name|wash()}
            </a>
        </h2>
        <div class="card-text mb-5">
            {include uri='design:openpa/full/parts/main_attributes.tpl' node=$valid_node}            
        </div>

        {include uri='design:openpa/full/parts/taxonomy.tpl' node=$valid_node show_title=false()}

        <a class="read-more mt-5" href="{$openpa.content_link.full_link}">
            <span class="text">{if $openpa.content_link.is_internal}Leggi di più{else}Visita{/if}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>

    </div>

</div>
{undef $valid_node $openpa}
{/if}
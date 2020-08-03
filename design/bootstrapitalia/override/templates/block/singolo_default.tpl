{if count($block.valid_nodes)|gt(0)}
    {def $valid_node = $block.valid_nodes[0]}
    {def $openpa = object_handler($valid_node)}

    {def $has_image = false()}
    {foreach class_extra_parameters($valid_node.object.class_identifier, 'table_view').main_image as $identifier}
        {if $valid_node|has_attribute($identifier)}
            {set $has_image = true()}
            {break}
        {/if}
    {/foreach}

    {def $has_video = false()
         $oembed = false()}
    {if $valid_node|has_attribute('video')}
        {set $has_video = $valid_node|attribute('video').content}
    {elseif $valid_node|has_attribute('has_video')}
        {set $has_video = $valid_node|attribute('has_video').content}
    {/if}
    {if $has_video}
        {set $oembed = get_oembed_object($has_video)}
        {if is_array($oembed)|not()}
            {set $has_video = false()}
        {/if}
    {/if}

    <div class="singolo-container {$valid_node|access_style}">


        {if or($has_image, $has_video)}
        <div class="singolo-image-container d-lg-flex align-items-stretch flex-nowrap">
            <div class="singolo-placeholder d-none d-lg-block flex-lg-fill"></div>
            {if $has_video}
                <div class="singolo-image flex-lg-fill video-wrapper">{$oembed.html}</div>
            {elseif $has_image}
                <div class="singolo-image flex-lg-fill bg-dark"
                     style="background-image:url('{include uri='design:atoms/image_url.tpl' node=$valid_node}'); background-position: center center;background-repeat: no-repeat;background-size: cover;min-height:200px"></div>
            {/if}
        </div>
        {/if}

        <div class="singolo-text p-2 pr-4{if and($has_image|not(), $has_video|not())} mw-100{/if}">

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
                <span class="text">{if $openpa.content_link.is_node_link}Leggi di più{else}Visita{/if}</span>
                {display_icon('it-arrow-right', 'svg', 'icon')}
            </a>

            {if and($openpa.content_link.is_node_link|not(), $valid_node.can_edit)}
                <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$valid_node.url_alias|ezurl(no)}">
                    <span class="fa-stack">
                      <i class="fa fa-circle fa-stack-2x"></i>
                      <i class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                    </span>
                </a>
            {/if}
        </div>

    </div>
    {undef $valid_node $openpa}
{/if}
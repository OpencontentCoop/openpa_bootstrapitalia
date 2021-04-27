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

    <section id="head-section {$valid_node|access_style}">
        <div class="container">
            <div class="row">
                {if or($has_image, $has_video)}
                    <div class="col-lg-6 offset-lg-1 order-lg-2">
                        {if $has_video}
                            <div class="singolo-image flex-lg-fill video-wrapper">{$oembed.html}</div>
                        {elseif $has_image}
                            <img src="{include uri='design:atoms/image_url.tpl' node=$valid_node}" alt="{include uri='design:atoms/image_alt.tpl' node=$valid_node}" class="mw-100 of-lg-cover singolo_default">
                        {/if}
                    </div>
                {/if}
                <div class="{if and($has_image|not(), $has_video|not())}col{else}col-lg-5 order-lg-1{/if}">
                    <div class="card">
                        <div class="card-body pb-5">

                            {include uri='design:openpa/card/parts/category.tpl' view_variation='alt' show_icon=true() node=$valid_node}

                            <h1 class="h4 card-title">
                                <a href="{$openpa.content_link.full_link}" title="Link a {$valid_node.name|wash()}" class="text-primary text-decoration-none">
                                    {$valid_node.name|wash()}
                                </a>
                            </h1>

                            <div class="card-text mb-3">
                                {include uri='design:openpa/full/parts/main_attributes.tpl' node=$valid_node dates_container_class=false()}
                            </div>
                            {include uri='design:openpa/full/parts/taxonomy.tpl' node=$valid_node show_title=false() container_class='pb-3'}

                            <a class="read-more pb-5 pt-4" href="{$openpa.content_link.full_link}#page-content">
                                <span class="text">{if $openpa.content_link.is_node_link}{'Read more'|i18n('bootstrapitalia')}{else}{'Visit'|i18n('bootstrapitalia')}{/if}</span>
                                {display_icon('it-arrow-right', 'svg', 'icon')}
                            </a>

                            {if and($openpa.content_link.is_node_link|not(), $valid_node.can_edit)}
                                <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$valid_node.url_alias|ezurl(no)}">
                                    <span class="fa-stack">
                                      <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                                      <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                                    </span>
                                </a>
                            {/if}

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {undef $valid_node $openpa}
{/if}
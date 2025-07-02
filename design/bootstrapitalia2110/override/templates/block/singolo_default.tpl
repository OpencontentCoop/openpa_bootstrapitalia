{if count($block.valid_nodes)|gt(0)}
    {def $valid_node = $block.valid_nodes[0]}

    {if and($valid_node.class_identifier|eq('dataset'), $valid_node|has_attribute('csv_resource'))}

        {include uri='design:parts/block_name.tpl' css_class="pb-0 mb-0"}

        <div class="row">
            <div class="col">
                {attribute_view_gui attribute=$valid_node|attribute('csv_resource')}
            </div>
        </div>

    {else}

        {def $openpa = object_handler($valid_node)}

        {def $has_image = false()}
        {foreach class_extra_parameters($valid_node.object.class_identifier, 'table_view').main_image as $identifier}
            {if $valid_node|has_attribute($identifier)}
                {set $has_image = true()}
                {break}
            {/if}
        {/foreach}

        {def $video = false()
             $has_video = false()
             $oembed = false()}
        {if $valid_node|has_attribute('video')}
          {set $video = $valid_node|attribute('video')}
        {elseif $valid_node|has_attribute('has_video')}
          {set $video = $valid_node|attribute('has_video')}
        {/if}
        {set $has_video = cond($video, $video.content, false())}
        {if $has_video}
            {set $oembed = get_oembed_object($has_video)}
            {if is_array($oembed)|not()}
                {set $has_video = false()}
            {/if}
        {/if}

        {if openpaini('ViewSettings', 'ShowTitleInSingleBlock')|eq('enabled')}
          {include uri='design:parts/block_name.tpl'}
        {elseif $block.name|ne('')}
          <h2 class="visually-hidden">{$block.name|wash()}</h2>
        {else}
          <h2 class="visually-hidden">{$valid_node.name|wash()}</h2>
        {/if}
        <div class="{$valid_node|access_style}">
            <div class="row {if $block.custom_attributes.color_style|ne('')} shadow-sm border border-light rounded{/if}">
                <div class="col{if or($has_image, $has_video)}-lg-6 order-2 order-lg-1{/if} {if $block.custom_attributes.color_style|ne('')}px-0{/if}">
                    <div class="card h-100 rounded {if $block.custom_attributes.color_style|eq('')}mb-5{/if}">
                        <div class="card-body pb-5">
                            {include uri='design:openpa/card/parts/category.tpl' view_variation='alt' show_icon=true() node=$valid_node}
                            <h3 class="card-title">
                                <a href="{$openpa.content_link.full_link}"
                                  class="text-decoration-none">
                                    {$valid_node.name|wash()}
                                </a>
                            </h3>
                            <div class="mb-4 pt-3 lora">{include uri='design:openpa/full/parts/main_attributes.tpl' node=$valid_node dates_container_class='' avoid_oembed=true()}</div>
                            {include uri='design:openpa/full/parts/taxonomy.tpl' node=$valid_node show_title=false() container_class=''}
                            <a class="read-more {if $block.custom_attributes.color_style|eq('')}mb-5{else}mb-3{/if}" href="{$openpa.content_link.full_link}#page-content">
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
                {if or($has_image, $has_video)}
                <div class="col-lg-6 order-1 order-lg-2 px-0 d-lg-flex align-items-stretch flex-nowrap">
                    {if $has_video}
                      <div class="flex-lg-fill bg-white">
                        {include uri='design:parts/video.tpl' video=$video}
                      </div>
                    {elseif $has_image}
                        {include name="img" uri='design:atoms/img.tpl' set_max_dimensions=false() node=$valid_node image_class=reference style="overflow: hidden;object-fit: cover;" classes='flex-lg-fill bg-dark d-none d-lg-flex h-100' preload=false()}
                        {include name="img" uri='design:atoms/img.tpl' node=$valid_node image_class=imagelargeoverlay style="overflow: hidden;object-fit: cover;height:250px;width:100%" classes='img-fluid d-block d-lg-none' alias='small' height=250}
                    {/if}
                </div>
                {/if}
            </div>
        </div>
        {undef $openpa $video $has_video $oembed}
    {/if}
    {undef $valid_node}
{/if}
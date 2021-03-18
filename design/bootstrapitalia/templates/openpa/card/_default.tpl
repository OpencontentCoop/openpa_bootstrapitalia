{set_defaults(hash('show_icon', true(), 'image_class', 'large', 'view_variation', ''))}

{if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('show_icon')}
    {set $show_icon = true()}
{/if}

{def $has_image = false()}
{foreach class_extra_parameters($node.object.class_identifier, 'table_view').main_image as $identifier}
    {if and($node|has_attribute($identifier), or($node|attribute($identifier).data_type_string|eq('ezimage'), $identifier|eq('image')))}
        {set $has_image = true()}
        {break}
    {/if}
{/foreach}

{def $has_video = false()}
{if $view_variation|ne('big')}
    {def $oembed = false()}
    {if $node|has_attribute('video')}
        {set $has_video = $node|attribute('video').content}
    {elseif $node|has_attribute('has_video')}
        {set $has_video = $node|attribute('has_video').content}
    {/if}
    {if $has_video}
        {set $oembed = get_oembed_object($has_video)}
        {if is_array($oembed)|not()}
            {set $has_video = false()}
        {/if}
    {/if}
{/if}

{def $has_media = false()}
{if or($has_image, $has_video)}
    {set $has_media = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {include uri='design:openpa/card/parts/image.tpl'}

    {include uri='design:openpa/card/parts/icon.tpl'}

    <div class="card-body">

        {include uri='design:openpa/card/parts/category.tpl'}

        {include uri='design:openpa/card/parts/card_title.tpl'}

        {include uri='design:openpa/card/parts/abstract.tpl'}            

        <a class="read-more" href="{$openpa.content_link.full_link}#main-content">
            <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>

    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{undef $has_image $has_video}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
{set_defaults(hash('show_icon', true(), 'image_class', 'imagelargeoverlay', 'view_variation', ''))}

{def $has_media = false()}
{if $node|has_attribute('image')}
    {set $has_media = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {include uri='design:openpa/card/parts/image.tpl'}

    <div class="col-{if $has_media}8{else}12{/if} order-1 order-md-2">
        <div class="card-body pb-5">

                {include uri='design:openpa/card/parts/category.tpl'}

                {include uri='design:openpa/card/parts/card_title.tpl'}

                {include uri='design:openpa/card/parts/abstract.tpl'}

                <a class="read-more" href="{$openpa.content_link.full_link}#page-content">
                    <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
                    {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
                </a>

        </div>
    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
{set_defaults(hash('show_icon', true(), 'image_class', 'large', 'view_variation', ''))}

{if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('show_icon')}
    {set $show_icon = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {include uri='design:openpa/card/parts/image.tpl'}

    {include uri='design:openpa/card/parts/icon.tpl'}

    <div class="card-body">

        {include uri='design:openpa/card/parts/category.tpl'}

        {include uri='design:openpa/card/parts/card_title.tpl'}

        {include uri='design:openpa/card/parts/abstract.tpl'}            

        <a class="read-more" href="{$openpa.content_link.full_link}">
            <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>

    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
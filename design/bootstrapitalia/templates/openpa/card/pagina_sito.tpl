{set_defaults(hash('show_icon', true(), 'image_class', 'large', 'view_variation', ''))}

{def $has_media = false()}
{if $node|has_attribute('image')}
    {set $has_media = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {include uri='design:openpa/card/parts/image.tpl'}

    {include uri='design:openpa/card/parts/icon.tpl'}

    <div class="card-body">

        {include uri='design:openpa/card/parts/category.tpl'}

        {include uri='design:openpa/card/parts/card_title.tpl'}        

        {include uri='design:openpa/card/parts/abstract.tpl'}      

        <a class="read-more" href="{$openpa.content_link.full_link}#page-content">
            <span class="text">{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|wash()}{else}{'Go to page'|i18n('bootstrapitalia')}{/if}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>

    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
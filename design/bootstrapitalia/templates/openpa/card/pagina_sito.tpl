{set_defaults(hash('show_icon', true(), 'image_class', 'medium', 'view_variation', ''))}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {include uri='design:openpa/card/parts/image.tpl'}

    {include uri='design:openpa/card/parts/icon.tpl'}

    <div class="card-body">

        {include uri='design:openpa/card/parts/category.tpl'}

        {include uri='design:openpa/card/parts/card_title.tpl'}        

        {include uri='design:openpa/card/parts/abstract.tpl'}      

        <a class="read-more" href="{$openpa.content_link.full_link}">
            <span class="text">{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|wash()}{else}Vai alla pagina{/if}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>

    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
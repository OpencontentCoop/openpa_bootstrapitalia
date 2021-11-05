{set_defaults(hash('show_icon', false(), 'image_class', 'large', 'view_variation', ''))}
{def $has_media = false()}

<div data-object_id="{$node.contentobject_id}" class="shared_link-card card-wrapper {if or($view_variation|eq('big'),$view_variation|eq('alt'))}card-space{/if} {$node|access_style}">
    <div class="card {if $has_media} card-img{/if} {if $view_variation|eq('alt')}rounded shadow{/if} {if $view_variation|eq('big')}card-bg {if $has_media|not()}card-big{/if} rounded shadow{/if}">

        <div class="card-body">

            {include uri='design:openpa/card/parts/card_title.tpl'}

            <a data-shared_link="{$node.contentobject_id}" data-shared_link_view="card" class="read-more" href="{$openpa.content_link.full_link}#page-content">
                <span class="text">{'Further details'|i18n('bootstrapitalia')}</span>
                {display_icon('it-external-link', 'svg', 'icon')}
            </a>

        </div>

    </div>
</div>

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}

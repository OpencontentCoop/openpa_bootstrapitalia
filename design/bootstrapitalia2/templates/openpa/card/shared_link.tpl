{def $has_media = false()}
{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}
<div class="col-{if $has_media}8{else}12{/if} order-1 order-md-2">
    <div class="card-body">
        <a data-shared_link="{$node.contentobject_id}" data-shared_link_view="card" target="_blank" rel="noopener noreferrer" class="read-more" href="{$openpa.content_link.full_link}#page-content">
            <span class="text">{'Further details'|i18n('bootstrapitalia')}</span>
            {display_icon('it-external-link', 'svg', 'icon')}
        </a>
    </div>
</div>
{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}


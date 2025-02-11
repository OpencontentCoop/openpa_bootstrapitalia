<div data-object_id="{$node.contentobject_id}" class="shared_link-card_teaser card card-teaser shadow {$node|access_style} rounded {$view_variation}">
    <div class="card-body">
        <h5 class="card-title mb-1">
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
        </h5>
        <div class="card-text">
            <p class="mt-3">
                <a data-shared_link="{$node.contentobject_id}"
                  data-shared_link_view="card_teaser"
                  target="_blank"
                  rel="noopener noreferrer"
                  href="{$openpa.content_link.full_link}">
                    {'Further details'|i18n('bootstrapitalia')}
                    {display_icon('it-external-link', 'svg', 'icon icon-sm')}
                </a>
            </p>
        </div>
    </div>
</div>

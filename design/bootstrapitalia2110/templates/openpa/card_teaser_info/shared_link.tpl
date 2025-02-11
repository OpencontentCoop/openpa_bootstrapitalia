{set_defaults(hash(
    'attribute_index', 0,
    'view_variation', ''
))}
<div data-object_id="{$node.contentobject_id}" class="shared_link-card_teaser font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 {if $view_variation|eq('auto_width')|not()}card-teaser-info-width {/if} mt-0 mb-3 {$view_variation}" style="z-index: {100|sub($attribute_index)}">
    <div class="card-body">
        <p class="card-title text-paragraph-regular-medium-semi mb-3">
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
        </p>
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

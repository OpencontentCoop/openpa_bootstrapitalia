<div data-object_id="{$content.guid}"
     class="card-wrapper h-100 border border-light rounded shadow-sm {if $content.image} cmp-list-card-img {/if} cmp-list-card-img-hr">
    <div class="card no-after rounded bg-white">
        <div class="row g-2 g-md-0 flex-md-column">
            {if $content.image}
            <div class="col-4 order-2 order-md-1 position-relative">
                <img class="rounded-top img-fluid img-responsive" src="{$content.image}" />
            </div>
            {/if}
            <div class="col-{if $content.image}8{else}12{/if} order-1 order-md-2">
                <div class="card-body pb-5">
                    <div class="category-top cmp-list-card-img__body">
                        <a class="text-decoration-none fw-bold cmp-list-card-img__body-heading-title" href="{$content.source_uri}">
                            {$content.source_name|wash()}
                        </a>
                    </div>
                    <h3 class="card-title{if $content.image|not()} big-heading{/if}">
                        <a class="text-decoration-none" href="{$content.uri}">{$content.name|wash()}</a>
                    </h3>
                    {if $content.abstract}
                    <div class="card-text pb-3 d-none d-md-block">
                        {$content.abstract}
                    </div>
                    {/if}

                    <a class="read-more" href="{$content.uri}">
                        <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
                        {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
                    </a>

                </div>
            </div>
        </div>
    </div>
</div>
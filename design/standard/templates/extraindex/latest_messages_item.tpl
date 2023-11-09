<div id="{$content.guid}" class="cmp-card-latest-messages mb-3 mb-30">
    <div class="card shadow-sm px-4 pt-4 pb-4 rounded">
        <span class="visually-hidden">{'Categoria'|i18n('bootstrapitalia')}:</span>
        <div class="card-header border-0 p-0">
            <a class="text-decoration-none title-xsmall-bold mb-2 category text-uppercase" href="{$content.source_uri}">
                {$content.source_name|wash()}
            </a>
        </div>
        <div class="card-body p-0 my-2">
            <h3 class="green-title-big t-primary mb-8"><a href="{$content.uri}" class="text-decoration-none">{$content.name|wash()}</a></h3>
            {if $content.abstract}<p class="text-paragraph">{$content.abstract}</p>{/if}
        </div>
    </div>
</div>
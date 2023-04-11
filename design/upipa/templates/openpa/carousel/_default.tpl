<div class="it-hero-wrapper it-dark it-overlay">
    {include uri='design:openpa/carousel/parts/image.tpl'}
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-hero-text-wrapper bg-dark">
                    <h1>{$node.name|wash()}</h1>
                    {if $node|has_abstract()}
                        <p class="d-none d-lg-block">{$node|abstract()|openpa_shorten(300)}</p>
                    {/if}
                    <div class="it-btn-container"><a class="btn btn-sm btn-secondary" href="{$openpa.content_link.full_link}">{'Read more'|i18n('ocbootstrap')}</a></div>
                </div>
            </div>
        </div>
    </div>
</div>
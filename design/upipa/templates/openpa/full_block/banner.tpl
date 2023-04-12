<div class="it-hero-wrapper {if $openpa.content_link.is_node_link|not()}it-dark {/if}it-overlay position-relative">
    {include uri='design:openpa/carousel/parts/image.tpl'}
    {if $openpa.content_link.is_node_link|not()}
        <div class="it-hero-text-wrapper bg-dark">
            <h1>{$node.name|wash()}</h1>
            {if $node|has_abstract()}
                <p class="d-none d-lg-block">{$node|abstract()|openpa_shorten(300)}</p>
            {/if}
            <div class="it-btn-container"><a class="btn btn-sm btn-secondary" href="{$openpa.content_link.full_link}">{'Read more'|i18n('ocbootstrap')}</a></div>
        </div>
    {else}
        <p class="text-white position-absolute font-weight-bold text-sans-serif" style="bottom:5px; left: 20px">{$node.name|wash()}</p>
    {/if}
</div>
<div class="cmp-card-latest-messages mb-3 mb-30">
    <div class="card shadow-sm px-4 pt-4 pb-4 rounded">
        {if $node|has_attribute('type')}
        <span class="visually-hidden">{'Categoria'|i18n('bootstrapitalia')}:</span>
        <div class="card-header border-0 p-0">
            {foreach $node|attribute('type').content.tags as $tag}
                <a class="text-decoration-none title-xsmall-bold mb-2 category text-uppercase" href="{concat( '/tags/view/', $tag.url )|explode('tags/view/tags/view')|implode('tags/view')|ezurl(no)}">
                    {$tag.keyword|wash}
                </a>
            {/foreach}
        </div>
        {/if}
        <div class="card-body p-0 my-2">
            <h3 class="green-title-big t-primary mb-8"><a href="{$openpa.content_link.full_link}" class="text-decoration-none" data-element="{$openpa.data_element.value}">{$node.name|wash()}</a></h3>
            {if $node|has_abstract()}<p class="text-paragraph">{$node|abstract()}</p>{/if}
        </div>
    </div>
</div>
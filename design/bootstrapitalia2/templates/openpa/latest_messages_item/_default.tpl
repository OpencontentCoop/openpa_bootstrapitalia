<div class="cmp-card-latest-messages mb-3 mb-30">
    <div class="card shadow-sm px-4 pt-4 pb-4 rounded">
        {if $openpa.content_icon.context_icon}
        <span class="visually-hidden">{'Categoria'|i18n('bootstrapitalia')}:</span>
        <div class="card-header border-0 p-0">
            <a class="text-decoration-none title-xsmall-bold mb-2 category text-uppercase" href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}">
                {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$openpa.content_icon.context_icon.node.name}
            </a>
        </div>
        {/if}
        <div class="card-body p-0 my-2">
            <h3 class="green-title-big mb-8"><a href="{$openpa.content_link.full_link}" class="text-decoration-none" data-element="{$openpa.data_element.value}">{$node.name|wash()}</a></h3>
            {if $node|has_abstract()}<p class="text-paragraph">{$node|abstract()}</p>{/if}
            {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
                <a href="{$node.url_alias|ezurl(no)}">
                    <span class="fa-stack">
                      <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                      <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                    </span>
                </a>
            {/if}
        </div>
    </div>
</div>
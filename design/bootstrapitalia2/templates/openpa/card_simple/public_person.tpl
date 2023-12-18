<div class="cmp-card-simple card-wrapper pb-0 rounded bg-white border border-light">
    <div class="card shadow-sm rounded">
        <div class="card-body">
            {if or($openpa.data_element.value|eq('live-button-locations'), $openpa.data_element.value|eq('live-button-events'))}
                <button type="button"
                        href="{$openpa.content_link.full_link}"
                        onclick="location.href = '{$openpa.content_link.full_link}';"
                        data-element="{$openpa.data_element.value|wash()}"
                        class="card-title t-primary title-xlarge p-0">
                    <span>
                         {$node.name|wash()}
                    </span>
                </button>
            {else}
                <a href="{$openpa.content_link.full_link}#page-content" data-element="{$openpa.data_element.value|wash()}" class="text-decoration-none">
                    <h3 class="card-title t-primary title-xlarge">
                        {$node.data_map.given_name.content|wash()} {$node.data_map.family_name.content|wash()}
                        {include uri='design:parts/card_title_suffix.tpl'}
                        {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
                            <a href="{$node.url_alias|ezurl(no)}">
                                <span class="fa-stack">
                                  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                                  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                                </span>
                            </a>
                        {/if}
                    </h3>
                </a>
            {/if}
            <div class="m-0">
                {def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
                {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
                {undef $attributes}
            </div>
        </div>
    </div>
</div>

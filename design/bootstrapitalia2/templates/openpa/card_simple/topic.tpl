<div class="cmp-card-simple card-wrapper pb-0 rounded bg-white border border-light">
    <div class="card shadow-sm rounded">
        <div class="card-body">
            <a href="{$openpa.content_link.full_link}#page-content" data-element="{$openpa.data_element.value|wash()}" class="text-decoration-none">
                <h3 class="card-title t-primary title-xlarge">
                    {$node.name|wash()}
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
            {include uri='design:openpa/card/parts/abstract.tpl' wrapper_class="titillium text-paragraph mb-0"}
            {if and( $node.children_count, $node|has_attribute('show_topic_children'), $node|attribute('show_topic_children').data_int|eq(1) )}
                <div class="mt-4">
                    {foreach $node.children as $child}
                        <a class="text-decoration-none text-nowrap d-inline-block " href="{$child.url_alias|ezurl(no)}" data-element="{object_handler($child).data_element.value|wash()}">
                            <div class="chip chip-simple chip-{if $child.object.section_id|eq(1)}primary{else}danger{/if}"><span class="chip-label">{$child.name|wash()}</span></div>
                        </a>
                    {/foreach}
                </div>
            {/if}
        </div>
    </div>
</div>

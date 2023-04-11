{def $valid_nodes = $block.valid_nodes}
{if $valid_nodes|count()|gt(0)}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if $block.name}
        <h3 class="openpa-widget-title"><span>{$block.name}</span></h3>
    {/if}
    <div class="openpa-widget-content">
        <div class="widget_tabs {$block.view}" id="{$block.id}">
            <ul class="nav nav-tabs">
                {foreach $valid_nodes as $index => $child}
                    <li class="nav-tab {if $index|eq(0)}active{/if}">
                        <a href="#{$block.id}-{$child.name|slugize()}" data-toggle="tab" title="{$child.name|wash()}">{$child.name|wash()}</a>
                    </li>
                {/foreach}
            </ul>
            <div>
                <div class="tab-content">
                    {foreach $valid_nodes as $index => $child}
                        <div class="tab-pane{if $index|eq(0)} active{/if}" id="{$block.id}-{$child.name|slugize()}">
                            {node_view_gui content_node=$child view=accordion_content image_class=medium}
                            <a class="readmore" href="{object_handler($child).content_link.full_link}" title="Link alla pagina {$child.name|wash()}">{'Read more'|i18n('openpa/widget')}</a>
                        </div>
                    {/foreach}
                </div>
            </div>
        </div>
    </div>
</div>

    <script>
        {literal}
        $(document).ready(function() {
            $("#{/literal}{$block.id}{literal}").tabs();
        });
        {/literal}
    </script>
{/if}

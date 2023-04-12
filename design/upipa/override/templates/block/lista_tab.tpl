{def $valid_nodes = $block.valid_nodes}
{if $valid_nodes|count()|gt(0)}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {include uri='design:parts/block_name.tpl'}
    <div class="openpa-widget-content">
        <div class="widget_tabs {$block.view}" id="{$block.id}">
            <ul class="nav nav-tabs">
                {foreach $valid_nodes as $index => $child}
                    <li class="nav-item nav-tab {if $index|eq(0)}active{/if}">
                        <a class="nav-link" href="#{$block.id}-{$child.name|slugize()}" data-toggle="tab" title="{$child.name|wash()}">{$child.name|wash()}</a>
                    </li>
                {/foreach}
            </ul>
            <div>
                <div class="tab-content">
                    {foreach $valid_nodes as $index => $child}
                        <div class="tab-pane{if $index|eq(0)} active{/if} p-4" id="{$block.id}-{$child.name|slugize()}">
                            {node_view_gui content_node=$child view=accordion_content image_class=medium}
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

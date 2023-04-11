{def $valid_nodes = $block.valid_nodes
     $show_link = true()}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if $block.name|ne('')}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span>{if $show_link}<a class="pull-right" href="{$valid_nodes[0].parent.url_alias|ezurl(no)}" title="{'Go to calendar'|i18n('openpa_designitalia')}"><i class="fa fa-calendar f_size_ex_large"></i></a>{/if}</h3>
    {/if}
    <div class="openpa-widget-content">
        <div class="events">
            {foreach $valid_nodes as $i => $child}
                {include uri="design:calendar/block_list_item.tpl" item=$child}
            {/foreach}
        </div>
    </div>
</div>


{def $openpa= object_handler($block)}
{set_defaults(hash('show_title', true()))}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        {include uri='design:parts/block_name.tpl'}
    {/if}
    <div class="openpa-widget-content u-padding-top-s">
        <div class="link-list-wrapper">
            <ul class="link-list">
                {foreach $openpa.content as $item}
                    <li>
                        {node_view_gui content_node=$item view=text_linked}
                    </li>
                {/foreach}
            </ul>
        </div>
        {include uri='design:parts/block_show_all.tpl'}
    </div>
</div>
{unset_defaults( array('show_title') )}

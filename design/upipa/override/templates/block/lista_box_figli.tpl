{def $openpa=object_handler($block)
     $count = $openpa.content|count()
     $size = 2}
{for 4 to 2 as $counter}
    {if $count|mod($counter)|eq(0)}
        {set $size = $counter}
        {break}
    {/if}
{/for}
{if count($openpa.content)|gt(0)}
{set_defaults(hash('show_title', true()))}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <div class="openpa-widget-content u-padding-top-s">
        <div class="Grid Grid--withGutter">
            {foreach $openpa.content as $item}
                <div class="Grid-cell u-md-size1of{$size} u-lg-size1of{$size} u-padding-bottom-s">
                    <h4 class="u-text-h4">
                        <a href="{$item.url_alias|ezurl(no)}" class="u-block u-text-h3 u-color-60 u-textClean">{$item.name|downcase()|upfirst()wash()}</a>
                    </h4>
                    <ul class="Linklist Prose u-text-r-xs">
                        {foreach $item.children as $child max 4}
                            <li>
                                {node_view_gui content_node=$child view=text_linked}
                            </li>
                        {/foreach}
                        <li>
                            <a href="{$item.url_alias|ezurl(no)}" class="u-textClean">Tutto su “{$item.name|downcase()|upfirst()wash()}” <span class="Icon Icon-chevron-right"></span></a>
                        </li>
                    </ul>
                </div>
            {/foreach}
        </div>
    </div>
</div>
{unset_defaults( array('show_title') )}
{/if}
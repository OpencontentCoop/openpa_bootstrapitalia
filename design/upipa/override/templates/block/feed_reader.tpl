{cache-block expiry=300}

{set_defaults( hash('show_title', true()) )}

{def $source = $block.custom_attributes.source
     $limit = $block.custom_attributes.limit
     $offset = $block.custom_attributes.offset
     $res = feedreader( $source, $limit, $offset )}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}
    <div class="openpa-widget-content">
        <h4 class="openpa-widget-title-lev2"><a href="{$res.links[0]}" title="{$res.title|wash()}">{$res.title|wash()}</a></h4>

        <ul class="list-unstyled">
            {foreach $res.items as $item}
                <li>
                    <a href="{$item.links[0]}" title="{$item.title|wash()}">{$item.title|wash()}</a>
                </li>
            {/foreach}
        </ul>

    </div>
</div>
{/cache-block}

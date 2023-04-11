<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">

    {if $block.name}
        <h3 class="openpa-widget-title"><span>{$block.name}</span></h3>
    {/if}
    <div class="openpa-widget-content">
            {$block.custom_attributes.html}
    </div>
</div>

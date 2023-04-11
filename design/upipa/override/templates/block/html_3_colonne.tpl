<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">

    {if $block.name}
        <h3 class="openpa-widget-title"><span>{$block.name}</span></h3>
    {/if}

    <div class="Grid Grid--withGutter">
      <div class="Grid-cell u-md-size1of3 u-lg-size1of3 u-margin-bottom-s">
        {$block.custom_attributes.htmlCol1}
      </div>
      <div class="Grid-cell u-md-size1of3 u-lg-size1of3 u-margin-bottom-s">
        {$block.custom_attributes.htmlCol2}
      </div>
      <div class="Grid-cell u-md-size1of3 u-lg-size1of3 u-margin-bottom-s">
        {$block.custom_attributes.htmlCol3}
      </div>
    </div>
</div>

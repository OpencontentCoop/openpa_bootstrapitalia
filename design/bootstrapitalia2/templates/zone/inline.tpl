{def $show_fullwidth = cond(and($attribute.object|has_attribute('show_fullwidth'), $attribute.object|attribute('show_fullwidth').data_int|eq(1) ), true(), false())}

{if and( is_set( $zones[0].blocks ), $zones[0].blocks|count() )}
  {foreach $zones[0].blocks as $block}
    <div class="py-5">
      {def $items_per_row = 2}
      {if and(is_set($block.custom_attributes.elementi_per_riga), $show_fullwidth)}
          {set $items_per_row = $block.custom_attributes.elementi_per_riga}
      {/if}
      {block_view_gui block=$block items_per_row=$items_per_row wrapper_class='position-relative' container_class=''}
      {undef $items_per_row}
    </div>
  {/foreach}
{/if}

{undef $show_fullwidth}
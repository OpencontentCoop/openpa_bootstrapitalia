{if and( is_set( $zones[0].blocks ), $zones[0].blocks|count() )}
  {foreach $zones[0].blocks as $block}
    <div class="py-5">
      {block_view_gui block=$block items_per_row=2 wrapper_class='position-relative' container_class=''}
    </div>
  {/foreach}
{/if}
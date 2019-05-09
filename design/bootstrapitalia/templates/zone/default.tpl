{def $block_wrappers = array()}
{if and( is_set( $zones[0].blocks ), $zones[0].blocks|count() )}
  {foreach $zones[0].blocks as $index => $block}

    {if or( $block.valid_nodes|count(),
            and( is_set( $block.custom_attributes), $block.custom_attributes|count() ),
            and( eq( ezini( $block.type, 'ManualAddingOfItems', 'block.ini' ), 'disabled' ), ezini_hasvariable( $block.type, 'FetchClass', 'block.ini' )|not ) )}

      {def $current_items_per_row = 3}
      {if and( is_set($block.custom_attributes.elementi_per_riga),
               $block.custom_attributes.elementi_per_riga|is_numeric,
               $block.custom_attributes.elementi_per_riga|gt(0),
               $block.custom_attributes.elementi_per_riga|le(6) ) }
        {set $current_items_per_row = $block.custom_attributes.elementi_per_riga}
      {elseif ezini_hasvariable( $block.type, 'ItemsPerRow', 'block.ini' )}
        {def $current_items_per_row_settings = ezini( $block.type, 'ItemsPerRow', 'block.ini' )}
        {if is_set($current_items_per_row_settings[$block.view])}
          {set $current_items_per_row = $current_items_per_row_settings[$block.view]}
        {/if}
        {undef $current_items_per_row_settings}
      {/if}

      {def $slug = concat('sezione-', $index)}
      {if $block.name|ne('')}
        {set $slug = concat('sezione-', $block.name|slugize())}
      {elseif is_set($block.valid_nodes[0])}
        {set $slug = concat('sezione-', $block.valid_nodes[0].name|slugize())}
      {/if}

      {def $is_wide = false()}
      {if $block.view|ends_with('_wide')}
        {set $is_wide = true()}
      {/if}

      {def $has_style = false()}
      {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}
        {set $has_style = true()}
      {/if}

      {def $next_index = $index|inc()}
      {def $show_next_link = false()}
      {if and(is_set($block.custom_attributes.show_next_link), $block.custom_attributes.show_next_link|eq(1), is_set($zones[0].blocks[$next_index]))}
        {set $show_next_link = true()}
      {/if}

      {set $block_wrappers = $block_wrappers|append(hash(
        'block', $block,
        'slug', $slug,
        'items_per_row', $current_items_per_row,
        'is_wide', $is_wide,
        'has_style', $has_style,
        'show_next_link', $show_next_link
      ))}

      {undef $slug $current_items_per_row $is_wide $has_style $next_index $show_next_link}

    {else}
      {skip}
    {/if}
  {/foreach}
{/if}
{if count($block_wrappers)|gt(0)}
{foreach $block_wrappers as $index => $block_wrapper}
  {def $next_index = $index|inc()}
  {if $block_wrapper.is_wide}
    <section class="{if $block_wrapper.has_style}bg-shadow bg-gray{/if}" id="{$block_wrapper.slug}">
      {block_view_gui block=$block_wrapper.block items_per_row=$block_wrapper.items_per_row link_top_title=false()}
      {if and($block_wrapper.show_next_link, $block_wrappers[$next_index])}
      <a href="#{$block_wrappers[$next_index].slug}" class="Forward Forward--floating js-scrollTo u-color{if $block_wrapper.has_style|not()}-grey{/if}-30" aria-hidden="true">
          <span class="Icon Icon-expand"></span>
      </a>
      {/if}
    </section>
  {else}
    <section class="{if $block_wrapper.has_style}bg-shadow bg-gray{/if}" id="{$block_wrapper.slug}">
        <div class="container">
            {block_view_gui block=$block_wrapper.block items_per_row=$block_wrapper.items_per_row link_top_title=false()}
        </div>
      {if and($block_wrapper.show_next_link, $block_wrappers[$next_index])}
      <a href="#{$block_wrappers[$next_index].slug}" class="Forward Forward--floating js-scrollTo u-color{if $block_wrapper.has_style|not()}-grey{/if}-30" aria-hidden="true">
          <span class="Icon Icon-expand"></span>
      </a>
      {/if}
    </section>
  {/if}
  {undef $next_index}
{/foreach}
{/if}
{undef $block_wrappers}
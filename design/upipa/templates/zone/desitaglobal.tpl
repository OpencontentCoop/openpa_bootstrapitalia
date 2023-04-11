{def $block_wrappers = array()}
{def $topic_first_block_color_style = 'section section-muted section-inset-shadow pb-5'}

{foreach $zones as $zone}
  {if and( is_set( $zone.blocks ), $zone.blocks|count() )}
    {foreach $zone.blocks as $index => $block}

      {if or( $block.valid_nodes|count(),
      and( is_set( $block.custom_attributes), $block.custom_attributes|count() ),
      and( eq( ezini( $block.type, 'ManualAddingOfItems', 'block.ini' ), 'disabled' ), ezini_hasvariable( $block.type, 'FetchClass', 'block.ini' )|not ) )}

        {def $current_items_per_row = 3}
        {if and( is_set($block.custom_attributes.elementi_per_riga),
            or( and( $block.custom_attributes.elementi_per_riga|is_numeric,
                     $block.custom_attributes.elementi_per_riga|gt(0),
                     $block.custom_attributes.elementi_per_riga|le(6) ),
                     $block.custom_attributes.elementi_per_riga|eq('auto'))
            ) }
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
        {if ezini_hasvariable( $block.type, 'Wide', 'block.ini' )}
          {set $is_wide = cond( ezini( $block.type, 'Wide', 'block.ini' )|contains($block.view), true(), false())}
        {/if}

        {def $container_style = false()}
        {if ezini_hasvariable( $block.type, 'ContainerStyle', 'block.ini' )}
          {set $container_style = cond( is_set(ezini( $block.type, 'ContainerStyle', 'block.ini' )[$block.view]), ezini( $block.type, 'ContainerStyle', 'block.ini' )[$block.view], false())}
        {/if}
        {def $layout_style = false()}
        {if and(is_set($block.custom_attributes.container_style), $block.custom_attributes.container_style|ne(''))}
          {set $layout_style = $block.custom_attributes.container_style}
        {/if}

        {def $color_style = false()}
        {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}
          {set $color_style = $block.custom_attributes.color_style|wash()}
        {/if}

        {def $next_index = $index|inc()}
        {def $show_next_link = false()}
        {if and(is_set($block.custom_attributes.show_next_link), $block.custom_attributes.show_next_link|eq(1), is_set($zone.blocks[$next_index]))}
          {set $show_next_link = true()}
        {/if}

        {def $openpa_block = object_handler($block)
        $has_content = cond(is_set($openpa_block.has_content), $openpa_block.has_content, true())}

        {if $has_content}
          {set $block_wrappers = $block_wrappers|append(hash(
          'block', $block,
          'slug', $slug,
          'items_per_row', $current_items_per_row,
          'is_wide', $is_wide,
          'container_style', $container_style,
          'layout_style', $layout_style,
          'color_style', $color_style,
          'show_next_link', $show_next_link
          ))}
        {/if}

        {undef $slug $current_items_per_row $is_wide $color_style $next_index $show_next_link $container_style $layout_style $openpa_block $has_content}

      {else}
        {skip}
      {/if}
    {/foreach}
  {/if}
{/foreach}
{if count($block_wrappers)|gt(0)}
  {foreach $block_wrappers as $index => $block_wrapper}
    {def $next_index = $index|inc()
    $prev_index = $index|sub(1)
    $block_wrapper_color_style = $block_wrapper.color_style
    $block_wrapper_container_style = $block_wrapper.container_style}

    {* forza il color_style al primo blocco dei topic *}
    {if and($#node.class_identifier|eq('topic'), $index|eq(0), $block_wrapper.color_style|ne($topic_first_block_color_style))}
      {set $block_wrapper_color_style = $topic_first_block_color_style}
    {/if}

    {if or($block_wrapper_container_style|eq(''), $#node.class_identifier|eq('pagina_trasparenza'))}
      {set $block_wrapper_container_style = 'mb-5'}
    {/if}

    <section class="page-{$#node.class_identifier} {$block_wrapper.layout_style} {if and(is_set($block_wrappers[$next_index].layout_style),$block_wrappers[$next_index].layout_style)} before-{$block_wrappers[$next_index].layout_style}{/if} {if and(is_set($block_wrappers[$prev_index].layout_style),$block_wrappers[$prev_index].layout_style)} after-{$block_wrappers[$prev_index].layout_style}{/if} {$block_wrapper_color_style}" id="{$block_wrapper.slug}">
      {if $block_wrapper_container_style}<div class="{$block_wrapper_container_style}">{/if}
        {if $block_wrapper.is_wide|not()}<div class="container">{/if}

          {block_view_gui block=$block_wrapper.block items_per_row=$block_wrapper.items_per_row}

          {if $block_wrapper.is_wide|not()}</div>{/if}
        {if $block_wrapper_container_style}</div>{/if}

      {*if and($block_wrapper.show_next_link, is_set($block_wrappers[$next_index]))}
      <a href="#{$block_wrappers[$next_index].slug}" class="scrollTo" aria-hidden="true">
          <span class="Icon Icon-expand"></span>
      </a>
      {/if*}
    </section>

    {undef $next_index $prev_index $block_wrapper_color_style $block_wrapper_container_style}

  {/foreach}
{/if}
{undef $block_wrappers}
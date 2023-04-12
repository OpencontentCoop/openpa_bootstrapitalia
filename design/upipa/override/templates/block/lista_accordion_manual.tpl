{def $openpa= object_handler($block)}
{if count($openpa.content)|gt(0)}
{set_defaults( hash('show_title', true(), 'items_per_row', 3) )}
{if count($openpa.content)}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}

    <div class="Accordion Accordion--default fr-accordion js-fr-accordion" id="accordion-{$block.id}">
      {foreach $openpa.content as $index => $item}
          <h2 class="Accordion-header js-fr-accordion__header fr-accordion__header" id="accordion-header-{$block.id}-{$item.node_id}">
              <span class="Accordion-link u-text-r-s">{$item.name|wash()}</span>
          </h2>
          <div id="accordion-panel-{$block.id}-{$item.node_id}" class="Accordion-panel fr-accordion__panel js-fr-accordion__panel">
              {node_view_gui content_node=$item view=accordion_content}
              <a class="readmore" href="{object_handler($item).content_link.full_link}" title="{$item.name|wash()}">{'Read more'|i18n('bootstrapitalia')}</a>
          </div>
      {/foreach}
    </div>

</div>
{/if}
{unset_defaults( array('show_title', 'items_per_row') )}
{/if}

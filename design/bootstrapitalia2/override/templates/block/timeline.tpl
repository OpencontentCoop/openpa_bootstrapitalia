{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}

  <div class="it-timeline-wrapper">
    <div class="row">
      {if is_set($block.valid_nodes[0])}
        {foreach $block.valid_nodes as $item}
          <div class="col-12">
            <div class="timeline-element">
              <h3 class="it-pin-wrapper it-evidence ">
                <div class="pin-icon">
                  {display_icon('it-bookmark', 'svg', 'icon')}
                </div>
                <div class="pin-text"><span>{$item.name|wash()}</span></div>
              </h3>
              {node_view_gui content_node=$item view=card}
            </div>
          </div>
        {/foreach}
      {/if}
    </div>
  </div>
{/if}
{undef $openpa}
{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}

  <div class="it-timeline-wrapper">
    <div class="row">
      {if is_set($block.valid_nodes[0])}
        {foreach $block.valid_nodes as $item}
          {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
          {def $openpa_timeline = object_handler($object)}
          <div class="col-12">
            <div class="timeline-element">
              <h3 class="it-pin-wrapper it-evidence">
                <div class="pin-icon">
                  {if $openpa_timeline.content_icon.object_icon}
                    {display_icon($openpa_timeline.content_icon.object_icon.icon_text, 'svg', 'icon')}
                  {else}
                    {display_icon('it-bookmark', 'svg', 'icon')}
                  {/if}
                </div>
                <div class="pin-text"><span>{$object.data_map.period.content|wash()}</span></div>
              </h3>
              {include name="timeline_element" uri=$openpa_timeline.control_template.card view_variation=false() node=$object.main_node openpa=$openpa_timeline}
            </div>
          </div>
          {undef $openpa_timeline $object}
        {/foreach}
      {/if}
    </div>
  </div>
{/if}
{undef $openpa}
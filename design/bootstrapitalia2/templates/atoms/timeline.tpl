  <div class="it-timeline-wrapper">
    <div class="row">
      {if is_set($items[0])}
        {foreach $items as $item}
          {if $item.class_identifier|ne('timeline_element')}
            {skip}
          {/if}
          {def $openpa_timeline = object_handler($item)}
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
                <div class="pin-text"><span>{$item.data_map.period.content|wash()}</span></div>
              </h3>
              {include name="timeline_element" uri=$openpa_timeline.control_template.card view_variation=false() node=$item openpa=$openpa_timeline}
            </div>
          </div>
          {undef $openpa_timeline $object}
        {/foreach}
      {/if}
    </div>
  </div>
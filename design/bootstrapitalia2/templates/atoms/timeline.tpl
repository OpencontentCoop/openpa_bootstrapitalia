<div class="container">
  <div class="it-timeline-wrapper">
    <div class="row mb-5">
      {if is_set($items[0])}
        {foreach $items as $item}
          {if $item.contentclass_identifier|ne('timeline_element')}
            {skip}
          {/if}
          {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
          <div class="col-12">
            <div class="timeline-element">
              <h3 class="h6 it-pin-wrapper it-evidence">
                <div class="pin-icon">
                  {if $object|has_attribute('icon')}
                    {display_icon($object.data_map.icon.content|wash(), 'svg', 'icon')}
                  {else}
                    {display_icon('it-bookmark', 'svg', 'icon')}
                  {/if}
                </div>
                <div class="pin-text"><span>{$object.data_map.period.content|wash()}</span></div>
              </h3>
              {def $openpa = object_handler($object)}
              {include name="timeline_element" uri=$openpa.control_template.card view_variation=false() node=$object openpa=$openpa}
              {undef $openpa}
            </div>
          </div>
          {undef $object}
        {/foreach}
      {/if}
    </div>
  </div>
</div>
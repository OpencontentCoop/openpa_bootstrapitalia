{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}

  <div class="it-timeline-wrapper">
    <div class="row">
      {if is_set($block.valid_nodes[0])}
        {foreach $block.valid_nodes as $item}
          {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
          <div class="col-12">
            <div class="timeline-element">
              <h3 class="it-pin-wrapper it-evidence ">
                <div class="pin-icon">
                  {display_icon('it-bookmark', 'svg', 'icon')}
                </div>
                <div class="pin-text"><span>{$item.name|wash()}</span></div>
              </h3>
              <article class="card-wrapper border border-light rounded shadow-sm bg-white ">
                <div class="card no-after rounded">
                  <div class="card-body">
                    <h2 class="h4 card-title">
                      {$object.data_map.title.content|wash()}
                    </h2>
                    <div class="card-text text-secondary">
                      {$object.data_map.text.content|wash()}
                    </div>
                  </div>
                </div>
              </article>
            </div>
          </div>
        {/foreach}
      {/if}
    </div>
  </div>
{/if}
{undef $openpa}
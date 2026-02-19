{if is_set($items[0])}
  dentro if
  <ul>
  {foreach $items as $valid_node max 10}
    {if and($valid_node.class_identifier|eq('stage'), $valid_node.data_map.places.has_content)}
      <li>
      {$valid_node.data_map.places.content.relation_list|attribute( show, 2 )}
      <ul>
      {foreach $valid_node.data_map.places.content as $place max 10}
        luogo
        {def $item_object = fetch(content, object, hash(object_id, $place.contentobject_id))}
        {$place.relation_list|attribute( show, 1 )}
      {/foreach}
      </ul>
      {undef $places}
    </li>
    {else}
      {editor_warning(concat("Non sono presenti luoghi georeferenziati per la tappa",$valid_node.name))}
    {/if}
  {/foreach}
  </ul>
{/if}


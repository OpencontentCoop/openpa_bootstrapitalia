<div class="ezobject-relationlist-container">
    {if is_set( $attribute.class_content.default_placement.node_id )}
     {set browse_object_start_node = $attribute.class_content.default_placement.node_id}
    {/if}

    {if $browse_object_start_node}
      <input type="hidden" name="{$attribute_base}_browse_for_object_start_node[{$attribute.id}]" value="{$browse_object_start_node|wash}" />
    {/if}

    {if is_set( $attribute.class_content.class_constraint_list[0] )}
      <input type="hidden" name="{$attribute_base}_browse_for_object_class_constraint_list[{$attribute.id}]" value="{$attribute.class_content.class_constraint_list|implode(',')}" />
    {/if}
    
    <div class="table-responsive">
      <table class="table table-condensed" cellspacing="0">
      <thead>
      <tr class="{if $attribute.content.relation_list|not()}hide{/if}">
          <th class="tight"></th>
          <th><small>{'Name'|i18n( 'design/standard/content/datatype' )}</small></th>
          <th><small>{'Section'|i18n( 'design/standard/content/datatype' )}</small></th>            
          <th class="tight"><small>{'Order'|i18n( 'design/standard/content/datatype' )}</small></th>
      </tr>
      </thead>
      <tbody>
        {if $attribute.content.relation_list}
          {foreach $attribute.content.relation_list as $item sequence array( 'bglight', 'bgdark' ) as $style}
		       {def $related = fetch( content, object, hash( object_id, $item.contentobject_id ))}
           <tr>
              {* Remove. *}
              <td class="related-id">
                <input type="checkbox" name="{$attribute_base}_selection[{$attribute.id}][]" value="{$related.id|wash}" />
                <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" value="{$related.id|wash}" />
              </td>
              
              <td class="related-name">
              {if ezini('ObjectRelationsMultiupload','ClassAttributeIdentifiers','ocoperatorscollection.ini')|contains($contentclass_attribute.identifier)}
                <div style="margin:0 10px;{if and($related|has_attribute( 'image' ), $related|attribute( 'image' ).data_type_string|eq('ezimage'))}background-image:url({$related|attribute( 'image' ).content['medium'].url|ezroot(no)});{/if}background-size: cover;background-position: center center;width: 50px;height: 50px;display: inline-block;vertical-align: middle;"></div>                
              {/if}
              {$related.name|wash()} <small>({$related.class_name|wash()})</small>
              </td>

              {* Section *}
              <td class="related-section">
                <small>{fetch( section, object, hash( section_id, $related.section_id ) ).name|wash()}</small>
              </td>
              
              {* Order. *}
              <td class="related-order">
                <input size="2" type="text" name="{$attribute_base}_priority[{$attribute.id}][]" value="{$item.priority}" />
              </td>
          {undef $related}  
          </tr>            
          {/foreach}
        {/if}        
        <tr class="buttons">
          <td colspan="4">
            <button class="btn btn-sm btn-danger ezobject-relationlist-remove-button" type="submit" name="CustomActionButton[{$attribute.id}_remove_objects]" {if count($attribute.content.relation_list)|eq(0)}style="display:none"{/if}>
              <span class="fa fa-trash"></span>
            </button>
            <button class="btn btn-sm btn-info ezobject-relationlist-add-button"                 
                type="submit" 
                name="CustomActionButton[{$attribute.id}_browse_objects]">
              <span class="fa fa-plus"></span> {'Add objects'|i18n( 'openpa/widget' )}
            </button>
          </td>          
        </tr>
      </tbody>
      </table>
      <div class="ezobject-relationlist-browse"           
           data-show_thumbnail="{if ezini('ObjectRelationsMultiupload','ClassAttributeIdentifiers','ocoperatorscollection.ini')|contains($contentclass_attribute.identifier)}1{else}0{/if}"
           data-attribute_base="{$attribute_base}" 
           data-attribute="{$attribute.id}" 
           data-classes="{if is_set( $attribute.class_content.class_constraint_list[0] )}{$attribute.class_content.class_constraint_list|implode(',')}{/if}"
           data-subtree="{if $browse_object_start_node}{$browse_object_start_node|wash}{else}{default_relations_parent_node_id($attribute.class_content.class_constraint_list)}{/if}"></div>

    </div>
  </div>  
<div class="block relations-searchbox" id="ezobjectrelationlist_browse_{$attribute.id}">
{if is_set( $attribute.class_content.default_placement.node_id )}
     {set browse_object_start_node = $attribute.class_content.default_placement.node_id}
{/if}

{* Optional controls. *}
{include uri='design:content/datatype/edit/ezobjectrelationlist_controls.tpl'}
    <div class="table-responsive">        
    <table class="table table-condensed{if $attribute.content.relation_list|not} hide{/if}" cellspacing="0">
    <thead>
    <tr>
        <th class="tight">                  
        </th>
        <th><small>{'Name'|i18n( 'design/standard/content/datatype' )}</small></th>
        {*<th>{'Type'|i18n( 'design/standard/content/datatype' )}</th>*}
        <th>{'Section'|i18n( 'design/standard/content/datatype' )}</th>
        <th>{'Published'|i18n( 'design/standard/content/datatype' )}</th>
        <th class="tight">{'Order'|i18n( 'design/standard/content/datatype' )}</th>
    </tr>
    </thead>
    <tbody>
    {if $attribute.content.relation_list}
        {foreach $attribute.content.relation_list as $item sequence array( 'bglight', 'bgdark' ) as $style}
	         {include name=relation_item uri='design:ezjsctemplate/relation_list_row.tpl' arguments=array( $item.contentobject_id, $attribute.id, $item.priority )}
        {/foreach}
    {/if}
    <tr class="hide">
      <td>
          <input type="checkbox" name="{$attribute_base}_selection[{$attribute.id}][]" value="--id--" />
          <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" value="no_relation" />
      </td>
      <td><small></small></td>
      <td><small></small></td>
      <td><small></small></td>
      <td><small></small></td>
      <td><input size="2" type="text" name="{$attribute_base}_priority[{$attribute.id}][]" value="0" /></td>
    </tr>                    
    <tr class="buttons">
      <td>
        <button class="btn btn-sm ezobject-relation-remove-button {if $attribute.content.relation_list|not()}hide{/if}" type="submit" name="CustomActionButton[{$attribute.id}_remove_objects]">
          <span class="glyphicon glyphicon-trash"></span>
        </button>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    </tbody>
    </table>
    
    </div>

      
    {if $browse_object_start_node}
        <input type="hidden" name="{$attribute_base}_browse_for_object_start_node[{$attribute.id}]" value="{$browse_object_start_node|wash}" />
    {/if}

    {if is_set( $attribute.class_content.class_constraint_list[0] )}
        <input type="hidden" name="{$attribute_base}_browse_for_object_class_constraint_list[{$attribute.id}]" value="{$attribute.class_content.class_constraint_list|implode(',')}" />
    {/if}

    <div class="clearfix">
    <div class="pull-left">      
        <button class="btn btn-info" type="submit" name="CustomActionButton[{$attribute.id}_browse_objects]" title="{'Browse to add existing objects in this relation'|i18n( 'design/standard/content/datatype' )}">
          <span class="fa fa-plus"></span> {'Add existing objects'|i18n( 'design/standard/content/datatype' )}
        </button>
    </div>
    {include uri='design:content/datatype/edit/ezobjectrelationlist_ajaxuploader.tpl'}


</div>
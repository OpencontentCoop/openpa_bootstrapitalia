{let class_content=$attribute.class_content
     class_list=fetch( class, list, hash( class_filter, $class_content.class_constraint_list ) )
     can_create=true()
     new_object_initial_node_placement=false()
     browse_object_start_node=false()}

{default html_class='full' placeholder=false()}

{if is_set( $attribute.class_content.default_placement.node_id )}
    {set $browse_object_start_node = $attribute.class_content.default_placement.node_id}
{/if}

<div class="block relations-searchbox" id="ezobjectrelationlist_browse_{$attribute.id}">
    <div class="table-responsive">
        <table class="table table-striped table-condensed{if $attribute.content.relation_list|not} hide{/if}">
            <thead>
            <tr>
                <th class="tight"></th>
                <th>{'Name'|i18n( 'design/standard/content/datatype' )}</th>
                <th>{'Section'|i18n( 'design/standard/content/datatype' )}</th>
                <th class="tight">{'Order'|i18n( 'design/standard/content/datatype' )}</th>
            </tr>
            </thead>
            <tbody>
            {if $attribute.content.relation_list}
                {foreach $attribute.content.relation_list as $item}
                    {include name=relation_item uri='design:ezjsctemplate/relation_list_row.tpl' arguments=array( $item.contentobject_id, $attribute.id, $item.priority )}
                {/foreach}
            {/if}
            <tr class="hide">
                <td>
                    <input type="checkbox" name="{$attribute_base}_selection[{$attribute.id}][]" value="--id--"/>
                    <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]"
                           value="no_relation"/>
                </td>
                <td></td>
                <td><small></small></td>
                <td><input size="2" type="text" name="{$attribute_base}_priority[{$attribute.id}][]" value="0"/></td>
            </tr>
            <tr class="buttons">
                <td colspan="4">
                    <button class="btn btn-sm btn-danger ezobject-relation-remove-button {if $attribute.content.relation_list|not()}hide{/if}"
                            type="submit" name="CustomActionButton[{$attribute.id}_remove_objects]">
                        {'Remove selected'|i18n( 'design/standard/content/datatype' )}
                    </button>
                </td>
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

    <div class="clearfix relation-edit">
        <input class="btn btn-sm btn-info ml-2 ms-2 relation_browser_toggler"
               id="browse_objects_{$attribute.id}"
               type="submit"
               name="CustomActionButton[{$attribute.id}_browse_objects]"
               value="{'Select from library'|i18n('bootstrapitalia')}"
               title="{'Browse to add existing objects in this relation'|i18n( 'design/standard/content/datatype' )}" />

        {include uri='design:content/datatype/edit/ezobjectrelationlist_create_new.tpl'}
        {include uri='design:content/datatype/edit/ezobjectrelationlist_ajaxuploader.tpl'}
        <div id="browse_and_search_{$attribute.id}"
             data-relation_attribute="{$attribute.id}"
             data-relation_maxitems="{$max_items}"
             data-relation_subtree="{cond($browse_object_start_node, $browse_object_start_node, 1)}"
             data-relation_classes="{cond( and( is_set( $attribute.class_content.class_constraint_list ), $attribute.class_content.class_constraint_list|count|ne( 0 ) ), $class_content.class_constraint_list|implode(','), '')}"
             class="mt-3 mb-3 relation_browser"></div>
        <div id="create_new_{$attribute.contentclassattribute_id}" data-attribute="{$attribute.id}" class="shadow px-3 py-3 mt-3 mb-3 bg-white" style="display: none;"></div>
    </div>

</div>
{/default}
{/let}

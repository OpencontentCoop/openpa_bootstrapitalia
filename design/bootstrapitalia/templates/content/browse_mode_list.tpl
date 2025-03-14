{ezscript_require( 'tools/ezjsselection.js' )}
<div class="table-responsive">
<table class="table table-hover">
<tr>
    <th class="tight">
    {section show=eq( $select_type, 'checkbox' )}
        <a href="#" data-toggle="tooltip" data-bs-toggle="tooltip" data-placement="top" title="{'Invert selection'|i18n( 'design/ocbootstrap/content/browse_mode_list' )}" onclick="ezjs_toggleCheckboxes( document.browse, '{$select_name}[]' ); return false;">
            <i aria-hidden="true" class="fa fa-check-circle"></i>
        </a>
    {/section}
    </th>
    <th class="wide">
        {'Name'|i18n( 'design/ocbootstrap/content/browse_mode_list' )}
    </th>
    <th>
    {'Type'|i18n( 'design/ocbootstrap/content/browse_mode_list' )}
        </th>
</tr>
{if is_set($browse.persistent_data.ContentNodeID)}
    {def $browse_context_content_class_id = fetch('content', 'node', hash('node_id', $browse.persistent_data.ContentNodeID)).object.content_class.id}
{else}
    {def $browse_context_content_class_id = fetch('content', 'object', hash('object_id', $browse.persistent_data.ContentObjectID)).content_class.id}
{/if}

{section var=Nodes loop=$node_array sequence=array( bglight, bgdark )}
  <tr class="{$Nodes.sequence}">
    <td>
    {* Note: The tpl code for $ignore_nodes_merge with the eq, unique and count
             is just a replacement for a missing template operator.
             If there are common elements the unique array will have less elements
             than the merged one
             In the future this should be replaced with a  new template operator that checks
             one array against another and returns true if elements in the first
             exists in the other *}
     {let ignore_nodes_merge=merge( $browse.ignore_nodes_select_subtree, $Nodes.item.path_array )}
     {section show=and( or( $browse.permission|not,
                           cond( is_set( $browse.permission.contentclass_id ),
                                 fetch( content, access, hash( access,          $browse.permission.access,
                                                               contentobject,   $Nodes.item,
                                                               contentclass_id, $browse.permission.contentclass_id ) ),
                                 fetch( content, access, hash( access,          $browse.permission.access,
                                                               contentobject,   $Nodes.item ) ) ) ),
                           $browse.ignore_nodes_select|contains( $Nodes.item.node_id )|not,
                           eq( $ignore_nodes_merge|count,
                               $ignore_nodes_merge|unique|count ) )}
        {section show=is_array( $browse.class_array )}
            {section show=$browse.class_array|contains( $Nodes.item.object.content_class.identifier )}
                <input type="{$select_type}" name="{$select_name}[]" value="{$Nodes.item[$select_attribute]}" />
            {section-else}
                <input type="{$select_type}" name="" value="" disabled="disabled" />
            {/section}
        {section-else}
            {section show=and(
                or( eq( $browse.action_name, 'MoveNode' ), eq( $browse.action_name, 'CopyNode' ), eq( $browse.action_name, 'AddNodeAssignment' ) ),
                or( $Nodes.item.object.content_class.is_container|not, fetch( 'content', 'access', hash( 'access', 'create', 'contentobject', $Nodes.item, 'contentclass_id', $browse_context_content_class_id, 'parent_contentclass_id', $Nodes.item.object.content_class.id ) )|eq(0) )
            )}
                <input type="{$select_type}" name="{$select_name}[]" value="{$Nodes.item[$select_attribute]}" disabled="disabled" />
            {section-else}
                <input type="{$select_type}" name="{$select_name}[]" value="{$Nodes.item[$select_attribute]}" />
            {/section}
        {/section}
    {section-else}
        <input type="{$select_type}" name="" value="" disabled="disabled" />
    {/section}
    {/let}
    </td>
    <td>
    {* Replaces node_view_gui... *}
    {* Note: The tpl code for $ignore_nodes_merge with the eq, unique and count
             is just a replacement for a missing template operator.
             If there are common elements the unique array will have less elements
             than the merged one
             In the future this should be replaced with a  new template operator that checks
             one array against another and returns true if elements in the first
             exists in the other *}
    {let ignore_nodes_merge=merge( $browse.ignore_nodes_click, $Nodes.item.path_array )}
    {section show=eq( $ignore_nodes_merge|count,
                      $ignore_nodes_merge|unique|count )}
        {section show=and( or( ne( $browse.action_name, 'MoveNode' ), ne( $browse.action_name, 'CopyNode' ) ), $Nodes.item.object.content_class.is_container )}
            <a href={concat( '/content/browse/', $Nodes.item.node_id )|ezurl}>{$Nodes.item.name|wash}</a>
        {section-else}
            {$Nodes.item.name|wash}
        {/section}
    {section-else}
        {$Nodes.item.name|wash}
    {/section}
    {/let}

    </td>
    <td class="class">
        {$Nodes.item.object.content_class.name|wash}
    </td>
 </tr>
{/section}
</table>
</div>

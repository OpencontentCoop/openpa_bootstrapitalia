{set scope=global persistent_variable=hash('left_menu', false(),
                                           'extra_menu', false(),
                                           'show_path', false())}
{ezscript_require( array( 'ezjsc::yui3', 'ezjsc::yui3io', 'ezwtsortdd.js' ) )}
{*
  Drag and drop script inited in the bottom of this template!
*}

<form id="ezwt-sort-form" method="post" action={'content/action'|ezurl}>
<input type="hidden" name="ContentNodeID" value="{$node.node_id}" />

{def $item_type = ezpreference( 'user_list_limit' )
     $priority_sorting = or($node.object.remote_id|eq('all-services'), $node.sort_array[0][0]|eq( 'priority' ))
     $node_can_edit = cond(or($node.can_edit, current_user_can_lock_edit($node.object)), true(), false())
     $node_name     = $node.name
     $can_remove    = false()
     $number_of_items = min( $item_type, 3)|choose( 10, 10, 25, 50 )
     $children_count = fetch( content, list_count, hash( parent_node_id, $node.node_id,
                                                      objectname_filter, $view_parameters.namefilter ) )
     $children = fetch( content, list, hash( parent_node_id, $node.node_id,
                                          sort_by, $node.sort_array,
                                          limit, $number_of_items,
                                          offset, $view_parameters.offset,
                                          objectname_filter, $view_parameters.namefilter ) ) }

    <div class="row py-3">
        <div class="col col-md-8">
            <h1 class="h3">{'Sorting'|i18n( 'design/standard/parts/website_toolbar' )}:  <a class="text-decoration-none" href={$node.url_alias|ezurl}>{$node_name|wash}</a> ({$children_count})</h1>
        </div>
        {* Items per page selector. *}
        <div class="col col-md-4 text-right pt-2">
            {switch match=$number_of_items}
            {case match=25}
                <a class="btn btn-xs px-2 py-1 btn-primary" href={'/user/preferences/set/user_list_limit/1'|ezurl} title="{'Show 10 items per page.'|i18n( 'design/standard/websitetoolbar/sort' )}">10</a>
                <span class="current btn btn-xs px-2 py-1 btn--outline-primary">25</span>
                <a class="btn btn-xs px-2 py-1 btn-primary" href={'/user/preferences/set/user_list_limit/3'|ezurl} title="{'Show 50 items per page.'|i18n( 'design/standard/websitetoolbar/sort' )}">50</a>
            {/case}
            {case match=50}
                <a class="btn btn-xs px-2 py-1 btn-primary" href={'/user/preferences/set/user_list_limit/1'|ezurl} title="{'Show 10 items per page.'|i18n( 'design/standard/websitetoolbar/sort' )}">10</a>
                <a class="btn btn-xs px-2 py-1 btn-primary" href={'/user/preferences/set/user_list_limit/2'|ezurl} title="{'Show 25 items per page.'|i18n( 'design/standard/websitetoolbar/sort' )}">25</a>
                <span class="current btn btn-xs px-2 py-1 btn--outline-primary">50</span>
            {/case}
            {case}
                <span class="current btn btn-xs px-2 py-1 btn--outline-primary">10</span>
                <a class="btn btn-xs px-2 py-1 btn-primary" href={'/user/preferences/set/user_list_limit/2'|ezurl} title="{'Show 25 items per page.'|i18n( 'design/standard/websitetoolbar/sort' )}">25</a>
                <a class="btn btn-xs px-2 py-1 btn-primary" href={'/user/preferences/set/user_list_limit/3'|ezurl} title="{'Show 50 items per page.'|i18n( 'design/standard/websitetoolbar/sort' )}">50</a>
            {/case}
            {/switch}
        </div>
    </div>


{if $children}

<table id="ezwt-sort-list" class="table">
    <thead>
    <tr>
        <th class="tight"></th>
        <th class="name">{'Name'|i18n( 'design/standard/websitetoolbar/sort' )}</th>
        <th class="class">{'Type'|i18n( 'design/standard/websitetoolbar/sort' )}</th>
        {if $priority_sorting}
            <th class="priority" width="1">{'Priority'|i18n( 'design/standard/websitetoolbar/sort' )}</th>
        {/if}
    </tr>
    </thead>
    <tbody>
    {def $row_count=1}
    {foreach $children as $child}
    {if $child.can_remove}{set $can_remove = true()}{/if}
    {def $section_object = fetch( 'section', 'object', hash( 'section_id', $child.object.section_id ) )}
        <tr id="ezwt-table-row-{$row_count}" class="ezwt-sort-dragable">
            <td>
                {if $child.can_remove}
                    <input id="ezwt-table-row-{$row_count}-column-1" type="checkbox" name="DeleteIDArray[]" value="{$child.node_id}" title="{'Use these checkboxes to select items for removal. Click the "Remove selected" button to  remove the selected items.'|i18n( 'design/standard/websitetoolbar/sort' )|wash()}" />
                    {else}
                    <input id="ezwt-table-row-{$row_count}-column-1" type="checkbox" name="DeleteIDArray[]" value="{$child.node_id}" title="{'You do not have permission to remove this item.'|i18n( 'design/standard/websitetoolbar/sort' )}" disabled="disabled" />
                {/if}
            </td>
            <td id="ezwt-table-row-{$row_count}-column-2">{$child.name|wash}</td>
            <td class="class">{$child.class_name|wash}</td>
            {if $priority_sorting}
                <td>
                {if $node_can_edit}
                    <input id="ezwt-table-row-{$row_count}-column-4-a" class="priority ezwt-priority-input form-control border" type="text" name="Priority[]" size="3" value="{$child.priority}" title="{'Use the priority fields to control the order in which the items appear. You can use both positive and negative integers. Click the "Update priorities" button to apply the changes.'|i18n( 'design/standard/websitetoolbar/sort' )|wash}" />
                    <input id="ezwt-table-row-{$row_count}-column-4-b" type="hidden" name="PriorityID[]" value="{$child.node_id}" />
                {else}
                    <input id="ezwt-table-row-{$row_count}-column-4-a" class="priority ezwt-priority-input" type="text" name="Priority[]" size="3" value="{$child.priority}" title="{'You are not allowed to update the priorities because you do not have permission to edit <%node_name>.'|i18n( 'design/standard/websitetoolbar/sort',, hash( '%node_name', $node_name ) )|wash}" disabled="disabled" />
                {/if}
                </td>
            {/if}
      </tr>
    {set $row_count=inc($row_count)}
    {undef $section_object}
    {/foreach}
    {undef $row_count}
    </tbody>
</table>

{else}

    <p class="lead">{'The current item does not contain any sub items.'|i18n( 'design/standard/websitetoolbar/sort' )}</p>

{/if}

<div class="context-toolbar">
{include name=navigator
         uri='design:navigator/alphabetical.tpl'
         page_uri = concat( '/websitetoolbar/sort/', $node.node_id )
         item_count = $children_count
         view_parameters = $view_parameters
         node_id = $node.node_id
         item_limit = $number_of_items}
</div>

<div class="row my-5">

    {* Update priorities button *}
    <div class="col">
        {if $can_remove}
            <input class="btn btn-xs btn-danger" type="submit" name="RemoveButton" value="{'Remove selected'|i18n( 'design/admin/node/view/full' )}" title="{'Remove the selected items from the list above.'|i18n( 'design/standard/websitetoolbar/sort' )}" />
        {else}
            <input class="btn btn-xs btn--disabled" type="submit" name="RemoveButton" value="{'Remove selected'|i18n( 'design/admin/node/view/full' )}" title="{'You do not have permission to remove any of the items from the list above.'|i18n( 'design/standard/websitetoolbar/sort' )}" disabled="disabled" />
        {/if}
        {if and( $priority_sorting, $node_can_edit, $children_count )}
            <input id="ezwt-update-priority" class="btn btn-xs btn-secondary" type="submit" name="LockedUpdatePriorityButton" value="{'Update priorities'|i18n( 'design/standard/websitetoolbar/sort' )}" title="{'Apply changes to the priorities of the items in the list above.'|i18n( 'design/standard/websitetoolbar/sort' )}" />
            <input type="hidden" name="RedirectURIAfterPriority" value="websitetoolbar/sort/{$node.node_id}" />
            <span class="d-none" id="ezwt-automatic-update-container">{'Automatic update'|i18n( 'design/standard/websitetoolbar/sort' )} <input id="ezwt-automatic-update" type="checkbox" name="AutomaticUpdate" value="" /></span>
        {else}
            <input id="ezwt-update-priority" class="btn btn-xs btn-disabled" type="submit" name="LockedUpdatePriorityButton" value="{'Update priorities'|i18n( 'design/standard/websitetoolbar/sort' )}" title="{'You cannot update the priorities because you do not have permission to edit the current item or because a non-priority sorting method is used.'|i18n( 'design/standard/websitetoolbar/sort' )}" disabled="disabled" />
            <span class="d-none" id="ezwt-automatic-update-container" class="hide">{'Automatic update'|i18n( 'design/standard/websitetoolbar/sort' )} <input id="ezwt-automatic-update" type="checkbox" name="AutomaticUpdate" value="" /></span>
        {/if}
    </div>

    {* Sorting *}
    <div class="col d-flex" style="align-items: center;">
        <label class="pe-2">{'Sorting'|i18n( 'design/standard/websitetoolbar/sort' )}:</label>

        {def $sort_fields = hash( 6, 'Class identifier'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  7, 'Class name'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  5, 'Depth'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  3, 'Modified'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  9, 'Name'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  1, 'Path String'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  8, 'Priority'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  2, 'Published'|i18n( 'design/standard/websitetoolbar/sort' ),
                                  4, 'Section'|i18n( 'design/standard/websitetoolbar/sort' ) )
            $title = 'You cannot set the sorting method for the current location because you do not have permission to edit the current item.'|i18n( 'design/standard/websitetoolbar/sort' )
            $disabled = ' disabled="disabled"' }

        {if $node_can_edit}
            {set $title    = 'Use these controls to set the sorting method for the sub items of the current location.'|i18n( 'design/standard/websitetoolbar/sort' )}
            {set $disabled = ''}
            <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}" />
            <input type="hidden" name="RedirectURIAfterSorting" value="websitetoolbar/sort/{$node.node_id}" />
        {/if}

        <select id="ezwt-sort-field" name="SortingField" title="{$title}"{$disabled}>
        {foreach $sort_fields as $sort_index => $sort}
            <option value="{$sort_index}" {if eq( $sort_index, $node.sort_field )}selected="selected"{/if}>{$sort}</option>
        {/foreach}
        </select>

        <select id="ezwt-sort-order" name="SortingOrder" title="{$title}"{$disabled}>
            <option value="0"{if eq($node.sort_order, 0)} selected="selected"{/if}>{'Descending'|i18n( 'design/standard/websitetoolbar/sort' )}</option>
            <option value="1"{if eq($node.sort_order, 1)} selected="selected"{/if}>{'Ascending'|i18n( 'design/standard/websitetoolbar/sort' )}</option>
        </select>

        <input {if $disabled}class="btn btn-xs btn-disabled ms-2"{else}class="btn btn-xs btn-secondary ms-2"{/if} type="submit" name="SetSorting" value="{'Set'|i18n( 'design/standard/websitetoolbar/sort' )}" title="{$title}" {$disabled} />

        {undef $sort_fields $title $disabled}
    </div>
</div>

</form>

{undef}


<script type="text/javascript">
eZWTSortDD.init();
</script>
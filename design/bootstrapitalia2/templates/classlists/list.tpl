{ezscript_require( 'tools/ezjsselection.js' )}
{def $item_type = ezpreference( 'admin_classlists_limit' )
     $limit = min( $item_type, 3 )|choose( 10, 10, 25, 50 )
     $filter_hash = hash( 'parent_node_id', 1,'main_node_only', true(),'sort_by', array( $sort_method, $sort_order ),'limit', $limit,'offset', $view_parameters.offset )
     $filter_count_hash = hash( 'parent_node_id', 1,'main_node_only', true() )
     $nodes_count = 0
     $nodes_list = array()
     $confirm_js = ezini( 'DeleteSettings', 'ConfirmJavascript', 'lists.ini' )
     $move_to_trash = ezini( 'DeleteSettings', 'DefaultMoveToTrash', 'lists.ini' )
     $current_class = false()
     $required_fields = array()
     $required_labels = hash()
     $relations = array()}

{if $class_identifier}
    {set $filter_count_hash = hash( 'parent_node_id', 1,'main_node_only', true(),'class_filter_type', include,'class_filter_array', array( $class_identifier ) )}
    {set $filter_hash = hash( 'parent_node_id', 1,'sort_by', array( $sort_method, $sort_order ),'class_filter_type', include,'class_filter_array', array( $class_identifier ),'main_node_only', true(),'limit', $limit,'offset', $view_parameters.offset )}
    {set $current_class = fetch( 'class', 'list', hash( 'class_filter', array($class_identifier)))[0]}
    {foreach $current_class.data_map as $identifier => $class_attribute}
        {if $class_attribute.is_required}
            {set $required_fields = $required_fields|append($identifier)}
            {set $required_labels = $required_labels|merge(hash($identifier, $class_attribute.name))}
        {/if}
        {if $class_attribute.data_type_string|eq('ezobjectrelationlist')}
            {set $relations = $relations|append($class_attribute)}
        {/if}
    {/foreach}
{/if}

{debug-log msg='template fetch filter' var=$filter_hash}
{set $nodes_count = fetch( content, tree_count, $filter_count_hash )}
{set $nodes_list = fetch( content, tree, $filter_hash )}
{if is_set( $remove_count )}
    <div class="alert">
        <h2>{'%remove_count objects deleted'|i18n( 'classlists/list', , hash( '%remove_count', $remove_count ) )}</h2>
    </div>
{/if}
{if is_set( $error )}
    <div class="alert alert-danger">
        <h2>{$error|wash()}</h2>
    </div>
{/if}

{def $classlist = fetch( 'class', 'list', hash( 'class_filter', ezini( 'ListSettings', 'IncludeClasses', 'lists.ini' ),'sort_by', array( 'name', true() ) ) )
     $uri = ''}

<form method="post" id="class-list-menu-form">
    <div class="row">
        <div class="col form-group">
            <label for="classIdentifier">{'Classes list'|i18n( 'classlists/list' )}</label>
            <select name="classIdentifier" id="classIdentifier" class="form-control">
                {foreach $classlist as $class}
                    <option value="{$class.identifier|wash()}"{cond( $class_identifier|eq( $class.identifier ), ' selected="selected"' , '' )}>{$class.name|wash()}</option>
                {/foreach}
            </select>
        </div>
        <div class="col form-group">
            <label for="sortMethod">{'Sort by'|i18n( 'classlists/list' )}</label>
            {def $sort_methods = hash( 'depth', 'Depth','name', 'Name','path', 'Path','path_string', 'Path string','priority', 'Priority','modified', 'Modified','published', 'Published','section', 'Section' )}
            <select name="sortMethod" id="sortMethod" class="form-control">
                {foreach $sort_methods as $key => $sm}
                    <option value="{$key}"
                            {cond( $key|eq( $sort_method ), ' selected="selected"', '' )}
                            title="{$sm|i18n( 'classlists/list' )}">{$sm|i18n( 'classlists/list' )|shorten( 20 )}</option>
                {/foreach}
            </select>
            {undef $sort_methods}
        </div>
        <div class="col form-group">
            <label for="sortOrder">{'Sort order'|i18n( 'classlists/list' )}</label>
            <select name="sortOrder" id="sortOrder" class="form-control">
                <option value="ascending"{cond( $sort_order, ' selected="selected"', '' )}>{'Ascending'|i18n( 'classlists/list' )}</option>
                <option value="descending"{cond( $sort_order|not, ' selected="selected"', '' )}>{'Descending'|i18n( 'classlists/list' )}</option>
            </select>
        </div>
        <div class="col form-group">
            <label for="filterButton" style="visibility:hidden">{'Go'|i18n( 'classlists/list' )}</label>
            <input type="submit" class="btn btn-sm btn-primary text-white" value="{'Go'|i18n( 'classlists/list' )}"/>
        </div>
    </div>
</form>

<form name="classlists"
          method="post"
         {if $confirm_js|eq( 'enabled' )} onsubmit="return confirm('{'Are you sure you want to delete these objects ?'|i18n('classlists/list')|wash( 'javascript' )}');"{/if}
          action={$page_uri|ezurl()}>

    <p class="pull-right pull-end mt-3">
        {switch match=$limit}
        {case match=25}
            <a class="btn btn-xs btn-primary" href={concat( '/user/preferences/set/admin_classlists_limit/1/', $page_uri )|ezurl} title="{'Show 10 items per page.'|i18n( 'design/admin/node/view/full' )}">10</a>
            <span class="current btn btn-xs btn-outline-primary">25</span>
            <a class="btn btn-xs btn-primary" href={concat( '/user/preferences/set/admin_classlists_limit/3/', $page_uri )|ezurl} title="{'Show 50 items per page.'|i18n( 'design/admin/node/view/full' )}">50</a>
        {/case}

        {case match=50}
            <a class="btn btn-xs btn-primary" href={concat( '/user/preferences/set/admin_classlists_limit/1/', $page_uri )|ezurl} title="{'Show 10 items per page.'|i18n( 'design/admin/node/view/full' )}">10</a>
            <a class="btn btn-xs btn-primary" href={concat( '/user/preferences/set/admin_classlists_limit/2/', $page_uri )|ezurl} title="{'Show 25 items per page.'|i18n( 'design/admin/node/view/full' )}">25</a>
            <span class="current btn btn-xs btn-outline-primary">50</span>
        {/case}

        {case}
            <span class="current btn btn-xs btn-outline-primary">10</span>
            <a class="btn btn-xs btn-primary" href={concat( '/user/preferences/set/admin_classlists_limit/2/', $page_uri )|ezurl} title="{'Show 25 items per page.'|i18n( 'design/admin/node/view/full' )}">25</a>
            <a class="btn btn-xs btn-primary" href={concat( '/user/preferences/set/admin_classlists_limit/3/', $page_uri )|ezurl} title="{'Show 50 items per page.'|i18n( 'design/admin/node/view/full' )}">50</a>
        {/case}

        {/switch}
    </p>
    <h1>
        {if $class_identifier}{$current_class.name|wash()} - {/if}
        {'%count objects'|i18n( 'classlists/list', , hash( '%count', $nodes_count ) )}
    </h1>
{$required_fields|attribute(show,2)}
    <table class="table" cellspacing="0">
        <thead>
            <tr>
                <th class="remove"><img
                            src={'toggle-button-16x16.gif'|ezimage} alt="{'Invert selection.'|i18n( 'design/admin/node/view/full' )}"
                            title="{'Invert selection.'|i18n( 'design/admin/node/view/full' )}"
                            onclick="ezjs_toggleCheckboxes( document.classlists, 'DeleteIDArray[]' ); return false;"/>
                </th>
                <th class="name">{'Name'|i18n( 'design/admin/node/view/full' )}</th>
                {if count($required_fields)|gt(0)}
                    <th class="class"></th>
                    <th>{'Related contents'|i18n('bootstrapitalia')}</th>
                {else}
                    <th class="class">{'Type'|i18n( 'design/admin/node/view/full' )}</th>
                {/if}
                <th class="published">{'Published'|i18n( 'design/admin/node/view/full' )}</th>
                <th class="modified">{'Modified'|i18n( 'design/admin/node/view/full' )}</th>
                <th class="owner">{'Creator'|i18n( 'design/admin/node/view/full' )}</th>
                <th class="edit">&nbsp;</th>
            </tr>
        </thead>
        <tbody>
        {foreach $nodes_list as $k => $node}
            {def $missing = array()}
            {if count($required_fields)|gt(0)}
                {foreach $required_fields as $required_field}
                    {if $node.data_map[$required_field].has_content|not()}
                        {set $missing = $missing|append($required_field)}
                    {elseif and($node.data_map[$required_field].data_type_string|eq('ezinteger'), $node.data_map[$required_field].content|eq(0))}
                        {set $missing = $missing|append($required_field)}
                    {elseif and($node.data_map[$required_field].data_type_string|eq('ezxmltext'), $node.data_map[$required_field].content.output.output_text|strip_tags()|shorten(10)|trim()|eq('...'))}
                        {set $missing = $missing|append($required_field)}
                    {/if}
                {/foreach}
            {/if}
            <tr{if count($missing)} class="bg-light"{/if}>
                <td>
                    <input name="DeleteIDArray[]" value="{$node.node_id}"
                           type="checkbox"{if $node.can_remove|not()} disabled="disabled"{/if} />
                </td>
                <td>

                    {foreach $required_fields as $required_field}
                        {if $node.data_map[$required_field].data_type_string|eq('ezxmltext')}
                            $node.data_map[$required_field].content.output.output_text|strip_tags()|shorten(10)|trim()
                        {/if}
                    {/foreach}

                    <a href={$node.url_alias|ezurl()}>{$node.name|wash()}</a>
                    {if $node|has_attribute('identifier')}
                        <code class="d-block">{$node|attribute('identifier').content|wash()}</code>
                    {/if}
                    {if count($missing)}
                        <small class="d-block text-muted">Missing required fields: {foreach $missing as $m}{$required_labels[$m]}{delimiter}, {/delimiter}{/foreach}</small>
                    {/if}
                </td>
                {if count($required_fields)|gt(0)}
                    <td class="class">
                        {foreach $required_fields as $required_field}
                            {if $node|has_attribute($required_field)|not()}
                                {set $missing = $missing|append($required_field)}
                            {/if}
                        {/foreach}
                        {if count($missing)}
                            <i class="fa fa-warning" title="{$missing|implode(', ')}"></i>
                        {else}
                            <i class="fa fa-check"></i>
                        {/if}
                    </td>
                    <td style="font-size: .8em">
                        {foreach $relations as $relation}
                        {if $node|has_attribute($relation.identifier)}
                        <div class="m-0">
                            <strong>{$relation.name|wash()}:</strong>
                            <ul>
                            {foreach $node.data_map[$relation.identifier].content.relation_list as $related}
                                <li>{fetch(content,object,hash(object_id, $related.contentobject_id)).name|wash()}</li>
                            {/foreach}
                            </ul>
                        </div>
                        {/if}
                        {/foreach}
                    </td>
                {else}
                <td class="class">
                    <a href={concat( 'classlists/list/', $node.class_identifier )|ezurl()}>{$node.class_name|wash()}</a>
                </td>
                {/if}
                <td class="published">
                    {$node.object.published|l10n(datetime)}
                </td>
                <td class="modified">
                    {$node.object.modified|l10n(datetime)}
                </td>
                <td class="owner">
                    {$node.object.owner.name|wash()}
                </td>
                <td class="edit">
                    <a href={concat( '/content/edit/', $node.object.id )|ezurl()}><i class="fa fa-edit"></i></a>
                </td>
            </tr>
            {undef $missing}
        {/foreach}
        </tbody>
        <tfoot>
        <tr>
            <td colspan="7">
                <div class="my-3">
                    <label for="MoveToTrash">{'Move to trash'|i18n( 'classlists/list' )}</label>
                    <input type="checkbox" value="1" name="MoveToTrash"
                           id="MoveToTrash"{if $move_to_trash|eq( 'enabled' )} checked="checked"{/if} />
                    <input class="btn btn-xs btn-danger ms-5" type="submit" name="RemoveButton"
                           value="{'Remove selected'|i18n( 'design/admin/node/view/full' )}"
                           title="{'Remove the selected items from the list above.'|i18n( 'design/admin/node/view/full' )}"/>
                </div>
            </td>
        </tr>
        </tfoot>
    </table>

    {include name=navigator uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$nodes_count view_parameters=$view_parameters item_limit=$limit}

</form>

{undef $filter_hash $filter_count_hash $nodes_count $nodes_list $confirm_js $move_to_trash}

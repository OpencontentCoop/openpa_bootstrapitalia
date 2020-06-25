<div class="row mb-5">
    <div class="col-md-8 offset-md-2">
    
{let item_type=ezpreference( 'admin_list_limit' )
     number_of_items=min( $item_type, 3)|choose( 10, 10, 25, 50 )
     select_name='SelectedObjectIDArray'
     select_type='checkbox'
     select_attribute='contentobject_id'
     browse_list_count=0
     page_uri_suffix=false()
     node_array=array()
     bookmark_list=fetch('content','bookmarks',array())}
{if is_set( $node_list )}
    {def $page_uri=$requested_uri }
    {set browse_list_count = $node_list_count
         node_array        = $node_list
         page_uri_suffix   = concat( '?', $requested_uri_suffix)}
{else}
    {def $page_uri=concat( '/content/browse/', $main_node.node_id )}

    {set browse_list_count=fetch( content, list_count, hash( parent_node_id, $node_id, depth, 1, objectname_filter, $view_parameters.namefilter) )}
    {if $browse_list_count}
        {set node_array=fetch( content, list, hash( parent_node_id, $node_id, depth, 1, offset, $view_parameters.offset, limit, $number_of_items, sort_by, $main_node.sort_array, objectname_filter, $view_parameters.namefilter ) )}
    {/if}
{/if}

{if eq( $browse.return_type, 'NodeID' )}
    {set select_name='SelectedNodeIDArray'}
    {set select_attribute='node_id'}
{/if}

{if eq( $browse.selection, 'single' )}
    {set select_type='radio'}
{/if}

<form name="browse" action={$browse.from_page|ezurl()} method="post">

{if $browse.description_template}
    {include name=Description uri=$browse.description_template browse=$browse main_node=$main_node}
{else}
    <div class="attribute-header">
    <h1 class="long">{'Browse'|i18n( 'design/ocbootstrap/content/browse' )} - {$main_node.name|wash}</h1>
    </div>

    <p>{'To select objects, choose the appropriate radiobutton or checkbox(es), and click the "Select" button.'|i18n( 'design/ocbootstrap/content/browse' )}</p>
    <p>{'To select an object that is a child of one of the displayed objects, click the parent object name to display a list of its children.'|i18n( 'design/ocbootstrap/content/browse' )}</p>
{/if}

    {def $sezione_trasparenza = fetch('content','list',hash( parent_node_id,1,class_filter_type,'include',class_filter_array,array(trasparenza),limit,1))}

    {if count($bookmark_list)}
    <ul class="nav nav-tabs nav-fill overflow-hidden">
        <li role="presentation" class="nav-item">
            <a class="text-decoration-none nav-link active" data-toggle="tab" href="#structure">
                <span style="font-size: 1.2em">{'Content structure'|i18n( 'design/admin/parts/content/menu' )}</span>
            </a>
        </li>
        <li role="presentation" class="nav-item">
            <a class="text-decoration-none nav-link" data-toggle="tab" href="#bookmarks">
                <span style="font-size: 1.2em">{"Bookmarks"|i18n("design/standard/content/browse")}</span>
            </a>
        </li>
    </ul>

    <div class="tab-content mt-3">
        <div role="tabpanel" class="tab-pane active" id="structure">
    {/if}
            <div class="card mb-3">
                {def $current_node=fetch( content, node, hash( node_id, $browse.start_node ) )}
                {if $browse.start_node|gt( 1 )}
                    <div class="card-header px-2">
                        <a class="mr-3" href={concat( '/content/browse/', $main_node.parent_node_id, '/' )|ezurl}><i class="fa fa-arrow-circle-up fa-2x"></i></a>
                        <h5 class="d-inline">{$current_node.name|wash}</h5>
                        {if is_set($sezione_trasparenza[0])}
                            <a class="mt-2 float-right btn btn-primary btn-xs" href="{concat( '/content/browse/', $sezione_trasparenza[0].node_id, '/' )|ezurl(no)}">{$sezione_trasparenza[0].name|wash()}</a>
                        {/if}
                    </div>
                {/if}

                {include uri='design:content/browse_mode_list.tpl'}
            </div>

            {include name=Navigator
                     uri='design:navigator/google.tpl'
                     page_uri=concat('/content/browse/',$main_node.node_id)
                     item_count=$browse_list_count
                     view_parameters=$view_parameters
                     item_limit=$number_of_items}
            
    {if count($bookmark_list)}
        </div>
        <div role="tabpanel" class="tab-pane" id="bookmarks">
            <div class="card mb-3">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <tr>
                            <th class="tight">
                                {section show=eq( $select_type, 'checkbox' )}
                                    <a href="#" data-toggle="tooltip" data-placement="top" title="{'Invert selection'|i18n( 'design/ocbootstrap/content/browse_mode_list' )}" onclick="ezjs_toggleCheckboxes( document.browse, '{$select_name}[]' ); return false;">
                                        <i class="fa fa-check-circle"></i>
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
                        {foreach $bookmark_list as $item}
                            {def $ignore_nodes_merge = merge( $browse.ignore_nodes_select_subtree, $item.node.path_array )}
                            <tr>
                                <td width="1">
                                    {if and(
                                            or( $browse.permission|not,
                                                cond( is_set( $browse.permission.contentclass_id ),
                                                      fetch( content, access, hash( access, $browse.permission.access, contentobject, $item.node, contentclass_id, $browse.permission.contentclass_id ) ),
                                                      fetch( content, access, hash( access, $browse.permission.access, contentobject, $item.node ) ) )
                                            ),
                                            $browse.ignore_nodes_select|contains( $item.node_id )|not(),
                                            eq( $ignore_nodes_merge|count, $ignore_nodes_merge|unique|count )
                                        )}
                                        {if is_array($browse.class_array)}
                                            {if $browse.class_array|contains($item.object.content_class.identifier)}
                                                <input type="{$select_type}" name="{$select_name}[]" value="{$item.node[$select_attribute]}" />
                                            {else}
                                                <input type="{$select_type}" name="" value="" disabled="disabled" />
                                            {/if}
                                        {else}
                                            <input type="{$select_type}" name="{$select_name}[]" value="{$item.node[$select_attribute]}" />
                                        {/if}
                                    {else}
                                        {if and( or( eq( $browse.action_name, 'MoveNode' ), eq( $browse.action_name, 'CopyNode' ), eq( $browse.action_name, 'AddNodeAssignment' ) ), $item.node.object.content_class.is_container|not )}
                                            <input type="{$select_type}" name="{$select_name}[]" value="{$item.node[$select_attribute]}" />
                                        {else}
                                            <input type="{$select_type}" name="" value="" disabled="disabled" />
                                        {/if}
                                    {/if}
                                </td>

                                <td>
                                    {if and($item.node_id|ne( $main_node.node_id ), $browse.ignore_nodes_click|contains( $item.node_id )|not())}
                                        <a href="{concat( 'content/browse/', $item.node_id, '/' )|ezurl(no)}">{$item.node.name|wash()}</a>
                                    {else}
                                        {$item.node.name|wash()}
                                    {/if}
                                </td>
                                <td class="class">
                                    {$item.node.object.content_class.name|wash}
                                </td>
                            </tr>
                            {undef $ignore_nodes_merge}
                        {/foreach}
                    </table>
                </div>
            </div>
        </div>
    </div>
    {/if}

    {if $browse.persistent_data|count()}
    {foreach $browse.persistent_data as $key => $data_item}
        <input type="hidden" name="{$key|wash}" value="{$data_item|wash}" />
    {/foreach}
    {/if}


    <input type="hidden" name="BrowseActionName" value="{$browse.action_name}" />
    {if $browse.browse_custom_action}
    <input type="hidden" name="{$browse.browse_custom_action.name}" value="{$browse.browse_custom_action.value}" />
    {/if}

    

    <button class="float-left btn btn-primary" type="submit" name="SelectButton">{'Select'|i18n('design/ocbootstrap/content/browse')}</button>
    {if $cancel_action}
    <input type="hidden" name="BrowseCancelURI" value="{$cancel_action|wash}" />
    {/if}
    <button class="float-right btn btn-large btn-dark" type="submit" name="BrowseCancelButton">{'Cancel'|i18n( 'design/ocbootstrap/content/browse' )}</button>

</form>

{/let}
</div>
</div>

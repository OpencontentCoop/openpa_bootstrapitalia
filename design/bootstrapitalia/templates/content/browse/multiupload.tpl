{def $number_of_items=10
     $select_name='SelectedObjectIDArray'
     $select_type='checkbox'
     $select_attribute='contentobject_id'
     $browse_list_count=0
     $page_uri_suffix=false()
     $node_array=array()
     $bookmark_list=fetch('content','bookmarks',array())
     $is_search = false()}

{if is_set( $node_list )}
    {def $page_uri=$requested_uri
    $main_node = fetch( content, node, hash(node_id, $browse.start_node ) )}
    {set $browse_list_count = $node_list_count
    $node_array        = $node_list
    $page_uri_suffix   = concat( '?', $requested_uri_suffix, '&SubTreeArray[]=', $browse.start_node )
    $is_search = true()}
{else}
    {def $page_uri=concat( '/content/browse/', $main_node.node_id )}
    {set $browse_list_count=fetch( content, list_count, hash( parent_node_id, $node_id, depth, 1, objectname_filter, $view_parameters.namefilter) )}
    {if $browse_list_count}
        {set node_array=fetch( content, list, hash( parent_node_id, $node_id,
                                                    depth, 1,
                                                    offset, $view_parameters.offset,
                                                    limit, $number_of_items,
                                                    sort_by, array( 'published', false() ),
                                                    objectname_filter, $view_parameters.namefilter ) )}
    {/if}
{/if}

{if eq( $browse.return_type, 'NodeID' )}
    {set select_name='SelectedNodeIDArray'}
    {set select_attribute='node_id'}
{/if}

{if eq( $browse.selection, 'single' )}
    {set select_type='radio'}
{/if}

{if $browse.description_template}
    {include name=Description uri=$browse.description_template browse=$browse main_node=$main_node}
{else}
    <div class="maincontentheader">
        <h1>{"Browse"|i18n("design/standard/content/browse")} - {$main_node.name|wash}</h1>
    </div>
{/if}

<div class="row">
    <div class="col-md-8">
        <form action={"/content/search"|ezurl}>
            <div class="input-group">
                <input style="padding:6px" class="form-control" name="SearchText" type="text"
                       value="{cond( ezhttp_hasvariable('SearchText','get'), ezhttp('SearchText','get')|wash(),'')}"
                       size="12"/>
                <input type="hidden" value="{'Search'|i18n('openpa/search')}" name="SearchButton"/>
                <input type="hidden" value="{$browse.start_node}" name="SubTreeArray[]"/>
                <input name="Mode" type="hidden" value="browse"/>
                <div class="input-group-append">
                    <button name="SearchButton" value="{'Search'|i18n('openpa/search')}" id="searchbox_submit" type="submit"
                            class="btn btn-info searchbutton">
                        <i aria-hidden="true" class="fa fa-search"></i>
                    </button>
                    {if $is_search}
                      <a href="{concat('content/browse/', $browse.start_node)|ezurl(no)}" class="btn btn-danger">Annulla ricerca</a>
                    {/if}
                </div>
            </div>
        </form>
    </div>
    <div class="col-md-4">
        <form name="browse" method="post" action={$browse.from_page|ezurl}>
            <input class="btn btn-dark" type="submit" name="BrowseCancelButton" value="Annulla e torna alla modifica del contenuto"/>
        </form>
    </div>
</div>

<div class="row mt-3">
    <div class="col-md-6">

        {if and( $is_search, count($node_array)|eq(0) )}
            <div class="alert alert-warning clearfix">
                Nessun elemento trovato <a class="btn btn-sm btn-warning float-right" href={concat('content/browse/', $browse.start_node)|ezurl()}>Indietro</a>
            </div>
        {/if}

        <form class="clearfix" name="browse" method="post" action={$browse.from_page|ezurl}>
            <div id="selection" class="context-block" style="margin: 20px 0">
                <div class="card border-success">
                    <div class="card-header">
                        Elementi selezionati
                        <div class="spinner spinner-border spinner-border-sm" role="status">
                            <span class="sr-only">Loading...</span>
                        </div>
                    </div>
                    <table id="select_table" class="table bg-white" cellspacing="0">
                        <tbody></tbody>
                    </table>
                    {section var=PersistentData show=$browse.persistent_data loop=$browse.persistent_data}
                        <input type="hidden" name="{$PersistentData.key|wash}" value="{$PersistentData.item|wash}"/>
                    {/section}
                    <input type="hidden" name="BrowseActionName" value="{$browse.action_name}"/>
                    {if $browse.browse_custom_action}
                        <input type="hidden" name="{$browse.browse_custom_action.name}"
                               value="{$browse.browse_custom_action.value}"/>
                    {/if}
                    {if $cancel_action}
                        <input type="hidden" name="BrowseCancelURI" value="{$cancel_action}"/>
                    {/if}
                    <div class="card-footer">
                        <input class="btn btn-success d-block m-auto" type="submit" name="SelectButton" value="Carica la selezione nel contenuto"/>
                    </div>
                </div>
            </div>

            <div class="card">
                {def $current_node=fetch( content, node, hash( node_id, $browse.start_node ) )}
                {if $browse.start_node|gt( 1 )}
                    <div class="card-header">
                        <a href={concat( '/content/browse/', $main_node.parent_node_id, '/' )|ezurl}>
                            <i aria-hidden="true" class="fa fa-arrow-circle-up fa-2x align-middle"></i>
                        </a>
                        {$current_node.name|wash} <span class="badge badge-primary bg-primary">{$current_node.children_count}</span>
                    </div>
                {/if}

                <table id="browse_table" class="table" cellspacing="0">
                    <tbody>
                    {foreach $node_array as $item}
                        <tr id="object-{$item.contentobject_id}">
                            <td>
                                {def $ignore_nodes_merge=merge( $browse.ignore_nodes_select_subtree, $item.path_array )
                                $browse_permission = true()}
                                {if $browse.permission}
                                    {if $browse.permission.contentclass_id}
                                        {if is_array( $browse.permission.contentclass_id )}
                                            {foreach $browse.permission.contentclass_id as $contentclass_id}
                                                {set $browse_permission = fetch( 'content', 'access', hash( 'access', $browse.permission.access, 'contentobject', $item,'contentclass_id', $contentclass_id ) )}
                                                {if $browse_permission|not}{break}{/if}
                                            {/foreach}
                                        {else}
                                            {set $browse_permission = fetch( 'content', 'access', hash( 'access', $browse.permission.access, 'contentobject',   $item,'contentclass_id', $browse.permission.contentclass_id ) )}
                                        {/if}
                                    {else}
                                        {set $browse_permission = fetch( 'content', 'access', hash( 'access', $browse.permission.access,'contentobject',   $item ) )}
                                    {/if}
                                {/if}
                                {if and( $browse_permission, $browse.ignore_nodes_select|contains( $item.node_id )|not, eq( $ignore_nodes_merge|count, $ignore_nodes_merge|unique|count ) )}
                                    {if is_array( $browse.class_array )}
                                        {if $browse.class_array|contains( $item.object.content_class.identifier )}
                                            <input type="{$select_type}" name="{$select_name}[]" value="{$item[$select_attribute]}"/>
                                        {else}
                                            <input type="{$select_type}" name="_Disabled" value="" disabled="disabled"/>
                                        {/if}
                                    {else}
                                        {if and( or( eq( $browse.action_name, 'MoveNode' ), eq( $browse.action_name, 'CopyNode' ), eq( $browse.action_name, 'AddNodeAssignment' ) ), $item.object.content_class.is_container|not )}
                                            <input type="{$select_type}" name="{$select_name}[]" value="{$item[$select_attribute]}" disabled="disabled"/>
                                        {else}
                                            <input type="{$select_type}" name="{$select_name}[]" value="{$item[$select_attribute]}"/>
                                        {/if}
                                    {/if}
                                {else}
                                    <input type="{$select_type}" name="_Disabled" value="" disabled="disabled"/>
                                {/if}
                            </td>
                            <td>
                                {if and( is_set($item.data_map.image), $item.data_map.image.has_content )}
                                    <img data-object="{$item.contentobject_id}" class="load-preview img-thumbnail" src={$item.data_map.image.content['small'].url|ezroot} />
                                {/if}
                            </td>
                            <td class="object-name">
                                {set $ignore_nodes_merge=merge( $browse.ignore_nodes_click, $item.path_array )}
                                {if eq( $ignore_nodes_merge|count, $ignore_nodes_merge|unique|count )}
                                    {if and( or( ne( $browse.action_name, 'MoveNode' ), ne( $browse.action_name, 'CopyNode' ) ), $item.object.content_class.is_container )}
                                        <a href={concat( '/content/browse/', $item.node_id )|ezurl}>{$item.name|wash}</a>
                                    {else}
                                        {$item.name|wash}
                                    {/if}
                                {else}
                                    {$item.name|wash}
                                {/if}
                            </td>
                            <td>
                                {$item.object.content_class.name|wash}
                            </td>
                            <td>
                              <span data-object="{$item.contentobject_id}" class="load-preview">
                                  <i aria-hidden="true" class="fa fa-search-plus"></i>
                              </span>
                            </td>
                        </tr>
                        {undef $ignore_nodes_merge $browse_permission}
                    {/foreach}
                    </tbody>
                </table>
            </div>

            <div class="mt-3 mb-3">
            {include name=navigator
                     uri='design:navigator/alphabetical.tpl'
                     page_uri=$page_uri
                     page_uri_suffix=$page_uri_suffix
                     item_count=$browse_list_count
                     view_parameters=$view_parameters
                     node_id=$browse.start_node
                     item_limit=$number_of_items}
            </div>
        </form>
    </div>
    <div class="col-md-6">
        <div id="preview-container"></div>
        <div id="spinner" class="mt-5 text-center">
            <div class="spinner-border" role="status">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
    </div>
</div>


{ezscript_require( array( 'ezjsc::jquery' ) )}
{ezscript( array( 'ezjsc::jqueryio', 'jcookie.js' ) )}

<script type="text/javascript">
    var previewIcon = {'websitetoolbar/ezwt-icon-preview.png'|ezimage()|shared_asset()};
    {literal}
    $(document).ready(function () {

        var selectionContainer = $("#selection");
        var selectTable = $("#select_table");
        var spinner = $('#spinner').hide();
        selectionContainer.hide();

        var displayImageDetail = function (e) {
            $('table').find('tr').removeClass('table-active');
            $(this).closest('tr').addClass('table-active');
            var objectId = $(this).data('object');
            spinner.show();
            $('#preview-container').empty();
            $.ez('ezjsctemplate::preview::' + objectId, false, function (data) {
                if (data.error_text.length) {
                    alert(data.error_text);
                } else {
                    $('#preview-container').html(data.content);
                }
                spinner.hide();
            });
            e.preventDefault();
        };

        var selectUnselect = function (e) {
            var checkbox = $(e.currentTarget);
            var row = checkbox.closest('tr');
            if (checkbox.is(':checked')) {
                selectTable.find('tbody').append(row);
                addSelect(checkbox.val());
            } else {
                $("#browse_table").find('tbody').prepend(row);
                removeSelect(checkbox.val());
                if ($("tr", selectTable).length === 0) {
                    selectionContainer.hide();
                }
            }
        };

        var addSelect = function (selection) {
            var cookies = readCookie('ocb_browse');
            if (cookies == null || cookies === '-' || cookies === '') {
                cookies = selection;
                selectionContainer.show();
            } else {
                cookies += '-' + selection;
            }
            eraseCookie('ocb_browse');
            createCookie('ocb_browse', cookies);
        };

        var removeSelect = function (selection) {
            var cookie = readCookie('ocb_browse');
            var cookies = cookie.split('-');
            $.each(cookies, function (i, v) {
                if (v === selection) cookies.splice(i, 1);
            });
            eraseCookie('ocb_browse');
            createCookie('ocb_browse', cookies.join('-'));
        };

        var showSelectedItems = function () {
            var cookie = readCookie('ocb_browse');
            if (cookie != null && cookie !== '') {
                selectionContainer.show();
                $(".spinner", selectionContainer).show();
                var cookies = cookie.split('-');
                var loadedItems = 0;
                $.each(cookies, function (i, v) {
                    $.ez('ezjsctemplate::browse_list_row::' + v + '::{/literal}{$select_type}{literal}::{/literal}{$select_name}{literal}::1', false, function (content) {
                        if (content.error_text.length) {
                            alert(content.error_text);
                        } else {
                            selectTable.find('tbody').prepend(content.content);
                        }
                        loadedItems++;
                        if (loadedItems === cookies.length){
                            $(".spinner", selectionContainer).hide();
                        }
                    });
                });
            }
        };

        var inlineEdit = function () {
            $('span.inline-form').each(function () {
                $(this).hide();
                $(this).prev().show()
            });
            var editButton = $(this);
            var attributeData = editButton.data();
            var text = editButton.parent();
            var form = text.next();
            text.hide();
            form.show().find('button').bind('click', function () {
                var value = form.find(attributeData.input).val();
                form.hide();
                text.show();
                $('#preview-container').empty();
                spinner.show();
                $.ez('ocb::attribute_edit', {
                    objectId: attributeData.objectid,
                    attributeId: attributeData.attributeid,
                    version: attributeData.version,
                    content: value
                }, function (result) {
                    if (result.error_text.length) {
                        alert(result.error_text);
                    } else {
                        $('#object-' + attributeData.objectid + ' td.object-name').html(result.content);
                    }
                    $.ez('ezjsctemplate::preview::' + attributeData.objectid, false, function (data) {
                        if (data.error_text.length) {
                            alert(data.error_text);
                        } else {
                            $('#preview-container').html(data.content);
                        }
                        spinner.hide();
                    });
                });
            });
        };

        $(document).on('click', '.load-preview', displayImageDetail);
        $(document).on('change', 'td > input:checkbox', selectUnselect);
        $(document).on('submit', 'form[name="browse"]', function () {
            eraseCookie('ocb_browse');
        });
        $(document).on('click', '.inline-edit', inlineEdit);

        $('.load-preview').css({cursor: 'pointer'});
        $(".load-preview:first").trigger('click');
        showSelectedItems();
    });
    {/literal}
</script>

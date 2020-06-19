{cache-block keys=array( $user.contentobject_id )}

{def $latest_content = fetch( 'content', 'tree', hash( 'parent_node_id',   1,
                                                       'limit',            $block.number_of_items,
                                                       'main_node_only',   true(),
                                                       'sort_by',          array( 'modified', false() ),
                                                       'attribute_filter', array( array( 'owner', '=', $user.contentobject_id ) ) ) )}



{if $latest_content}
    <div class="my-3 p-3 bg-white rounded shadow-sm">
        <h6 class="border-bottom border-gray pb-2 mb-0">{'My latest content'|i18n( 'design/admin/dashboard/latest_content' )}</h6>
        <table class="table table-striped table-condensed" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <th>{'Name'|i18n( 'design/admin/dashboard/latest_content' )}</th>
                <th>{'Type'|i18n( 'design/admin/dashboard/latest_content' )}</th>
                <th>{'Modified'|i18n( 'design/admin/dashboard/latest_content' )}</th>
                <th class="tight"></th>
            </tr>
            {foreach $latest_content as $latest_node sequence array( 'bglight', 'bgdark' ) as $style}
                <tr class="{$style}">
                    <td>
                        <a href="{$latest_node.url_alias|ezurl('no')}"
                           title="{$latest_node.name|wash()}">{$latest_node.name|shorten('30')|wash()}</a>
                    </td>
                    <td>
                        {$latest_node.class_name|wash()}
                    </td>
                    <td>
                        {$latest_node.object.modified|l10n('shortdate')}
                    </td>
                    <td>
                        {if $latest_node.can_edit}
                            <a href="{concat( 'content/edit/', $latest_node.contentobject_id, '/f/', $latest_node.object.default_language )|ezurl('no')}">
                                <i class="fa fa-pencil"></i> <span
                                        class="sr-only">{'Edit'|i18n( 'design/admin/dashboard/all_latest_content' )}</span>
                            </a>
                        {/if}
                    </td>
                </tr>
            {/foreach}
        </table>
    </div>
{/if}

{undef $latest_content}

{/cache-block}

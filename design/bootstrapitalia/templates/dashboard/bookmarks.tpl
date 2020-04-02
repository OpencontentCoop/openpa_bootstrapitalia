{def $bookmark_list = fetch( 'content', 'bookmarks', hash( 'limit', 20 ) ) $bookmark_node = 0}

{if $bookmark_list}
<div class="my-3 p-3 bg-white rounded shadow-sm">
    <form action={concat("content/bookmark/")|ezurl} method="post">
        <h6 class="border-bottom border-gray pb-2 mb-0">
            {'Bookmarks'|i18n( 'design/admin/pagelayout' )}
            {if $bookmark_list}
                <button class="btn btn-xs pull-right" type="submit" name="RemoveButton"
                        value="{'Remove'|i18n('design/standard/content/view')}"
                        alt="{'Remove'|i18n('design/standard/content/view')}">
                    <i class="fa fa-trash"></i> Rimuovi selezionati
                </button>
            {/if}
        </h6>

        <table class="table table-striped table-condensed" width="100%" cellpadding="0" cellspacing="0" border="0">

            {foreach $bookmark_list as $bookmark}
                {set $bookmark_node = $bookmark.node}
                <tr>
                    <td width="1"><input type="checkbox" name="DeleteIDArray[]" value="{$bookmark.id}"/></td>
                    <td><a href={$bookmark_node.url_alias|ezurl}>{$bookmark_node.name|wash}</a></td>
                </tr>
            {/foreach}
            <tr>
            </tr>
        </table>
    </form>
</div>
{undef $bookmark_list $bookmark_node}
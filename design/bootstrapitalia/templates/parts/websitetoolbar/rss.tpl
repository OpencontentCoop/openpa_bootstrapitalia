{if is_set( ezini( 'RSSSettings', 'DefaultFeedItemClasses', 'site.ini' )[ $content_object.class_identifier ] )}
    {def $create_rss_access = fetch( 'user', 'has_access_to', hash( 'module', 'rss', 'function', 'edit' ) )}
    {if $create_rss_access}
        <li>
        {if fetch( 'rss', 'has_export_by_node', hash( 'node_id', $current_node.node_id ) )}
            <button class="btn list-item left-icon" type="submit" name="RemoveNodeFeed" title="{'Remove node RSS/ATOM feed'|i18n( 'design/ocbootstrap/parts/website_toolbar' )}">
                <i aria-hidden="true" class="fa fa-rss"></i>
                Rimuovi RSS
            </button>
        {else}
            <button class="btn list-item left-icon" type="submit" name="CreateNodeFeed" title="{'Create node RSS/ATOM feed'|i18n( 'design/ocbootstrap/parts/website_toolbar' )}">
                <i aria-hidden="true" class="fa fa-rss"></i>
                Crea RSS
            </button>
        {/if}
        </li>
    {/if}
{/if}

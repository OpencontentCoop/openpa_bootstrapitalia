{if and(ezmodule('push','node'), fetch( 'user', 'has_access_to', hash( 'module', 'push', 'function', 'node' ) ))}
<li>
    <a class="list-item left-icon"
       href="{concat('/push/node/', $current_node.node_id, '/', ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini'))|ezurl(no)}">
        <i class="fa fa-plus-square"></i>
        Push to social
    </a>
</li>
{/if}
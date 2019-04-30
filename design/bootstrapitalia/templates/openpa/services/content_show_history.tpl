{if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'history' ) )}
<p class="text-sans-serif"><a href="{concat('content/history/',$node.contentobject_id)|ezurl(no)}" title="Vai alla storia di questo contenuto"><small>Consulta versioni precedenti</small></a></p>
{/if}
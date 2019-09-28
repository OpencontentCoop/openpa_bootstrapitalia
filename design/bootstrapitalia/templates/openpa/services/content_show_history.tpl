{if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'history' ) )}
<p class="text-sans-serif my-3"><a href="{concat('content/history/',$node.contentobject_id)|ezurl(no)}" title="{'Go to the history of this content'|i18n('bootstrapitalia')}"><small>{'See previous versions'|i18n('bootstrapitalia')}</small></a></p>
{/if}
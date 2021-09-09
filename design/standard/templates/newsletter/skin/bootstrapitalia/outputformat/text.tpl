{set-block variable=$subject scope=root}{ezini('NewsletterMailSettings', 'EmailSubjectPrefix', 'cjw_newsletter.ini')} {$contentobject.name|wash}{/set-block}
{def $site_url = concat('https://', ezini('SiteSettings', 'SiteURL', 'site.ini'))}
{def $edition_data_map = $contentobject.data_map}
{def $main_node = $contentobject.contentobject.main_node}

{if $edition_data_map.title.has_content}
<h1>{$main_node.parent.name|wash()} - {$edition_data_map.title.content|wash()} - {currentdate()|l10n('shortdate')}</h1>
{/if}

{if $edition_data_map.description.has_content}
     {attribute_view_gui attribute=$edition_data_map.description}
{/if}

{def $list_items = fetch('content', 'list', hash( 'parent_node_id', $contentobject.contentobject.main_node_id,
                                                  'sort_by', array( 'priority' , true() ) ) )}

{if $list_items|count|ne(0)}
<hr>
{foreach $list_items as $item}
    <h2>{$item.name|wash}</h2>

    {* text *}
    {if $item|has_abstract()}   
        {$item|abstract()}
    {/if}

    Link: {concat($site_url, '/', $item.object.main_node.url_alias)}
	{delimiter}<hr>{/delimiter}
{/foreach}
{/if}


<hr>

<h2>{'To unsubscribe from this newsletter please visit the following link'|i18n('cjw_newsletter/skin/default')}</h2> 
{concat($site_url,'/newsletter/unsubscribe/#_hash_unsubscribe_#')}

<hr>

{if and( is_set( $main_node.parent.data_map.footer_link), $main_node.parent.data_map.footer_link.has_content )}

&copy; 2014 - {currentdate()|datetime( 'custom', '%Y' )} {ezini('SiteSettings', 'SiteName')|wash()}

{foreach $main_node.parent.data_map.footer_link.content.relation_list as $relation}  
{def $related = fetch( content, object, hash( object_id, $relation.contentobject_id ) )}        
{$related.name}: {concat($site_url, $related.main_node.url_alias|ezurl('no'))}
{undef $related}
{/foreach}
{/if}
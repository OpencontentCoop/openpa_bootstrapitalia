{set_defaults( hash('image_class', 'reference'))}
{if $node|attribute($identifier).data_type_string|eq('ezimage')}{def $image = $node|attribute($identifier)}{$image.content[$image_class].url|ezroot(no)}{undef $image}
{elseif $node|attribute($identifier).data_type_string|eq('ezobjectrelationlist')}
{foreach $node|attribute($identifier).content.relation_list as $item}{include name="related_main_image_as_background" uri='design:atoms/image_url.tpl' node=fetch(content,node, hash(node_id, $item.node_id))}{break}{/foreach}{/if}{break}{/if}
{unset_defaults(array('image_class'))}
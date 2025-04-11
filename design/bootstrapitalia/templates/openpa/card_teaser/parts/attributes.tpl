{if $attributes.show|count()|gt(0)}
    {foreach $attributes.show as $identifier}
        {if $node|has_attribute($identifier)}
            <p class="mt-1{if $node|attribute($identifier).data_type_string|eq('ezemail')} text-truncate{/if}">
            {if $attributes.show_label|contains($identifier)}
                <strong>{$node|attribute($identifier).contentclass_attribute_name}:</strong>
            {/if}
            {if $node|attribute($identifier).data_type_string|eq('ezobjectrelationlist')}
                <div id="{concat($node|attribute($identifier).contentclass_attribute_identifier,'-',$node|attribute($identifier).id)}">
                {foreach $node|attribute($identifier).content.relation_list as $item}
                    {def $item_object = fetch(content, object, hash(object_id, $item.contentobject_id))}                    
                    {content_view_gui content_object=$item_object 
                                      view=embed-inline 
                                      count=count($node|attribute($identifier).content.relation_list) 
                                      container_parent_id=concat($node|attribute($identifier).contentclass_attribute_identifier,'-',$node|attribute($identifier).id)
                                      container_has_image=cond(and($attributes.show|contains('image'), $node|has_attribute('image')), true(), false())
                                      show_icon=false() 
                                      show_link=cond($attributes.show_link|contains($identifier), true(), false())}
                    {undef $item_object}
                {/foreach}
                </div>
            {elseif $node|attribute($identifier).data_type_string|ne('ezimage')}
                {attribute_view_gui attribute=$node|attribute($identifier)
                                    image_class=small
                                    show_link=false()
                                    only_address=true()
                                    avoid_oembed=true()}
            {else}
            {/if}
            </p>
        {/if}
    {/foreach}
{/if}
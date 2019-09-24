{def $attributes = class_extra_parameters($object.class_identifier, 'card_small_view')}
{if $count|gt(1)}
    <strong>{$object.name|wash()}</strong>
{/if}
{if $attributes.show|count()|gt(0)}
    {foreach $attributes.show as $identifier}
        {if $object|has_attribute($identifier)}
            <div>
            {if $attributes.show_label|contains($identifier)}
                <strong>{$object|attribute($identifier).contentclass_attribute_name}</strong>
            {/if}              
            {if $object|attribute($identifier).data_type_string|eq('ezobjectrelationlist')}
                {foreach $object|attribute($identifier).content.relation_list as $item}
                    {def $item_object = fetch(content, object, hash(object_id, $item.contentobject_id))}
                    <p>
                        {content_view_gui content_object=$item_object 
                                          view=embed-inline 
                                          count=count($node|attribute($identifier).content.relation_list)                                           
                                          show_icon=false() 
                                          show_link=cond($attributes.show_link|contains($identifier), true(), false())
                                          container_has_image=cond(is_set($container_has_image), $container_has_image, false())}
                    </p>
                    {undef $item_object}
                {/foreach}
            {elseif $object|attribute($identifier).data_type_string|ne('ezimage')}                
                {attribute_view_gui attribute=$object|attribute($identifier) 
                                    image_class=small 
                                    show_link=false() 
                                    only_address=true() 
                                    container_has_image=cond(is_set($container_has_image), $container_has_image, false())}
            {/if}
            </div>
        {/if}        
    {/foreach}
{/if}
{undef $attributes}
{def $attributes = class_extra_parameters($object.class_identifier, 'card_small_view')
     $min_view_accordion = 0}

{if $count|gt($min_view_accordion)}
    <div id="opening-hours-title-{$object.id}" class="py-1">
        <a href="#opening-hours-{$object.id}-{$container_parent_id}"
          class="text-decoration-none opening-hours-accordion"
          data-toggle="collapse"
          data-bs-toggle="collapse"
          data-target="#opening-hours-{$object.id}-{$container_parent_id}"
          data-bs-target="#opening-hours-{$object.id}-{$container_parent_id}"
          aria-controls="opening-hours-{$object.id}-{$container_parent_id}"
          role="button">
            <i aria-hidden="true" class="fa fa-clock-o"></i> {$object.name|wash()} <i aria-hidden="true" class="fa fa-caret-down"></i>
        </a>
    </div>
{/if}
{if $attributes.show|count()|gt(0)}
    {if $count|gt($min_view_accordion)}<div class="collapse p-2 lightgrey-bg-c1 mb-1" id="opening-hours-{$object.id}-{$container_parent_id}" aria-labelledby="opening-hours-title-{$object.id}" data-parent="#{$container_parent_id}">{/if}
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
    {if $count|gt($min_view_accordion)}</div>{/if}
{/if}
{undef $attributes $min_view_accordion}
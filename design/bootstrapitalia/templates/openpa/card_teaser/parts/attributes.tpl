{if $attributes.show|count()|gt(0)}
    {foreach $attributes.show as $identifier}
        {if $node|has_attribute($identifier)}
            <div class="mt-1">
            {if $attributes.show_label|contains($identifier)}
                <strong>{$node|attribute($identifier).contentclass_attribute_name}:</strong>
            {/if}
            {if $node|attribute($identifier).data_type_string|eq('ezobjectrelationlist')}
                {foreach $node|attribute($identifier).content.relation_list as $item}
                    {def $item_object = fetch(content, object, hash(object_id, $item.contentobject_id))}                    
                    <div>{content_view_gui content_object=$item_object view=embed-inline count=count($node|attribute($identifier).content.relation_list) show_icon=false() show_link=cond($attributes.show_link|contains($identifier), true(), false())}</div>
                    {undef $item_object}
                {/foreach}
            {elseif $node|attribute($identifier).data_type_string|ne('ezimage')}
                {attribute_view_gui attribute=$node|attribute($identifier) image_class=small show_link=false() only_address=true()}
            {/if}
            </div>
        {/if}
    {/foreach}
{/if}
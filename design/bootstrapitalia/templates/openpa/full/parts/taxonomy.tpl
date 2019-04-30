{set_defaults( hash(
    'show_title', true()
))}

{if or($node|has_attribute('topics'), $node|has_attribute('has_public_event_typology'))}
<div class="mt-4 mb-4">
    {if $show_title}
    <h6><small>Argomenti</small></h6>
    {/if}

    {if $node|has_attribute('topics')}
    {foreach $node|attribute('topics').content.relation_list as $item}
        {def $object = fetch(content, object, hash(object_id, $item.contentobject_id))}
        <a href="{$object.main_node.url_alias|ezurl(no)}"><div class="chip chip-simple chip-primary"><span class="chip-label">{$object.name|wash()}</span></div></a>
        {undef $object}
    {/foreach}
    {/if}
    
    {if $node|has_attribute('has_public_event_typology')}
        {attribute_view_gui attribute=$node|attribute('has_public_event_typology')}
    {/if}

</div>
{/if}

{unset_defaults(array(
    'show_title'
))}
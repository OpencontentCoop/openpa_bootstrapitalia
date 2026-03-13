{if $attribute.has_content}
  {def $nodes = array()}
  {foreach $attribute.content.relation_list as $item}
    {set $nodes = $nodes|append(fetch(content, node, hash(node_id, $item.node_id)))}
  {/foreach}
  {def $gpx_attr = $attribute.object.data_map.gpx_attachment}
  {def $gpx_url = cond($gpx_attr.has_content, concat('/content/download/', $attribute.object.id, '/', $gpx_attr.id, '/file/', $gpx_attr.content.original_filename), '')}
  {*include uri='design:atoms/itinerary_map.tpl' items=$nodes block_id=$attribute.id gpx_url=$gpx_url*}
  {undef $nodes $gpx_attr $gpx_url}
  <div class="procedure-wrapper" id="procedure-{$attribute.id}">
        {foreach $attribute.content.relation_list as $index => $item}
            {def $counter = $index|inc()}
            {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
            <div class="procedure-item mb-5">
                <div class="procedure-item-header d-flex align-items-center"
                    id="heading-{$object.id}">
                    <span class="procedure-number">{$counter}</span>
                    <h3 class="procedure-title">{$object.name|wash()}</h3>
                </div>
                <div class="procedure-item-body pt-3">
                    <div class="procedure-item-content richtext-wrapper lora">

                        {def $attributes = class_extra_parameters($object.class_identifier, 'table_view')}
                        {foreach $object.data_map as $identifier => $attribute}
                            {if $attributes.show|contains($identifier)|not()}
                                {skip}
                            {/if}
                            {def $do = cond($object|has_attribute($identifier), true(), false())}
                            {if $attributes.show_empty|contains($identifier)}
                                {set $do = true()}
                            {/if}
                            {if $do}
                                <div class="mb-3">
                                {if $attributes.show_label|contains($identifier)}
                                    <h5>{$object|attribute($identifier).contentclass_attribute_name|wash()}</h5>
                                {/if}
                                {attribute_view_gui attribute=$object|attribute($identifier)
                                                    view_context=howto_step
                                                    attribute_group=false()
                                                    image_class=imagelargeoverlay
                                                    attribute_index=$index
                                                    context_class=$object.class_identifier
                                                    relation_view=banner
                                                    relation_has_wrapper=true()
                                                    show_link=true()
                                                    tag_view="chip-lg mr-2 me-2"}
                                </div>
                            {/if}
                            {undef $do}
                        {/foreach}
                        {undef $attributes}
                    </div>
                </div>
            </div>
            {undef $object $counter}
        {/foreach}
    </div>
{/if}

{run-once}
{literal}

<style>
    .procedure-item-header{
        background: #f4fafb;
        font-size: 1.15em;
        padding: 0;
        font-weight: 600;
    }
    .procedure-item-header-open{
        background: var(--bs-primary);
        color: #fff
    }
    .procedure-title{
        padding: 7px 10px;
        font-size: 1em;
        line-height: 1;
        font-weight: 600;
        margin-bottom: 0;
    }
    .procedure-number{
        padding: 7px 20px;
        border-right: 2px solid #fff;
    }
    .procedure-item-body{
        padding-left: 36px;
        margin-left: 27px;
        border-left: 1px solid #c5c7c9;
    }
    .procedure-toggle{
        font-size: .875em;
        text-decoration: none;
        color: var(--bs-primary);
        margin: 12px 0 20px;
        font-weight: 600;
    }
    .procedure-toggle .icon {
        width: 25px;
        height: 25px;
    }
</style>
{/literal}
{/run-once}
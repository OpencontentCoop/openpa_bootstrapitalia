{set_defaults(hash(
    'relation_view', 'list',
    'relation_has_wrapper', false(),
    'context_class', false()
))}

{def $node_list = array()}
{if and(is_active_public_service($attribute.object), $attribute.has_content)}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}
    {foreach $node_list as $index => $child}
        <div data-element="{if and($child|has_attribute('has_channel_type'), $child|attribute('has_channel_type').content.keywords|contains('Applicazione Web'))}service-online-access{elseif and($child|has_attribute('has_channel_type'), $child|attribute('has_channel_type').content.keywords|contains('Sportello Pubblica Amministrazione'))}service-booking-access{else}service-generic-access{/if}">
        {if $child|has_attribute('abstract')}
            <div class="text-paragraph lora mb-4">
                {attribute_view_gui attribute=$child|attribute('abstract')}
            </div>
        {/if}
        {if $child.data_map.channel_url.has_content}
            <div class="mb-4">
                {if has_custom_booking_url($child|attribute('channel_url'), $attribute.object)}
                    <a class="text-primary btn btn-outline-primary text-primary bg-white mobile-full font-sans-serif"
                       href="{concat('/prenota_appuntamento?service_id=', $attribute.contentobject_id)|ezurl(no)}">
                        {$child|attribute('channel_url').data_text|wash( xhtml )}
                    </a>
                {else}
                    {attribute_view_gui attribute=$child|attribute('channel_url') css_class=cond($index|eq(0), "btn btn-primary fw-bold mobile-full font-sans-serif", "text-primary btn btn-outline-primary t-primary bg-white mobile-full font-sans-serif")}
                {/if}
            </div>
        {/if}
        </div>
    {/foreach}
{/if}

{undef $node_list}

{unset_defaults(array('relation_view', 'relation_has_wrapper'))}
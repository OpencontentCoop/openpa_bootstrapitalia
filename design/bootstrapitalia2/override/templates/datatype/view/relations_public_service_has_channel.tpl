{set_defaults(hash(
    'relation_view', 'list',
    'relation_has_wrapper', false(),
    'context_class', false()
))}

{def $node_list = array()}
{def $is_active = is_active_public_service($attribute.object)}
{if openpaini('ViewSettings', 'ForceShowServiceChannel', 'disabled')|eq('enabled')}
    {set $is_active = true()}
{/if}
{if and($is_active, $attribute.has_content)}
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

{def $has_channel_help_link = false()}
{def $hide_main_channel = cond(and($attribute.object|has_attribute('hide_main_channel'), $attribute.object|attribute('hide_main_channel').data_int|eq(1)), true(), false())}
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
                {attribute_view_gui attribute=$child|attribute('channel_url')
                                    service=$attribute.object
                                    context=list
                                    css_class=cond(or($index|eq(0), $hide_main_channel), "btn btn-primary fw-bold mobile-full font-sans-serif", "text-primary btn btn-outline-primary bg-white mobile-full font-sans-serif")}
                {if $has_channel_help_link|not()}
                    {include uri='design:parts/channel_help_link.tpl' object=$child.object}
                    {set $has_channel_help_link = true()}
                {/if}
            </div>
        {/if}
        </div>
    {/foreach}
{/if}
{undef $has_channel_help_link}

{undef $node_list}

{unset_defaults(array('relation_view', 'relation_has_wrapper'))}
{if and(is_active_public_service($node), $node|has_attribute('has_channel'))}
    {def $has_channel_help_link = false()}
    {foreach $node|attribute('has_channel').content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if and($content_object.can_read, $content_object.data_map.channel_url.has_content)}
                <div data-element="service-main-access">
                    {attribute_view_gui attribute=$content_object|attribute('channel_url') service=$node.object context=main}
                    {if $has_channel_help_link|not()}
                        {include uri='design:parts/channel_help_link.tpl' object=$content_object}
                        {set $has_channel_help_link = true()}
                    {/if}
                </div>
                {break}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
    {undef $has_channel_help_link}
{/if}
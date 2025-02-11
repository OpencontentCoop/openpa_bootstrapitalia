<div class="row my-3">
    <label for="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}"
           class="col-12 col-form-label font-weight-bold">{$attribute.label|wash()}:</label>
    <div class="col-12 d-flex">
        {def $topics = fetch(content, object, hash(remote_id, 'topics'))
             $topic_list = cond($topics, tree_menu( hash( 'root_node_id', $topics.main_node_id, 'user_hash', false(), 'scope', 'side_menu')), array())
             $custom_topic_container = fetch(content, object, hash(remote_id, 'custom_topics'))
             $has_custom_topics = cond(and($custom_topic_container, $custom_topic_container.main_node.children_count))}
        <select id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control select_to_string" onchange="select_to_string(this)">
            <option></option>
            {foreach $topic_list.children as $child}
                {if and($custom_topic_container, $custom_topic_container.main_node_id|eq($child.item.node_id))}{skip}{/if}
                <option value="{$child.item.node_id}">{$child.item.name|wash()} ({$child.item.node_id})</option>
                {if $child.has_children}
                    {foreach $child.children as $child1}
                        <option value="{$child1.item.node_id}">&nbsp;{$child1.item.name|wash()} ({$child1.item.node_id})</option>
                        {if $child1.has_children}
                            {foreach $child1.children as $child2}
                                <option value="{$child2.item.node_id}">&nbsp;&nbsp;{$child2.item.name|wash()} ({$child2.item.node_id})</option>
                                {if $child2.has_children}
                                    {foreach $child2.children as $child3}
                                        <option value="{$child3.item.node_id}">&nbsp;&nbsp;&nbsp;{$child3.item.name|wash()} ({$child3.item.node_id})</option>
                                    {/foreach}
                                {/if}
                            {/foreach}
                        {/if}
                    {/foreach}
                {/if}
            {/foreach}
            {if $has_custom_topics}
                <optgroup label="{$custom_topic_container.name|wash()}">
                    {foreach $custom_topic_container.main_node.children as $child}
                        <option value="{$child.node_id}">{$child.name|wash()} ({$child.node_id})</option>
                    {/foreach}
                </optgroup>
            {/if}
        </select>
        {undef $topics $topic_list}
        <input id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control" type="text"
               name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]"
               value="{if is_set($attribute.block.custom_attributes[$attribute.identifier])}{$attribute.block.custom_attributes[$attribute.identifier]|wash()}{/if}" />
    </div>
    {if $attribute.help_text}<div class="form-text">{$attribute.help_text|wash()}</div>{/if}
</div>
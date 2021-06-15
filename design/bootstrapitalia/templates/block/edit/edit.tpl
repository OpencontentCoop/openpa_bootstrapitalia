{def $is_dynamic = false()
     $is_custom = false()
     $fetch_params = array()
     $action = cond( is_set( $block.action ), $block.action, false() )}

{if and( eq( ezini( $block.type, 'ManualAddingOfItems', 'block.ini' ), 'disabled' ),
         ezini_hasvariable( $block.type, 'FetchClass', 'block.ini' ) )}
    {set $is_dynamic = true()}
{elseif and( eq( ezini( $block.type, 'ManualAddingOfItems', 'block.ini' ), 'disabled' ),
             ezini_hasvariable( $block.type, 'FetchClass', 'block.ini' )|not )}
    {set $is_custom = true()}
{/if}

{if is_set( $block.fetch_params )}
    {set $fetch_params = unserialize( $block.fetch_params )}
{/if}

<div id="id_{$block.id}" class="block-container mt-2">

<div class="block-header float-break">
    <div class="float-left">
        <em id="block-expand-{$block_id}" class="trigger {if $action|eq( 'add' )}collapse{else}expand{/if}"><i aria-hidden="true" class="fa fa-expand"></i></em>
        {ezini( $block.type, 'Name', 'block.ini' )} {if ne( $block.name, '' )}- {$block.name|wash()}{/if}
    </div>
    <div class="float-right">
        <div class="btn-group" role="group">
            <button id="block-up-{$block_id}" type="submit" class="btn-secondary btn py-1 px-2 btn-xs" name="CustomActionButton[{$attribute.id}_move_block_up-{$zone_id}-{$block_id}]" title="{'Move up'|i18n( 'design/standard/block/edit' )}"><i aria-hidden="true" class="fa fa-arrow-circle-up"></i></button>
            <button id="block-down-{$block_id}" type="submit" class="btn-secondary btn py-1 px-2 btn-xs" name="CustomActionButton[{$attribute.id}_move_block_down-{$zone_id}-{$block_id}]" title="{'Move down'|i18n( 'design/standard/block/edit' )}"><i aria-hidden="true" class="fa fa-arrow-circle-down"></i></button>
            <button id="block-remove-{$block_id}" type="submit" class="btn-secondary btn py-1 px-2 btn-xs" name="CustomActionButton[{$attribute.id}_remove_block-{$zone_id}-{$block_id}]" title="{'Remove'|i18n( 'design/standard/block/edit' )}" onclick="return confirmDiscard( '{'Are you sure you want to remove this block?'|i18n( 'design/standard/block/edit' )}' );"><i aria-hidden="true" class="fa fa-trash"></i></button>
        </div>
    </div>
</div>
<div class="block-content {if $action|eq( 'add' )}expanded{else}collapsed{/if}">

<div class="block-controls float-break">
    <div class="left blockname">
        <label>{'Name:'|i18n( 'design/standard/block/edit' )}</label>
        <input id="block-name-{$block_id}" class="textfield block-control" type="text" name="ContentObjectAttribute_ezpage_block_name_array_{$attribute.id}[{$zone_id}][{$block_id}]" value="{$block.name|wash()}" size="35" />
    </div>
    <div class="right">
    {if $is_custom|not}
        <select id="block-overflow-control-{$block_id}" class="list block-control" name="ContentObjectAttribute_ezpage_block_overflow_{$attribute.id}[{$zone_id}][{$block_id}]">
            <option value="">{'Set overflow'|i18n( 'design/standard/block/edit' )}</option>
            {foreach $zone.blocks as $index => $overflow_block}
                {if eq( $overflow_block.id, $block.id )}
                    {skip}
                {/if}
            <option value="{$overflow_block.id}" {if eq( $overflow_block.id, $block.overflow_id )}selected="selected"{/if}>{$index|inc}. {if is_set( $overflow_block.name )}{$overflow_block.name|wash()}{else}{ezini( $overflow_block.type, 'Name', 'block.ini' )}{/if}</option>
            {/foreach}
        </select>
     {/if}
        <select id="block-view-{$block_id}" class="list block-control" name="ContentObjectAttribute_ezpage_block_view_{$attribute.id}[{$zone_id}][{$block_id}]">
        {def $view_name = ezini( $block.type, 'ViewName', 'block.ini' )}
        {foreach ezini( $block.type, 'ViewList', 'block.ini' ) as $view}
            <option value="{$view}" {if and(is_set($block.view), eq( $block.view, $view ))}selected="selected"{/if}>{$view_name[$view]}</option>
        {/foreach}
        </select>
    </div>
</div>

<div class="block-parameters float-break">
    <div>
    {if $is_dynamic}
        {foreach ezini( $block.type, 'FetchParameters', 'block.ini' ) as $fetch_parameter => $value}
        {if eq( $fetch_parameter, 'Source' )}
        <div class="block-parameter">
            <input id="block-fetch-parameter-choose-source-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" name="CustomActionButton[{$attribute.id}_new_source_browse-{$zone_id}-{$block_id}]" type="submit" value="{'Choose source'|i18n( 'design/standard/block/edit' )}" />
            <div class="source">            
            {if is_set( $fetch_params['Source'] )}
                {if is_array( $fetch_params['Source'] )}
                    {'Current source:'|i18n( 'design/standard/block/edit' )}
                    {foreach $fetch_params['Source'] as $source}
                        {def $source_node = fetch( 'content', 'node', hash( 'node_id', $source ) )}                        
                        <a href={$source_node.url_alias|ezurl} target="_blank" title="{$source_node.name|wash()} [{$source_node.object.content_class.name|wash()}]">{$source_node.name|wash()}</a>{delimiter}, {/delimiter}
                        {undef $source_node}
                    {/foreach}
                {else}
                    {def $source_node = fetch( 'content', 'node', hash( 'node_id', $fetch_params['Source'] ) )}                    
                    {'Current source:'|i18n( 'design/standard/block/edit' )}
                    <a href={$source_node.url_alias|ezurl} target="_blank" title="{$source_node.name|wash()} [{$source_node.object.content_class.name|wash()}]">{$source_node.name|wash()}</a>
                    {undef $source_node}
                {/if}
            {/if}
            </div>
        </div>
        {else}
        <div class="block-parameter">
        <label>{$fetch_parameter}:</label> <input id="block-fetch-parameter-{$fetch_parameter}-{$block_id}" class="textfield block-control" type="text" name="ContentObjectAttribute_ezpage_block_fetch_param_{$attribute.id}[{$zone_id}][{$block_id}][{$fetch_parameter}]" value="{$fetch_params[$fetch_parameter]}" />
        </div>
        {/if}
        {/foreach}
    {/if}
    {if ezini_hasvariable( $block.type, 'CustomAttributes', 'block.ini' )}
        {def $custom_attributes = array()
             $custom_attribute_types = array()
             $custom_attribute_names = array()
             $custom_attribute_selections = array()
             $loop_count = 0}
        {if ezini_hasvariable( $block.type, 'CustomAttributes', 'block.ini' )}
            {set $custom_attributes = ezini( $block.type, 'CustomAttributes', 'block.ini' )}
        {/if}
        {if ezini_hasvariable( $block.type, 'CustomAttributeTypes', 'block.ini' )}
            {set $custom_attribute_types = ezini( $block.type, 'CustomAttributeTypes', 'block.ini' )}
        {/if}
        {if ezini_hasvariable( $block.type, 'CustomAttributeNames', 'block.ini' )}
            {set $custom_attribute_names = ezini( $block.type, 'CustomAttributeNames', 'block.ini' )}
        {/if}
        {foreach $custom_attributes as $custom_attrib}
        <div class="block-parameter">
            {def $use_browse_mode = array()}
            {if ezini_hasvariable( $block.type, 'UseBrowseMode', 'block.ini' )}
                {set $use_browse_mode = ezini( $block.type, 'UseBrowseMode', 'block.ini' )}
            {/if}
            {if and( is_set( $use_browse_mode[$custom_attrib] ), eq( $use_browse_mode[$custom_attrib], 'true' ) )}
                {if is_set($custom_attribute_names[$custom_attrib])}<label>{$custom_attribute_names[$custom_attrib]}:</label>{/if}
                <input id="block-choose-source-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" name="CustomActionButton[{$attribute.id}_custom_attribute_browse-{$zone_id}-{$block_id}-{$custom_attrib}]" type="submit" value="{'Choose source'|i18n( 'design/standard/block/edit' )}" />
                <div class="source">                    
                    {if is_set( $block.custom_attributes[$custom_attrib] )}
                        {def $source_node = fetch( 'content', 'node', hash( 'node_id', $block.custom_attributes[$custom_attrib] ) )}
                        {if $source_node}
                        {'Current source:'|i18n( 'design/standard/block/edit' )}
                            <a href={$source_node.url_alias|ezurl()}>{$source_node.name|wash()}</a>
                        {/if}
                        {undef $source_node}
                    {/if}
                </div>
            {else}
                {if is_set( $custom_attribute_types[$custom_attrib] )}
                    {switch match = $custom_attribute_types[$custom_attrib]}
                        {case match = 'text'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            <textarea id="block-custom_attribute-{$block_id}-{$loop_count}" class="textbox block-control" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" rows="7">{$block.custom_attributes[$custom_attrib]|wash()}</textarea>
                        {/case}
                        {case match = 'checkbox'}
                        <input id="block-custom_attribute-{$block_id}-{$loop_count}-a" class="block-control" type="hidden" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="0" />
                            <label>
                                <input id="block-custom_attribute-{$block_id}-{$loop_count}-b" class="block-control" type="checkbox" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]"{if and(is_set($block.custom_attributes[$custom_attrib]), eq( $block.custom_attributes[$custom_attrib], '1'))} checked="checked"{/if} value="1" />
                                {if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}
                            </label>
                        {/case}
                        {case match = 'string'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control w-50" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{$block.custom_attributes[$custom_attrib]|wash()}" />
                        {/case}
                        {case match = 'select'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            {set $custom_attribute_selections = ezini( $block.type, concat( 'CustomAttributeSelection_', $custom_attrib ), 'block.ini' )}
                            <select id="block-custom_attribute-{$block_id}-{$loop_count}" class="list block-control" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]">
                                {foreach $custom_attribute_selections as $selection_value => $selection_name}
                                    <option value="{$selection_value|wash()}"{if eq( $block.custom_attributes[$custom_attrib], $selection_value )} selected="selected"{/if}>{$selection_name|wash()}</option>
                                {/foreach}
                            </select>
                        {/case}
                        {case match = 'class_select'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            {def $class_list = fetch( class, list, hash( sort_by, array( 'name', true() ) ) )}
                              <select id="block-custom_attribute-{$block_id}-{$loop_count}" class="list block-control select_to_string" onchange="select_to_string(this)">
                                  <option></option>
                                  {foreach $class_list as $class}
                                    <option value="{$class.identifier}">{$class.name|wash()}</option>
                                  {/foreach}
                              </select>
                              {undef $class_list}
                              <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{$block.custom_attributes[$custom_attrib]|wash()}" />
                        {/case}
                        {case match = 'state_select'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            {def $state_list = object_state_list()}
                            <select id="block-custom_attribute-{$block_id}-{$loop_count}" class="list block-control select_to_string" onchange="select_to_string(this)">
                                <option></option>
                                {foreach $state_list as $id => $name}
                                    <option value="{$id}">{$name|wash()} ({$id})</option>
                                {/foreach}
                            </select>
                            {undef $state_list}
                            <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{$block.custom_attributes[$custom_attrib]|wash()}" />
                        {/case}
                        {case match = 'topic_select'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            {def $topics = fetch(content, object, hash(remote_id, 'topics'))
                                 $topic_list = cond($topics, tree_menu( hash( 'root_node_id', $topics.main_node_id, 'user_hash', false(), 'scope', 'side_menu')), array())
                                 $custom_topic_container = fetch(content, object, hash(remote_id, 'custom_topics'))
                                 $has_custom_topics = cond(and($custom_topic_container, $custom_topic_container.main_node.children_count))}
                            <select id="block-custom_attribute-{$block_id}-{$loop_count}" class="list block-control select_to_string" onchange="select_to_string(this)">
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
                            <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{if is_set($block.custom_attributes[$custom_attrib])}{$block.custom_attributes[$custom_attrib]|wash()}{/if}" />
                        {/case}
                        {case match = 'tag_tree_select'}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            <div>
                                <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control w-50" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{$block.custom_attributes[$custom_attrib]|wash()}" />
                                <a href="#" data-index="{$loop_count}" onclick="tag_tree_select(this);return false;"><i class="fa fa-plus-square-o"></i></a>
                            </div>
                        {/case}
                        {case}
                            <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                            <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control w-50" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{$block.custom_attributes[$custom_attrib]|wash()}" />
                        {/case}
                    {/switch}
                {else}
                    <label for="block-custom_attribute-{$block_id}-{$loop_count}">{if is_set( $custom_attribute_names[$custom_attrib] )}{$custom_attribute_names[$custom_attrib]}{else}{$custom_attrib}{/if}:</label>
                    <input id="block-custom_attribute-{$block_id}-{$loop_count}" class="textfield block-control w-50" type="text" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][{$custom_attrib}]" value="{$block.custom_attributes[$custom_attrib]|wash()}" />
                {/if}
            {/if}
            {undef $use_browse_mode}
            {set $loop_count=inc( $loop_count )}
        </div>
        {/foreach}
        {undef $loop_count}
    {/if}
    </div>
    {if and( not( $is_dynamic ), not( $is_custom ) )}
        <div class="block-parameter">
            <input id="block-add-item-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" name="CustomActionButton[{$attribute.id}_new_item_browse-{$zone_id}-{$block_id}]" type="submit" value="{'Add item'|i18n( 'design/standard/block/edit' )}" />
        </div>
    {/if}
</div>



{if $is_custom|not}
<table border="0" cellspacing="1" class="items queue" id="z:{$zone_id}_b:{$block_id}_q">
    <tbody>
    {if $block.waiting|count()}
    {foreach $block.waiting as $index => $item sequence array( 'bglight', 'bgdark') as $style}
    {def $item_object = fetch( 'content', 'object', hash( 'object_id', $item.object_id ) )}
    <tr id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}" class="{if $item.ts_publication|lt($current_time)}tbp{/if}">
        <td class="tight"><input type="checkbox" value="{$item.object_id}" name="DeleteItemIDArray[]" /></td>
        <td id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}_h" class="handler">{$item_object.name|wash()}</td>
            <td class="time">
                {if $block.rotation.interval}
                      <span>{'Rotating item.'|i18n( 'design/standard/block/edit' )}</span>
                      {def $number_of_valid_setting = ezini( $block.type, 'NumberOfValidItems', 'block.ini' )
                           $last_valid_time = $block.last_valid_item.ts_visible
                           $interval_time = $block.rotation.interval
                           $time_left_latest = $last_valid_time|sub( $current_time )|sum( $interval_time )
                           $position_left = $block.waiting|count()|sub( $index )|sub('1')
                           $time_left = sum( $position_left|div( $number_of_valid_setting )|floor|mul( $interval_time ),$time_left_latest )
                      }
                      {if $time_left|gt( '0' )}
                       <span class="rotation-time-left">
                             {def $days = $time_left|div( '86400' )|floor()
                                  $hours = $time_left|mod( '86400' )|div( '3600' )|floor()
                                  $minutes = $time_left|mod( '86400' )|mod( '3600' )|div( '60' )|floor()
                                  $seconds = $time_left|mod( '86400' )|mod( '3600' )|mod( '60' )|round()
                             }
                             
                             {if $days|gt( '0' )}
                                 {$days} {'d'|i18n( 'design/standard/block/edit' )}
                             {/if}
                                 
                             {if $hours|gt( '0' )}
                                 {$hours} {'h'|i18n( 'design/standard/block/edit' )}
                             {/if}
                                 
                             {if $minutes|gt( '0' )}
                                 {$minutes} {'m'|i18n( 'design/standard/block/edit' )}
                             {/if}
                                 
                             {if $seconds|gt( '0' )}
                                 {$seconds} {'s'|i18n( 'design/standard/block/edit' )} {'left'|i18n( 'design/standard/block/edit' )}
                             {/if}
                       </span>
                      {/if}
                      {undef $time_left}
                {else}
                    <span class="ts-publication">{$item.ts_publication|l10n( 'shortdatetime' )}</span>
                        {if $item.ts_publication|lt( $current_time )|not()}
                            (
                            {def $time_diff = $item.ts_publication|sub( $current_time )
                                 $days = $time_diff|div( '86400' )|floor()
                                 $hours = $time_diff|mod( '86400' )|div( '3600' )|floor()
                                 $minutes = $time_diff|mod( '86400' )|mod( '3600' )|div( '60' )|floor()
                                 $seconds = $time_diff|mod( '86400' )|mod( '3600' )|mod( '60' )|round()}
                                 
                             {if $days|gt( '0' )}
                                 {$days} {'d'|i18n( 'design/standard/block/edit' )}
                             {/if}
                                 
                             {if $hours|gt( '0' )}
                                 {$hours} {'h'|i18n( 'design/standard/block/edit' )}
                             {/if}
                                 
                             {if $minutes|gt( '0' )}
                                 {$minutes} {'m'|i18n( 'design/standard/block/edit' )}
                             {/if}
                                 
                             {if $seconds|gt( '0' )}
                                 {$seconds} {'s'|i18n( 'design/standard/block/edit' )} {'left'|i18n( 'design/standard/block/edit' )}
                             {/if}
                            )
                          {/if}
                    <input class="block-control" type="hidden" name="ContentObjectAttribute_ezpage_item_ts_published_value_{$attribute.id}[{$zone_id}][{$block_id}][{$item.object_id}]" value="{$item.ts_publication}" />
                    <img class="schedule-handler" src="{'ezpage/clock_ico.gif'|ezimage(no)}" alt="{concat( 'Publishing schedule for: '|i18n( 'design/standard/block/edit' ), $item_object.name|wash() )|shorten( '50' )}" title="{concat( 'Publishing schedule for: '|i18n( 'design/standard/block/edit' ), $item_object.name|wash() )|shorten( '50' )}" />
                {/if}
            </td>
    </tr>
    {undef $item_object}
    {/foreach}
    {else}
     <tr class="empty">
         <td colspan="3">{'Queue: no items.'|i18n( 'design/standard/block/edit' )}</td>
     </tr>
     {/if}
     </tbody>
</table>
<table border="0" cellspacing="1" class="items online" id="z:{$zone_id}_b:{$block_id}_o">
    <tbody>
    {if $block.valid|count()}
    {foreach $block.valid as $item sequence array( 'bglight', 'bgdark') as $style}
    <tr id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}">
        <td class="tight"><input type="checkbox" value="{$item.object_id}" name="DeleteItemIDArray[]" /></td>
        <td id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}_h" colspan="2" class="handler">{fetch( 'content', 'object', hash( 'object_id', $item.object_id ) ).name|wash()}</td>
    </tr>
    {/foreach}
    {else}
    <tr class="empty">
        <td colspan="3">{'Online: no items.'|i18n( 'design/standard/block/edit' )}</td>
    </tr>
    {/if}
    <tr class="rotation">
        <td colspan="3">{'Rotation:'|i18n( 'design/standard/block/edit' )} <input id="block-rotation-value-{$block_id}" class="textfield block-control" type="text" name="RotationValue_{$block_id}" value="{if is_set( $block.rotation )}{$block.rotation.value}{/if}" size="5" />
            <select id="block-rotation-unit-{$block_id}" class="list block-control" name="RotationUnit_{$block_id}">
                <option value="2" {if and( is_set( $block.rotation ), eq( $block.rotation.unit, 2 ) )}selected="selected"{/if}>{'min'|i18n( 'design/standard/block/edit' )}</option>
                <option value="3" {if and( is_set( $block.rotation ), eq( $block.rotation.unit, 3 ) )}selected="selected"{/if}>{'hour'|i18n( 'design/standard/block/edit' )}</option>
                <option value="4" {if and( is_set( $block.rotation ), eq( $block.rotation.unit, 4 ) )}selected="selected"{/if}>{'day'|i18n( 'design/standard/block/edit' )}</option>
            </select>

        {'Shuffle'|i18n( 'design/standard/block/edit' )} <input id="block-rotation-shuffle-{$block_id}" class="block-control" type="checkbox" {if and( is_set( $block.rotation ), eq( $block.rotation.type, 2 ) )}checked="checked"{/if} name="RotationShuffle_{$block_id}" /> <input id="block-set-rotation-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" type="submit" name="CustomActionButton[{$attribute.id}_set_rotation-{$zone_id}-{$block_id}]" value="{'Set'|i18n( 'design/standard/block/edit' )}" /></td>
    </tr>
</table>
<table border="0" cellspacing="1" class="items history" id="z:{$zone_id}_b:{$block_id}_h">
    {if $block.archived|count()}
    {foreach $block.archived as $item sequence array( 'bglight', 'bgdark') as $style}
    <tr>
        <td class="tight"><input type="checkbox" value="{$item.object_id}" name="DeleteItemIDArray[]" /></td>
        <td>{fetch( 'content', 'object', hash( 'object_id', $item.object_id ) ).name|wash()}</td>
        <td class="status">
            {if ne( $item.moved_to , '' )}
                {'Moved to:'|i18n( 'design/standard/block/edit' )}

                {foreach $zone.blocks as $index => $dest_block}
                {if eq( $dest_block.id, $item.moved_to )}
                    {if ne( $dest_block.name, '' )}
                        {$dest_block.name|wash()}
                    {else}
                        {ezini( $dest_block.type, 'Name', 'block.ini' )}
                    {/if}
                {/if}
                {/foreach}
            {else}
                {'Not visible'|i18n( 'design/standard/block/edit' )}
            {/if}
        </td>
    </tr>
    {/foreach}
    {else}
    <tr class="empty">
        <td colspan="3">{'History: no items.'|i18n( 'design/standard/block/edit' )}</td>
    </tr>
    {/if}
    </tbody>
</table>

<div class="block-controls float-break">
    <div class="left">
        <input id="block-remove-selected-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" type="submit" name="CustomActionButton[{$attribute.id}_remove_item-{$zone_id}-{$block_id}]" value="{'Remove selected'|i18n( 'design/standard/block/edit' )}" />
    </div>
    <div class="right legend">
        <div class="queue">&nbsp;</div> {'Queue:'|i18n( 'design/standard/block/edit' )} {$block.waiting|count()} <div class="online">&nbsp;</div> {'Online:'|i18n( 'design/standard/block/edit' )} {$block.valid|count()} <div class="history">&nbsp;</div> {'History:'|i18n( 'design/standard/block/edit' )} {$block.archived|count()}
    </div>
</div>
{/if}


{def $use_styles = openpaini( 'Stili', 'UsaNeiBlocchi', 'disabled' )|eq('enabled')}
{if $use_styles}
    <div class="block-parameters float-break">
        <div class="block-parameter">
        <label>Sfondo</label>
        <input type="radio" title="Nessuno" id="block-custom_attribute-{$block_id}-19771205" class="block-control" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][color_style]" {if is_set($block.custom_attributes[color_style])|not()}checked="checked"{/if} value="" />
        <div style="vertical-align: middle; margin-right: 5px; width: 15px; height: 15px; display: inline-block; border: 1px solid #ccc; background: #fff"></div>
        {def $node_styles = openpaini('Stili', 'Nodo_NomeStile')
             $styles = array()}
        {foreach $node_styles as $node_style}
            {def $style_parts = $node_style|explode(';')}
            {if $styles|contains($style_parts[1])|not()}
                {set $styles = $styles|append( $style_parts[1] )}
            {/if}
            {undef $style_parts}
        {/foreach}
        {foreach $styles as $style}
            <input type="radio" title="{$style}" id="block-custom_attribute-{$block_id}-19771205" class="block-control" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][color_style]" {if and(  is_set($block.custom_attributes[color_style]), $block.custom_attributes[color_style]|eq($style) )}checked="checked"{/if} value="{$style}" />
            <div class="block-color-select {$style}" style="padding:0 !important;vertical-align: middle; margin-right: 5px; width: 15px; height: 15px; display: inline-block; border: 1px solid #ccc"><span style="visibility: hidden">{$style}</span></div>
        {/foreach}
        </div>
    </div>
{/if}

<div class="block-parameters float-break">
    <div class="block-parameter">
        <label>Impostazioni di layout</label>
        <label for="block-custom_attribute-{$block_id}-20171205-0">
            <input type="radio" id="block-custom_attribute-{$block_id}-20171205-0" class="block-control" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][container_style]" {if or(is_set($block.custom_attributes[container_style])|not(), $block.custom_attributes[container_style]|eq(''))}checked="checked"{/if} value="" /> Default
        </label>
        <label for="block-custom_attribute-{$block_id}-20171205-1">
            <input type="radio" id="block-custom_attribute-{$block_id}-20171205-1" class="block-control" name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][container_style]" {if and(is_set($block.custom_attributes[container_style]), $block.custom_attributes[container_style]|eq('overlay'))}checked="checked"{/if} value="overlay" /> Sovrapposto al blocco precedente
        </label>        
    </div>
</div>

{if and(ezini_hasvariable($block.type, 'CanAddShowAllLink', 'block.ini'), ezini($block.type, 'CanAddShowAllLink', 'block.ini')|eq('enabled') )}
    <div class="block-parameters float-break">
        <div class="block-parameter">
            <label>Link all'origine</label>
            <label for="block-custom_attribute-{$block_id}-19791023-0">
                <input type="radio" id="block-custom_attribute-{$block_id}-19791023-0"
                       class="block-control"
                       name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][show_all_link]"
                       {if or(is_set($block.custom_attributes[show_all_link])|not(), $block.custom_attributes[show_all_link]|eq(''))}checked="checked"{/if} value="" /> Nascondi bottone
            </label>
            <label for="block-custom_attribute-{$block_id}-19791023-1">
                <input type="radio" id="block-custom_attribute-{$block_id}-19791023-1"
                       class="block-control"
                       name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][show_all_link]"
                       {if and(is_set($block.custom_attributes[show_all_link]), $block.custom_attributes[show_all_link]|eq('1'))}checked="checked"{/if} value="1" /> Mostra bottone
            </label>
            <label for="block-custom_attribute-{$block_id}-19791023-2">
                Testo del bottone "{'View all'|i18n('bootstrapitalia')}"
            </label>
            <input type="text" id="block-custom_attribute-{$block_id}-19791023-2" class="block-control w-50"
                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][show_all_text]"
                   value="{if is_set($block.custom_attributes[show_all_text])}{$block.custom_attributes[show_all_text]|wash()}{/if}" />
        </div>
    </div>
{/if}

{if and(ezini_hasvariable($block.type, 'CanAddIntroText', 'block.ini'), ezini($block.type, 'CanAddIntroText', 'block.ini')|eq('enabled') )}
    <div class="block-parameters float-break">
        <div class="block-parameter">
            <label>Testo introduttivo</label>
            <label for="block-custom_attribute-{$block_id}-20160702-0">
                <textarea id="block-custom_attribute-{$block_id}-20160702-0"
                          class="textbox block-control"
                          name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][intro_text]"
                          rows="3">{if is_set($block.custom_attributes[intro_text])}{$block.custom_attributes[intro_text]|wash()}{/if}</textarea>
            </label>
        </div>
    </div>
{/if}
</div>
</div>

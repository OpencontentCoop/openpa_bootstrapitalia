{if and( not( $is_dynamic ), not( $is_custom ) )}
    <div class="block-parameter my-3">
        <input id="block-add-item-{$block_id}"
               class="btn-secondary btn py-1 px-2 btn-xs block-control"
               name="CustomActionButton[{$attribute.id}_new_item_browse-{$zone_id}-{$block_id}]"
               type="submit"
               data-browsersubtree="2"
               data-browserselectiontype="{if $number_of_items}{cond($number_of_items|gt(1), 'multiple', 'single')}{else}single{/if}"
               value="{'Add item'|i18n( 'design/standard/block/edit' )}{if $number_of_items} (max {$number_of_items}){/if}" />
    </div>
{/if}

{if $is_custom|not}
    <table class="my-3 table table-sm table-borderless table-success items queue" id="z:{$zone_id}_b:{$block_id}_q">
        <tbody>
        {if $block.waiting|count()}
            {foreach $block.waiting as $index => $item sequence array( 'bglight', 'bgdark') as $style}
                {def $item_object = fetch( 'content', 'object', hash( 'object_id', $item.object_id ) )}
                <tr id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}" class="{if $item.ts_publication|lt($current_time)}tbp{/if}">
                    <td class="tight">
                        <input type="checkbox" value="{$item.object_id}" name="DeleteItemIDArray[]" />
                    </td>
                    <td id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}_h"><i class="fa fa-clock-o"></i> {$item_object.name|wash()}</td>
                    <td class="time d-none">
                        {if and(is_set($block.rotation), $block.rotation.interval)}
                            <small>{'Rotating item.'|i18n( 'design/standard/block/edit' )}</small>
                            {def $number_of_valid_setting = ezini( $block.type, 'NumberOfValidItems', 'block.ini' )
                                 $last_valid_time = $block.last_valid_item.ts_visible
                                 $interval_time = $block.rotation.interval
                                 $time_left_latest = $last_valid_time|sub( $current_time )|sum( $interval_time )
                                 $position_left = $block.waiting|count()|sub( $index )|sub('1')
                                 $time_left = sum( $position_left|div( $number_of_valid_setting )|floor|mul( $interval_time ),$time_left_latest )}
                            {if $time_left|gt( '0' )}
                                <small class="rotation-time-left">
                                     {def $days = $time_left|div( '86400' )|floor()
                                          $hours = $time_left|mod( '86400' )|div( '3600' )|floor()
                                          $minutes = $time_left|mod( '86400' )|mod( '3600' )|div( '60' )|floor()
                                          $seconds = $time_left|mod( '86400' )|mod( '3600' )|mod( '60' )|round()}
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
                               </small>
                            {/if}
                            {undef $time_left}
                        {else}
                            <small class="ts-publication">{$item.ts_publication|l10n( 'shortdatetime' )}</small>
                            {if $item.ts_publication|lt( $current_time )|not()}
                                ({*
                                *}{def $time_diff = $item.ts_publication|sub( $current_time )
                                     $days = $time_diff|div( '86400' )|floor()
                                     $hours = $time_diff|mod( '86400' )|div( '3600' )|floor()
                                     $minutes = $time_diff|mod( '86400' )|mod( '3600' )|div( '60' )|floor()
                                     $seconds = $time_diff|mod( '86400' )|mod( '3600' )|mod( '60' )|round()}{*
                                *}{if $days|gt( '0' )}
                                    {$days} {'d'|i18n( 'design/standard/block/edit' )}
                                {/if}{*
                                *}{if $hours|gt( '0' )}
                                    {$hours} {'h'|i18n( 'design/standard/block/edit' )}
                                {/if}{*
                                *}{if $minutes|gt( '0' )}
                                    {$minutes} {'m'|i18n( 'design/standard/block/edit' )}
                                {/if}{*
                                *}{if $seconds|gt( '0' )}
                                    {$seconds} {'s'|i18n( 'design/standard/block/edit' )} {'left'|i18n( 'design/standard/block/edit' )}
                                {/if}{*
                                *})
                            {/if}
                            <input class="block-control" type="hidden"
                                   name="ContentObjectAttribute_ezpage_item_ts_published_value_{$attribute.id}[{$zone_id}][{$block_id}][{$item.object_id}]"
                                   value="{$item.ts_publication}" />
                            <img class="schedule-handler" src="{'ezpage/clock_ico.gif'|ezimage(no)}"
                                 alt="{concat( 'Publishing schedule for: '|i18n( 'design/standard/block/edit' ), $item_object.name|wash() )|shorten( '50' )}"
                                 title="{concat( 'Publishing schedule for: '|i18n( 'design/standard/block/edit' ), $item_object.name|wash() )|shorten( '50' )}" />
                        {/if}
                    </td>
                </tr>
                {undef $item_object}
            {/foreach}
        {/if}
        </tbody>
    </table>
    <table class="table table-sm table-borderless items online table-success" id="z:{$zone_id}_b:{$block_id}_o">
        <tbody>
        {if $block.valid|count()}
            {foreach $block.valid as $item sequence array( 'bglight', 'bgdark') as $style}
                <tr id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}" class="table-success">
                    <td class="tight"><input type="checkbox" value="{$item.object_id}" name="DeleteItemIDArray[]" /></td>
                    <td id="z:{$zone_id}_b:{$block_id}_i:{$item.object_id}_h" colspan="2" class="handler" style="cursor:grab">{fetch( 'content', 'object', hash( 'object_id', $item.object_id ) ).name|wash()}</td>
                </tr>
            {/foreach}
        {else}
            <tr class="empty text-center">
                <td colspan="3">{'Online: no items.'|i18n( 'design/standard/block/edit' )}</td>
            </tr>
        {/if}
        <tr class="rotation text-center d-none">
            <td colspan="3">{'Rotation:'|i18n( 'design/standard/block/edit' )} <input id="block-rotation-value-{$block_id}" class="textfield block-control" type="text" name="RotationValue_{$block_id}" value="{if is_set( $block.rotation )}{$block.rotation.value}{/if}" size="5" />
                <select id="block-rotation-unit-{$block_id}" class="list block-control" name="RotationUnit_{$block_id}">
                    <option value="2" {if and( is_set( $block.rotation ), eq( $block.rotation.unit, 2 ) )}selected="selected"{/if}>{'min'|i18n( 'design/standard/block/edit' )}</option>
                    <option value="3" {if and( is_set( $block.rotation ), eq( $block.rotation.unit, 3 ) )}selected="selected"{/if}>{'hour'|i18n( 'design/standard/block/edit' )}</option>
                    <option value="4" {if and( is_set( $block.rotation ), eq( $block.rotation.unit, 4 ) )}selected="selected"{/if}>{'day'|i18n( 'design/standard/block/edit' )}</option>
                </select>
                {'Shuffle'|i18n( 'design/standard/block/edit' )} <input id="block-rotation-shuffle-{$block_id}" class="block-control" type="checkbox" {if and( is_set( $block.rotation ), eq( $block.rotation.type, 2 ) )}checked="checked"{/if} name="RotationShuffle_{$block_id}" /> <input id="block-set-rotation-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" type="submit" name="CustomActionButton[{$attribute.id}_set_rotation-{$zone_id}-{$block_id}]" value="{'Set'|i18n( 'design/standard/block/edit' )}" /></td>
        </tr>
    </table>
    <table class="table table-sm table-borderless items history table-light d-none" id="z:{$zone_id}_b:{$block_id}_h">
        <tbody>
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
            <tr class="empty text-center">
                <td colspan="3">{'History: no items.'|i18n( 'design/standard/block/edit' )}</td>
            </tr>
        {/if}
        </tbody>
    </table>

    <div class="block-controls float-break">
        <div class="left">
            <input id="block-remove-selected-{$block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control" type="submit" name="CustomActionButton[{$attribute.id}_remove_item-{$zone_id}-{$block_id}]" value="{'Remove selected'|i18n( 'design/standard/block/edit' )}" />
        </div>
    </div>
{/if}
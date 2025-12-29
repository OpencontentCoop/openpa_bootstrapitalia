<div class="row my-3">
    <div class="col-md-6">
        <div class="input-group">
            <select name="ContentObjectAttribute_ezpage_block_type_{$attribute.id}_{$zone_id}" class="custom-select" style="min-width:110px">
                {foreach ezini( 'General', 'AllowedTypes', 'block.ini' ) as $type}
                    <option value="{$type}">{ezini( $type, 'Name', 'block.ini' )}</option>
                {/foreach}
            </select>
            <div class="input-group-append">
                <input class="btn btn-xs btn-info" type="submit"
                       name="CustomActionButton[{$attribute.id}_new_block-{$zone_id}]"
                       value="{'Add block'|i18n( 'design/standard/datatype/ezpage' )}"/>
            </div>
        </div>
    </div>
    <div class="col-md-6 text-md-end">
        <button class="trigger expand-all btn btn-xs btn-outline-info border p-2"
                title="{'Expand All'|i18n( 'design/standard/datatype/ezpage' )}">{'Expand All'|i18n( 'design/standard/datatype/ezpage' )}</button>
        <button class="trigger collapse-all btn btn-xs btn-outline-info border p-2"
                title="{'Collapse All'|i18n( 'design/standard/datatype/ezpage' )}">{'Collapse All'|i18n( 'design/standard/datatype/ezpage' )}</button>
    </div>
</div>

<div id="zone-{$zone_id}-blocks">
    {foreach $zone.blocks as $index => $block}
        {update_zone_block_in_db_if_needed($attribute.object.main_node_id, $zone.id, $block)}
        {if or( is_set($block.action)|not(), and(is_set($block.action), ne( $block.action, 'remove' )))}
            {block_edit_gui block=$block block_id=$index current_time=currentdate() zone_id=$zone_id attribute=$attribute zone=$zone}
        {/if}
    {/foreach}
</div>

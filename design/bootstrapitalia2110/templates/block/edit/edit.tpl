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

{def $number_of_items = false()}
{if ezini_hasvariable( $block.type, 'NumberOfValidItems', 'block.ini' )}
    {set $number_of_items = ezini( $block.type, 'NumberOfValidItems', 'block.ini' )}
{/if}

{if is_set( $block.fetch_params )}
    {set $fetch_params = unserialize( $block.fetch_params )}
{/if}

<div id="id_{$block.id}" class="block-container my-3 card border-bottom p-3 no-after">

    <div class="row">
        <div class="col-8 col-lg-9">
            <h3 class="card-title h6 d-block mb-0">
                <span class="badge border text-black border-black me-2">{ezini( $block.type, 'Name', 'block.ini' )}</span>{if ne( $block.name, '' )} {$block.name|wash()} {/if}
            </h3>
        </div>
        <div class="col-4 col-lg-3 text-end">
            <button id="block-remove-{$block_id}" type="submit" class="btn-danger btn py-1 px-2 btn-xs" name="CustomActionButton[{$attribute.id}_remove_block-{$zone_id}-{$block_id}]" title="{'Remove'|i18n( 'design/standard/block/edit' )}" data-confirm="{'Are you sure you want to remove this block?'|i18n( 'design/standard/block/edit' )}"><i aria-hidden="true" class="fa fa-trash"></i></button>
            <button id="block-up-{$block_id}" type="submit" class="ms-3 btn-secondary btn py-1 px-2 btn-xs" name="CustomActionButton[{$attribute.id}_move_block_up-{$zone_id}-{$block_id}]" title="{'Move up'|i18n( 'design/standard/block/edit' )}"><i aria-hidden="true" class="fa fa-arrow-circle-up"></i></button>
            <button id="block-down-{$block_id}" type="submit" class="btn-secondary btn py-1 px-2 btn-xs" name="CustomActionButton[{$attribute.id}_move_block_down-{$zone_id}-{$block_id}]" title="{'Move down'|i18n( 'design/standard/block/edit' )}"><i aria-hidden="true" class="fa fa-arrow-circle-down"></i></button>
            <em id="block-expand-{$block_id}" class="ms-3 trigger {if $action|eq( 'add' )}collapse{else}expand{/if}" style="cursor:pointer">
                <i aria-hidden="true" class="fa fa-expand"></i>
                <i aria-hidden="true" class="fa fa-compress"></i>
            </em>
        </div>
    </div>

    <div class="block-content {if $action|eq( 'add' )}expanded{else}collapsed{/if}">
        <div class="row">
            <div class="col-md-6">
                {* Name *}
                <div class="row my-3">
                    <label for="block-name-{$block_id}" class="col-12 col-form-label font-weight-bold">{'Name:'|i18n( 'design/standard/block/edit' )}</label>
                    <div class="col-12">
                        <input type="text" name="ContentObjectAttribute_ezpage_block_name_array_{$attribute.id}[{$zone_id}][{$block_id}]" class="form-control w-100" id="block-name-{$block_id}" value="{$block.name|wash()}">
                    </div>
                </div>

                {* Overflow (hidden) *}
                {if $is_custom|not}
                <div class="d-none">
                    <label for="block-overflow-control-{$block_id}" class="col-12 col-form-label font-weight-bold">{'Set overflow'|i18n( 'design/standard/block/edit' )}</label>
                    <select id="block-overflow-control-{$block_id}" class="form-control w-100" name="ContentObjectAttribute_ezpage_block_overflow_{$attribute.id}[{$zone_id}][{$block_id}]">
                        <option value="">{'Set overflow'|i18n( 'design/standard/block/edit' )}</option>
                        {foreach $zone.blocks as $index => $overflow_block}
                            {if eq( $overflow_block.id, $block.id )}
                                {skip}
                            {/if}
                            <option value="{$overflow_block.id}" {if eq( $overflow_block.id, $block.overflow_id )}selected="selected"{/if}>{$index|inc}. {if is_set( $overflow_block.name )}{$overflow_block.name|wash()}{else}{ezini( $overflow_block.type, 'Name', 'block.ini' )}{/if}</option>
                        {/foreach}
                    </select>
                </div>
                {/if}

                {* View *}
                <div class="row my-3">
                    <label for="block-view-{$block_id}" class="col-12 col-form-label font-weight-bold">{'Block type:'|i18n( 'design/standard/block/edit' )}</label>
                    <div class="col-12">
                        <select id="block-view-{$block_id}" class="form-control w-100" name="ContentObjectAttribute_ezpage_block_view_{$attribute.id}[{$zone_id}][{$block_id}]">
                            {def $view_name = ezini( $block.type, 'ViewName', 'block.ini' )}
                            {foreach ezini( $block.type, 'ViewList', 'block.ini' ) as $view}
                                <option value="{$view}" {if and(is_set($block.view), eq( $block.view, $view ))}selected="selected"{/if}>{$view_name[$view]}</option>
                            {/foreach}
                        </select>
                    </div>
                </div>

                {* Intro *}
                {if and(ezini_hasvariable($block.type, 'CanAddIntroText', 'block.ini'), ezini($block.type, 'CanAddIntroText', 'block.ini')|eq('enabled') )}
                    <div class="row my-3">
                        <label for="block-custom_attribute-{$block_id}-20160702-0" class="col-12 col-form-label font-weight-bold">{'Intro:'|i18n( 'design/standard/block/edit' )}</label>
                        <div class="col-12">
                            <textarea id="block-custom_attribute-{$block_id}-20160702-0"
                                      class="form-control w-100"
                                      name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][intro_text]"
                                      rows="10">{if is_set($block.custom_attributes[intro_text])}{$block.custom_attributes[intro_text]|wash()}{/if}</textarea>
                        </div>
                    </div>
                {/if}

                {* Styles *}
                {if openpaini( 'Stili', 'UsaNeiBlocchi', 'disabled' )|eq('enabled')}
                    <div class="row my-3">
                        <label class="col-12 col-form-label font-weight-bold">{'Background:'|i18n( 'design/standard/block/edit' )}</label>
                        <div class="col-12">
                            <input type="radio" title="Nessuno"
                                   id="block-custom_attribute-{$block_id}-19771205"
                                   class="block-control"
                                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][color_style]"
                                   {if is_set($block.custom_attributes[color_style])|not()}checked="checked"{/if}
                                   value="" />
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
                                <input type="radio" title="{$style}" id="block-custom_attribute-{$block_id}-19771205"
                                       class="block-control"
                                       name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][color_style]"
                                       {if and(  is_set($block.custom_attributes[color_style]), $block.custom_attributes[color_style]|eq($style) )}checked="checked"{/if}
                                       value="{$style}" />
                                <div class="block-color-select {$style}" style="padding:0 !important;vertical-align: middle; margin-right: 5px; width: 15px; height: 15px; display: inline-block; border: 1px solid #ccc"><span style="visibility: hidden">{$style}</span></div>
                            {/foreach}
                        </div>
                    </div>
                {/if}

                {* Layout *}
                <div class="row my-3">
                    <label class="col-12 col-form-label font-weight-bold">{'Disposizione:'|i18n( 'design/standard/block/edit' )}</label>
                    <div class="col-12">
                        <div class="form-check">
                            <input type="radio"
                                   id="block-custom_attribute-{$block_id}-20171205-0"
                                   class="form-check-input"
                                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][container_style]"
                                   {if or(is_set($block.custom_attributes[container_style])|not(), $block.custom_attributes[container_style]|eq(''))}checked="checked"{/if}
                                   value="" />
                            <label class="form-check-label" for="block-custom_attribute-{$block_id}-20171205-0" style="font-size:1em">
                                Default
                            </label>
                        </div>
                        <div class="form-check">
                            <input type="radio"
                                   id="block-custom_attribute-{$block_id}-20171205-1"
                                   class="form-check-input"
                                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][container_style]"
                                   {if and(is_set($block.custom_attributes[container_style]), $block.custom_attributes[container_style]|eq('overlay'))}checked="checked"{/if}
                                   value="overlay" />
                            <label class="form-check-label" for="block-custom_attribute-{$block_id}-20171205-1" style="font-size:1em">
                                Sovrapposto al blocco precedente
                            </label>
                        </div>
                    </div>
                </div>

                {* View all *}
                {if and(ezini_hasvariable($block.type, 'CanAddShowAllLink', 'block.ini'), ezini($block.type, 'CanAddShowAllLink', 'block.ini')|eq('enabled') )}
                <div class="row my-3">
                    <label class="col-12 col-form-label font-weight-bold">{'Link a "Vedi tuti":'|i18n( 'design/standard/block/edit' )}</label>
                    <div class="col-12">
                        <div class="form-check">
                            <input class="form-check-input" type="radio"
                                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][show_all_link]"
                                   {if or(is_set($block.custom_attributes[show_all_link])|not(), $block.custom_attributes[show_all_link]|eq(''))}checked="checked"{/if}
                                   value=""
                                   id="block-custom_attribute-{$block_id}-19791023-0">
                            <label class="form-check-label" for="block-custom_attribute-{$block_id}-19791023-0" style="font-size:1em">
                                Nascondi bottone
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio"
                                   name="flexRadioDefault"
                                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][show_all_link]"
                                   {if and(is_set($block.custom_attributes[show_all_link]), $block.custom_attributes[show_all_link]|eq('1'))}checked="checked"{/if} value="1"
                                   id="block-custom_attribute-{$block_id}-19791023-1">
                            <label class="form-check-label" for="block-custom_attribute-{$block_id}-19791023-1" style="font-size:1em">
                                Mostra bottone
                            </label>
                        </div>
                        <div class="">
                            <label class="form-label" for="block-custom_attribute-{$block_id}-19791023-2">
                                Testo del bottone "{'View all'|i18n('bootstrapitalia')}"
                            </label>
                            <input type="text" id="block-custom_attribute-{$block_id}-19791023-2" class="form-control w-100"
                                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.id}[{$zone_id}][{$block_id}][show_all_text]"
                                   value="{if is_set($block.custom_attributes[show_all_text])}{$block.custom_attributes[show_all_text]|wash()}{/if}" />
                        </div>

                    </div>
                </div>
                {/if}
            </div>

            <div class="col-md-6">
                {if $is_dynamic}
                    {include uri='design:block/edit/parts/dynamic_source.tpl'}
                {/if}

                {if ezini_hasvariable( $block.type, 'CustomAttributes', 'block.ini' )}
                    {def $custom_attributes = array()
                         $custom_attribute_types = array()
                         $custom_attribute_names = array()
                        $use_browse_mode = array()
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
                    {if ezini_hasvariable( $block.type, 'UseBrowseMode', 'block.ini' )}
                        {set $use_browse_mode = ezini( $block.type, 'UseBrowseMode', 'block.ini' )}
                    {/if}
                    {def $custom_attributes_data = array()}
                    {def $custom_attributes_advanced_data = array()}
                    {def $custom_attributes_item = false()}
                    {foreach $custom_attributes as $custom_attrib}
                        {def $is_advanced = false()}
                        {def $label = false()}
                        {def $type = false()}
                        {def $help_text = false()}
                        {if is_set( $custom_attribute_names[$custom_attrib] )}
                            {set $label = $custom_attribute_names[$custom_attrib]|explode('(')[0]|trim()}
                            {if is_set( $custom_attribute_names[$custom_attrib]|explode('(')[1] )}
                                {set $help_text = concat('(', $custom_attribute_names[$custom_attrib]|explode('(')[1])}
                            {/if}
                            {if $custom_attribute_names[$custom_attrib]|contains('[Impostazione avanzata]')}
                                {set $is_advanced = true()}
                                {set $label = $label|explode('[Impostazione avanzata]')[1]|trim()}
                            {/if}
                        {/if}
                        {if and( is_set( $use_browse_mode[$custom_attrib] ), eq( $use_browse_mode[$custom_attrib], 'true' ) )}
                            {set $type = 'custom_source'}
                        {else}
                            {if $label|not()}
                                {set $label = $custom_attrib}
                            {/if}
                            {if is_set( $custom_attribute_types[$custom_attrib] )}
                                {set $type = $custom_attribute_types[$custom_attrib]}
                            {else}
                                {set $type = 'default'}
                            {/if}
                        {/if}
                        {set $custom_attributes_item = hash(
                            'attribute', $attribute,
                            'zone_id', $zone_id,
                            'block_id', $block_id,
                            'block', $block,
                            'identifier', $custom_attrib,
                            'block_id', $block_id,
                            'type', $type,
                            'label', $label,
                            'help_text', $help_text,
                            'is_advanced', $is_advanced,
                            'loop_count', $loop_count
                        )}
                        {if $is_advanced}
                            {set $custom_attributes_advanced_data = $custom_attributes_advanced_data|append($custom_attributes_item)}
                        {else}
                            {set $custom_attributes_data = $custom_attributes_data|append($custom_attributes_item)}
                        {/if}
                        {undef $label $help_text $is_advanced $type}
                        {set $loop_count=inc( $loop_count )}
                    {/foreach}
                    {undef $loop_count}
                    {foreach $custom_attributes_data as $custom_attributes_item}
                        {include name="block_param" uri='design:block/edit/parts/custom_attribute.tpl' attribute=$custom_attributes_item}
                    {/foreach}
                    {if count($custom_attributes_advanced_data)}
                        <div class="cmp-accordion accordion border-0">
                                <div class="accordion-item border-0 bg-transparent">
                                    <div class="accordion-header" id="heading-{$block_id}">
                                        <button class="accordion-button collapsed p-0 bg-transparent border-0" type="button" style="border: none !important;"
                                                data-bs-toggle="collapse" data-bs-target="#collapse-{$block_id}" aria-expanded="false" aria-controls="collapse-{$block_id}">
                                            Impostazioni avanzate
                                        </button>
                                    </div>
                                    <div id="collapse-{$block_id}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{$block_id}">
                                        <div class="accordion-body p-0">
                                            {foreach $custom_attributes_advanced_data as $custom_attributes_item}
                                                {include name="block_param" uri='design:block/edit/parts/custom_attribute.tpl' attribute=$custom_attributes_item}
                                            {/foreach}
                                        </div>
                                    </div>
                                </div>
                        </div>
                    {/if}
                {/if}
                {include uri='design:block/edit/parts/items.tpl'}
            </div>
        </div>
    </div>
</div>

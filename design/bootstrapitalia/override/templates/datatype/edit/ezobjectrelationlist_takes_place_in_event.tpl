{def $class_content=$attribute.class_content
     $parent_node_id = cond( and( is_set( $class_content.default_placement.node_id ), $class_content.default_placement.node_id|eq( 0 )|not ), $class_content.default_placement.node_id, 1 )}

{def $privacy_states = privacy_states()}
{def $languages = ezini('RegionalSettings', 'SiteLanguageList')}
{def $owner_list = array(fetch(user,current_user).contentobject_id)}
{foreach $attribute.object.author_array as $author}
    {if $owner_list|contains($author.contentobject_id)|not()}
        {set $owner_list = $owner_list|append($author.contentobject_id)}
    {/if}
{/foreach}

{def $public_places_query = concat("classes [place] subtree [",$parent_node_id,"] and state in [", $privacy_states['privacy.public'].id, "] sort [name=>asc] limit 100")}
{debug-log msg='public_places_query' var=$public_places_query}
{def $public_places = api_search($public_places_query)}

{def $private_places_query = concat("classes [place] subtree [",$parent_node_id,"] and state in [", $privacy_states['privacy.private'].id, "] and owner_id in [", $owner_list|implode(','), "] sort [name=>asc] limit 100")}
{debug-log msg='private_places_query' var=$private_places_query}
{def $private_places = api_search($private_places_query)}

{def $all_used_places_id_list_query = concat("classes [event] and owner_id in [", $owner_list|implode(','), "] and facets [takes_place_in.id|count|100] limit 1")}
{debug-log msg='all_used_places_id_list_query' var=$all_used_places_id_list_query}
{def $all_used_places_id_list = api_search($all_used_places_id_list_query).facets[0].data|array_keys}

{def $shared_places = hash('totalCount', 0)}
{if count($all_used_places_id_list)}
    {def $shared_places_query = concat("classes [place] subtree [",$parent_node_id,"] and state in [", $privacy_states['privacy.private'].id, "] and owner_id !in [", $owner_list|implode(','), "] and id in [", $all_used_places_id_list|implode(','), "] sort [name=>asc] limit 100")}
    {debug-log msg='shared_places_query' var=$shared_places_query}
    {set $shared_places = api_search($shared_places_query)}
{/if}

{def $current_selection = array()}
{if ne( count( $attribute.content.relation_list ), 0)}
{foreach $attribute.content.relation_list as $item}
    {set $current_selection = $current_selection|append($item.contentobject_id)}
{/foreach}
{/if}

<input type="hidden" name="single_select_{$attribute.id}" value="1" />
<div data-simplified_place_gui="{$attribute.id}">
    <select data-place_selection_wrapper name="ContentObjectAttribute_data_object_relation_list_{$attribute.id}[]"
            class="form-control"
            placeholder="{'Select place'|i18n('agenda/place')}">
        <option value="no_relation" {if eq( $attribute.content.relation_list|count, 0 )} selected="selected"{/if}>{'Nowhere'|i18n( 'agenda/place' )}</option>

        {if $public_places.totalCount|gt(0)}
            <optgroup label="{'Editor choice'|i18n('agenda/place')}">
            {foreach $public_places.searchHits as $public_place}
                {foreach $languages as $language}
                    {if is_set($public_place.metadata.name[$language])}
                        <option data-lng="{$public_place.data[$language].has_address.longitude}"
                                data-lat="{$public_place.data[$language].has_address.latitude}"
                                value="{$public_place.metadata.id}" {if $current_selection|contains($public_place.metadata.id )}selected="selected"{/if}>
                            {$public_place.metadata.name[$language]|wash}
                        </option>
                        {break}
                    {/if}
                {/foreach}
            {/foreach}
            </optgroup>
        {/if}

        {if $shared_places.totalCount|gt(0)}
        <optgroup label="{'Shared'|i18n('agenda/place')}">
            {foreach $shared_places.searchHits as $shared_place}
                {foreach $languages as $language}
                    {if is_set($shared_place.metadata.name[$language])}
                        <option data-lng="{$shared_place.data[$language].has_address.longitude}"
                                data-lat="{$shared_place.data[$language].has_address.latitude}"
                                value="{$shared_place.metadata.id}" {if $current_selection|contains($shared_place.metadata.id )}selected="selected"{/if}>
                            {$shared_place.metadata.name[$language]|wash}
                        </option>
                        {break}
                    {/if}
                {/foreach}
            {/foreach}
        </optgroup>
        {/if}

        <optgroup data-new_place_select label="{'Your own'|i18n('agenda/place')}">
            {if $private_places.totalCount|gt(0)}
                {foreach $private_places.searchHits as $private_place}
                    {foreach $languages as $language}
                        {if is_set($private_places.metadata.name[$language])}
                            <option data-lng="{$private_places.data[$language].has_address.longitude}"
                                    data-lat="{$private_places.data[$language].has_address.latitude}"
                                    value="{$private_places.metadata.id}" {if $current_selection|contains($private_places.metadata.id )}selected="selected"{/if}>
                                {$private_places.metadata.name[$language]|wash}
                            </option>
                            {break}
                        {/if}
                    {/foreach}
                {/foreach}
            {/if}
        </optgroup>
    </select>

    <div class="position-relative">
        <div id="map-{$attribute.id}" style="width: 100%; height: 400px; margin: 10px 0;"></div>

        <div data-helper-texts style="display: none;">
            <div data-candrag>{'Puoi trascinare il marker sulla mappa per selezionare la posizione in maniera più precisa.'|i18n('add_place_gui')}</div>
            <div data-confirm>{'Aggiungi questa posizione ai tuoi luoghi'|i18n('add_place_gui')}</div>
        </div>

        <div data-window class="bg-white position-absolute h-100 w-100 overflow-auto" style="top: 0;z-index: 1000;display: none"></div>
    </div>

</div>

{ezcss_require('leaflet/geocoder/Control.Geocoder.css')}
{ezscript_require(array('leaflet/geocoder/Control.Geocoder.js', 'jquery.simplifiedPlaceGui.js'))}

<script>
$.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
{literal}

$(document).ready(function () {
    $('[data-simplified_place_gui="{/literal}{$attribute.id}{literal}"]').simplifiedPlaceGui({
        class: 'place',
        parent: {/literal}{$attribute.class_content.default_placement.node_id|int()}{literal},
        i18n:{{/literal}
            'search': '{'Search'|i18n('agenda')}',
            'noResults': '{'No contents'|i18n('opendata_forms')}',
            'myLocation': '{'Detect position'|i18n('add_place_gui')}',
            'store': "{'Store'|i18n('opendata_forms')}",
            'cancel': "{'Cancel'|i18n('opendata_forms')}",
            'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
            'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
            'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
        {literal}}
    });
});
{/literal}
</script>


{undef}

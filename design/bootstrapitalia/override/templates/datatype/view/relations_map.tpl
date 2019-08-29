{set_defaults(hash(
    'relation_view', 'list',
    'relation_has_wrapper', false()
))}

{def $node_list = array()
     $markers = array()}
{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}                
                {if $content_object|has_attribute('has_address')}
                    {set $markers = $markers|append($content_object|attribute('has_address').content)}
                {/if}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}
    {if $relation_view|eq('list')}
        {include uri='design:atoms/list_with_icon.tpl' items=$node_list}
    {else}
        {if $relation_has_wrapper|not()}<div class="card-wrapper card-teaser-wrapper">{/if}
        {foreach $node_list as $child }
            {node_view_gui content_node=$child view=card_teaser show_icon=true() image_class=widemedium}
        {/foreach}
        {if $relation_has_wrapper|not()}</div>{/if}
    {/if}

    <div class="map-wrapper map-column mt-4 mb-5">
        <div id="relations-map-{$attribute.id}" style="width: 100%; height: 400px;"></div>
    </div>

    {ezscript_require(array('jquery.ocdrawmap.js'))}
    <script type="text/javascript">
        {run-once}
        {literal}
        function drowRelationMap(id, latLngList) {
            var map = new L.Map('relations-map-'+id);
            map.scrollWheelZoom.disable();
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);
            var markers = L.markerClusterGroup().addTo(map);            
            var customIcon = L.MakiMarkers.icon({icon: "star", color: "#f00", size: "l"});            
            $.each(latLngList, function () {
                var postMarker = new L.marker(this,{icon:customIcon});
                postMarker.addTo(markers)
            });            
            if (markers.getLayers().length > 0) {
                map.fitBounds(markers.getBounds());
            }
        }
        {/literal}
        {/run-once}
        drowRelationMap({$attribute.id},[{foreach $markers as $marker}[{$marker.latitude},{$marker.longitude}]{delimiter},{/delimiter}{/foreach}]);
    </script>

{/if}

{undef $node_list $markers}

{unset_defaults(array('relation_view', 'relation_has_wrapper'))}
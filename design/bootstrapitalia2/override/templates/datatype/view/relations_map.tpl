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
{def $has_geo = cond($attribute.object|has_attribute('geo'), $attribute.object|attribute('geo'), false())}
{if $has_geo}
    {set $markers = $markers|append($has_geo.content)}
{/if}

{if or(count($node_list)|gt(0), $has_geo)}
    {if $relation_view|eq('list')}
        {include uri='design:atoms/list_with_icon.tpl' items=$node_list}
        {if $has_geo}
        {/if}
    {else}
        <div class="card-wrapper card-column my-3" data-bs-toggle="masonry">
        {foreach $node_list as $child }
            {node_view_gui content_node=$child view=card_teaser_info show_icon=true() image_class=widemedium}
        {/foreach}
        {if $has_geo}
            {def $geo_link = concat('https://www.google.com/maps/dir/', $has_geo.content.latitude, ',', $has_geo.content.longitude, '/@', $has_geo.content.latitude, ',', $has_geo.content.longitude, ',15z?hl=it')}
            {if openpaini('Attributi', 'GeoMapLink', 'google')|eq('nominatim')}
                {set $geo_link = concat('https://www.openstreetmap.org/directions?route=', $has_geo.content.latitude, ', ', $has_geo.content.longitude)}
            {elseif openpaini('Attributi', 'GeoMapLink', 'google')|eq('disabled')}
                {set $geo_link = concat('#geo:', $has_geo.content.latitude, ',', $has_geo.content.longitude)}
            {/if}
            <div data-object_id="2400" class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3 " style="z-index: 100">
                <div class="card-body pe-3">
                    <div class="card-text u-main-black">
                        <div class="mt-1">
                            <a href="{$geo_link}" target="_blank" rel="noopener noreferrer" class="text-decoration-none">
                                <i aria-hidden="true" class="fa fa-map"></i> {$has_geo.content.address|wash()}
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            {undef $geo_link}
        {/if}
        </div>
    {/if}
    
    <div class="map-wrapper map-column mt-4 mb-5">
        <div id="relations-map-{$attribute.id}" style="width: 100%; height: 400px;"></div>
    </div>
    {ezscript_require(array('leaflet/leaflet.0.7.2.js','leaflet/Leaflet.MakiMarkers.js', 'leaflet/leaflet.markercluster.js'))}
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
            var customIcon = L.divIcon({html: '<i class="fa fa-map-marker fa-4x text-primary"></i>',iconSize: [20, 20],className: 'myDivIcon'});
            $.each(latLngList, function () {
                var postMarker = new L.marker(this,{icon:customIcon, interactive: false});
                postMarker.addTo(markers)
            });            
            if (markers.getLayers().length > 0) {
                map.fitBounds(markers.getBounds());
            }
        }
        {/literal}
        {/run-once}
        $(document).ready(function () {ldelim}
        drowRelationMap({$attribute.id},[{foreach $markers as $marker}[{$marker.latitude},{$marker.longitude}]{delimiter},{/delimiter}{/foreach}]);
        {rdelim});
    </script>
    <style>
        .map-wrapper.map-column .leaflet-clickable{ldelim}
            cursor: grab !important;
        {rdelim}
    </style>

{/if}

{undef $node_list $markers $has_geo}

{unset_defaults(array('relation_view', 'relation_has_wrapper'))}
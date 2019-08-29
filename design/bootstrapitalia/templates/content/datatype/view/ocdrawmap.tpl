{run-once}
{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css'
))}
{ezscript_require(array(
    'leaflet.js',
    'ezjsc::jquery',
    'Leaflet.MakiMarkers.js',
    'jquery.ocdrawmap.js'
))}
{/run-once}

<div class="map-wrapper map-column mt-4 mb-5">
<div id="map-{$attribute.id}"
     data-geojson='{$attribute.content.geo_json}'
     data-type="{$attribute.content.type}"
     data-color="{if $attribute.content.color}{$attribute.content.color}{else}#3388ff{/if}"
     style="width: 100%; height: 600px; margin: 10px 0"></div>

<script>
    $('#map-{$attribute.id}').ocviewmap();
</script>
</div>
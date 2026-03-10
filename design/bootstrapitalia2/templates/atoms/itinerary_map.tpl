{def $map_id = concat('itinerary-map-', $block_id)}

<div class="mb-4 position-relative">
  <div id="{$map_id}-loader" class="position-absolute top-0 start-0 w-100 h-100 d-flex justify-content-center align-items-center bg-white bg-opacity-75">
    <div class="spinner-border text-primary" role="status">
      <span class="visually-hidden">Caricamento...</span>
    </div>
  </div>
  <div id="{$map_id}" style="height:500px;"></div>
</div>

{def $markers = array()}
{foreach $items as $stage}
  {if and($stage.class_identifier|eq('itinerary_stage'), $stage.data_map.places.has_content)}
    {foreach $stage.data_map.places.content.relation_list as $place_relation}
      {def $place_obj = fetch(content, object, hash(object_id, $place_relation.contentobject_id))}
      {if and($place_obj.can_read, $place_obj|has_attribute('has_address'))}
        {def $geo = $place_obj|attribute('has_address').content}
        {if and($geo.latitude, $geo.longitude)}
          {set $markers = $markers|merge(array(hash(
            'lat', $geo.latitude,
            'lng', $geo.longitude,
            'stage', $stage.name,
            'place', $place_obj.name,
            'address', $geo.address,
            'url', concat('/', $place_obj.main_node.url_alias)
          )))}
          {undef $geo}
        {/if}
      {/if}
      {undef $place_obj}
    {/foreach}
  {/if}
{/foreach}
<script type="application/json" id="{$map_id}-data">{$markers|encode_json()}</script>

{def $scripts = array()}
{set $scripts = $scripts|merge(array(
    'leaflet/leaflet.0.7.2.js',
    'leaflet/Control.Geocoder.js',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/leaflet.activearea.js',
    'leaflet/leaflet.markercluster.js',
    'fields/SimpleOpenStreetMap.js',
))}
{ezscript_require($scripts)}
{ezcss_require(array(
    'leaflet/Control.Loading.css',
    'leaflet/MarkerCluster.css',
    'leaflet/MarkerCluster.Default.css',
))}

{literal}
<script>
    const mapId = '{/literal}{$map_id}{literal}';
    const loaderId = mapId + '-loader';

    document.addEventListener("DOMContentLoaded", initMapApp);

    function initMapApp() {
        const map = createMap();
        const loaderOverlay = document.getElementById(loaderId);
        loadMarkers(map, function() {});
    }

    function createMap() {
        const map = L.map(mapId, { loadingControl: true }).setView([41.9, 12.5], 6);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);
        return map;
    }

    function loadMarkers(map, onLoad) {
        const dataEl = document.getElementById(mapId + '-data');
        if (!dataEl) { if (onLoad) onLoad(); return; }

        let markers;
        try { markers = JSON.parse(dataEl.textContent); } catch(e) { if (onLoad) onLoad(); return; }

        map.fire("dataloading");
        // defer marker insertion so map tiles start loading first
        setTimeout(function() {
            const clusterGroup = L.markerClusterGroup();
            const icon = L.divIcon({
                html: '<i class="fa fa-map-marker fa-4x text-primary"></i>',
                iconSize: [28, 48],
                iconAnchor: [14, 48],
                popupAnchor: [0, -50],
                className: 'customDivIcon'
            });

            markers.forEach(function(m) {
                const addressHtml = m.address
                    ? '<p class="card-text mt-1" style="font-size:.85em;">' + m.address + '</p>'
                    : '';
                const popupContent =
                    '<div class="card-wrapper border border-light rounded shadow-sm pb-0">' +
                      '<div class="card no-after rounded bg-white">' +
                        '<div class="card-body">' +
                          '<div class="category-top">' +
                            '<span class="title-xsmall-semi-bold fw-semibold">' + m.stage + '</span>' +
                          '</div>' +
                          '<div class="card-text">' +
                            '<a href="' + m.url + '" class="font-sans-serif card-title h6 text-decoration-none d-block mb-0">' + m.place + '</a>' +
                            addressHtml +
                          '</div>' +
                        '</div>' +
                      '</div>' +
                    '</div>';
                const marker = L.marker([m.lat, m.lng], { icon: icon });
                marker.bindPopup(popupContent, { minWidth: 250 });
                clusterGroup.addLayer(marker);
            });

            map.addLayer(clusterGroup);
            fitMap(map, clusterGroup);
            map.fire("dataload");
            if (onLoad) onLoad();
        }, 0);
    }

    function fitMap(map, clusterGroup) {
        if (clusterGroup.getLayers().length > 0) {
            map.fitBounds(clusterGroup.getBounds(), { padding: [20, 20] });
        }
    }
</script>
{/literal}

{undef $map_id $scripts $markers}

{def $map_id = concat('itinerary-map-', $block_id)}

<div class="mb-4 position-relative">
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
    'leaflet/gpx.js',
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
    const gpxUrl = '{/literal}{$gpx_url|wash(javascript)}{literal}';

    document.addEventListener("DOMContentLoaded", initMapApp);

    function initMapApp() {
        const map = createMap();
        loadGpxTrack(map, function(gpxLayer) {
            loadMarkers(map, gpxLayer, function() {});
        });
    }

    function createMap() {
        const map = L.map(mapId, { loadingControl: true, scrollWheelZoom: false }).setView([41.9, 12.5], 6);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);
        return map;
    }

    function loadGpxTrack(map, onLoad) {
        if (!gpxUrl) { onLoad(null); return; }

        var gpxLayer = new L.GPX(gpxUrl, {
            async: true,
            marker_options: {
                startIconUrl: "{/literal}{'images/icons/pin-icon-start.png'|ezdesign(no)}{literal}",
                endIconUrl: "{/literal}{'images/icons/pin-icon-end.png'|ezdesign(no)}{literal}",
                shadowUrl: "{/literal}{'images/icons/pin-shadow.png'|ezdesign(no)}{literal}",
                wptIconUrls : {
                  '': "{/literal}{'images/icons/pin-icon-wpt.png'|ezdesign(no)}{literal}",
                },
            },
            polyline_options: {
                color: 'var(--bs-primary)',
                weight: 4,
                opacity: 0.85
            }
        });

        gpxLayer.on('loaded', function(e) {
            onLoad(gpxLayer);
        });

        gpxLayer.on('error', function() {
            onLoad(null);
        });

        gpxLayer.addTo(map);
    }

    function loadMarkers(map, gpxLayer, onLoad) {
        const dataEl = document.getElementById(mapId + '-data');
        if (!dataEl) { if (onLoad) onLoad(); return; }

        let markers;
        try { markers = JSON.parse(dataEl.textContent); } catch(e) { if (onLoad) onLoad(); return; }

        map.fire("dataloading");
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

            // fit bounds combining GPX track + markers
            var allLayers = [];
            if (gpxLayer) allLayers.push(gpxLayer);
            if (clusterGroup.getLayers().length > 0) allLayers.push(clusterGroup);
            if (allLayers.length > 0) {
                map.fitBounds(L.featureGroup(allLayers).getBounds(), { padding: [20, 20] });
            }

            map.fire("dataload");
            if (onLoad) onLoad();
        }, 0);
    }
</script>
{/literal}

{undef $map_id $scripts $markers}

{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}
  {if count($block.valid_nodes)|gt(0)}
    <div class="container">
      <div class="row">
        <div class="col-md-8">
          <div id="dataset-map-{$block.id}" style="height:500px;"></div>
        </div>
        <div class="col-md-4" id="dataset-controls-{$block.id}">
          <h3>Dataset</h3>
          {foreach $block.valid_nodes as $valid_node}
            {if and($valid_node.object.class_identifier|eq('dataset'), $valid_node.data_map.csv_resource.content.views|contains('map'))}
              {def $custom_repository = concat('dataset-', $valid_node.data_map.csv_resource.contentclass_attribute_identifier, '-',$valid_node.data_map.csv_resource.contentobject_id)}
              <div class="form-check">
                <input id="checkbox-{$valid_node.node_id}" type="checkbox" checked="checked" data-geojson="{concat('/customgeo/',$custom_repository)|ezurl(no)}/">
                <label for="checkbox-{$valid_node.node_id}">{$valid_node.data_map.csv_resource.content.item_name|wash()}</label>
              </div>
            {/if}
          {/foreach}
        </div>
      </div>
    </div>
  {/if}
{/if}
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
    'leaflet/leaflet.0.7.2.css',
    'leaflet/Control.Loading.css',
    'leaflet/MarkerCluster.css',
    'leaflet/MarkerCluster.Default.css',

))}

{literal}  
<script>
const mapId = 'dataset-map-{/literal}{$block.id}{literal}';
const controlsId = 'dataset-controls-{/literal}{$block.id}{literal}';
document.addEventListener("DOMContentLoaded", initMapApp);

function initMapApp() {
  const map = createMap();
  const layers = {};
  const checkboxes = document.querySelectorAll(`#${controlsId} [data-geojson]`);

  let loadedCount = 0;

  checkboxes.forEach(cb => {
    loadDataset(cb, map, layers, () => {
      loadedCount++;
      if (loadedCount === checkboxes.length) {
        fitActiveLayers(map, layers);
      }
    });
  });
}

function createMap() {
  const map = L.map(mapId).setView([41.9, 12.5], 6);

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  return map;
}

function loadDataset(checkbox, map, layers, onLoad) {
  const url = checkbox.dataset.geojson;

  fetch(url)
    .then(res => res.json())
    .then(data => {
      const layer = L.geoJson(data, {
        pointToLayer: function(feature, latlng) {
          let icon = L.divIcon({
            html: '<i class="fa fa-map-marker fa-2x text-primary"></i>',
            iconSize: [20, 20],
            className: 'customDivIcon'
          });
          return L.marker(latlng, { icon: icon });
        },
        onEachFeature: function(feature, layer) {
          let props = feature.properties || {};

          // Titolo
          let title = props.Name || 'Nessun titolo';

          // Filtra campi da mostrare
          let hiddenKeys = ['_createdAt', '_creator', '_guid', '_modifiedAt', 'Geo', 'Name'];
          let contentText = '';
          Object.keys(props).forEach(key => {
            if (!hiddenKeys.includes(key)) {
              contentText += `${key}: ${props[key]}<br>`;
            }
          });

          // Template HTML del baloon
          let popupContent = `
            <div class="card-wrapper border border-light rounded shadow-sm cmp-list-card-img cmp-list-card-img-hr">
              <div class="card no-after rounded bg-white">
                <div class="card-body pb-5">
                  <h3 class="card-title">${title}</h3>
                  <div class="card-text pb-3">
                    ${contentText}
                  </div>
                </div>
              </div>
            </div>
          `;

          layer.bindPopup(popupContent, { minWidth: 250 });
        }
      });

      layers[checkbox.id] = layer;

      map.addLayer(layer);
      checkbox.checked = true;

      checkbox.addEventListener("change", () => {
        toggleLayer(map, layers);
      });

      if (typeof onLoad === "function") onLoad(layer);
    })
    .catch(err => console.error("Errore caricamento GeoJSON:", url, err));
}

function toggleLayer(map, layers) {
  Object.keys(layers).forEach(id => {
    const checkbox = document.getElementById(id);
    const layer = layers[id];
    if (checkbox.checked) {
      if (!map.hasLayer(layer)) map.addLayer(layer);
    } else {
      if (map.hasLayer(layer)) map.removeLayer(layer);
    }
  });
  fitActiveLayers(map, layers);
}

function fitActiveLayers(map, layers) {
  const activeLayers = Object.values(layers).filter(layer => map.hasLayer(layer));
  if (activeLayers.length > 0) {
    const group = L.featureGroup(activeLayers);
    map.fitBounds(group.getBounds(), { padding: [20, 20] });
  }
}
</script>

{/literal}
{undef $openpa $scripts}
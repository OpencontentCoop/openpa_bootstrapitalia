
<div class="row mb-5" id="dataset-map-block-{$block_id}">
  <div class="col-12 col-lg-4 ps-lg-5 mb-4 mb-lg-0" id="dataset-controls-{$block_id}">
    <fieldset>
      <legend class="h6 mb-3 ps-0">{'Type'|i18n('bootstrapitalia')}</legend>
      <div class="row">
        {if is_set($items[0])}
          {foreach $items as $valid_node max 10}
            {if and($valid_node.class_identifier|eq('dataset'), $valid_node.data_map.csv_resource.content.views|contains('map'))}
              {def $custom_repository = concat('dataset-', $valid_node.data_map.csv_resource.contentclass_attribute_identifier, '-',$valid_node.data_map.csv_resource.contentobject_id)}
              {def $data = $valid_node.data_map.csv_resource.data_text|decode_json().fields}
              {def $fields = array()}
              {foreach $data as $item}
                {set $fields = $fields|merge( hash( $item.identifier, $item.label ) )}
              {/foreach}
              {def $fields_labels = $fields|encode_json()}

              <div class="col-12 col-sm-6 col-lg-12">
                <div class="form-check">
                  <input 
                    id="checkbox-{$valid_node.node_id}"
                    type="checkbox"
                    checked="checked"
                    data-geojson="{concat('/customgeo/',$custom_repository)|ezurl(no)}/"
                    data-fields-text="{$fields_labels|wash()}">
                  <label for="checkbox-{$valid_node.node_id}">{$valid_node.data_map.title.content|wash()}</label>
                </div>
              </div>
              {undef $custom_repository $fields $fields_labels $data}
            {else}
              {editor_warning(concat("Non sono presenti luoghi georeferenziati con vista mappa per il dataset: ",$valid_node.name))}
            {/if}
          {/foreach}
        {/if}
      </div>
      </fieldset>
  </div>
  <div class="order-lg-first col-12 col-lg-8">
    <div class="position-relative">
      <div id="dataset-map-loader-{$block_id}" class="position-absolute top-0 start-0 w-100 h-100 d-flex justify-content-center align-items-center bg-white bg-opacity-75">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Caricamento...</span>
        </div>
      </div>
      <div id="dataset-map-{$block_id}" style="height:500px;"></div>
    </div>
  </div>
</div>

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
    const blockId = 'dataset-map-block-{/literal}{$block_id}{literal}';
    const mapId = 'dataset-map-{/literal}{$block_id}{literal}';
    const controlsId = 'dataset-controls-{/literal}{$block_id}{literal}';
    const loaderId = 'dataset-map-loader-{/literal}{$block_id}{literal}';
    const placeDefaultLabel = '{/literal}{'Place'|i18n('openpa/search')}{literal}';

    document.addEventListener("DOMContentLoaded", initMapApp);

    function initMapApp() {
      const map = createMap();
      const layers = {};
      const checkboxes = document.querySelectorAll(`#${controlsId} [data-geojson]`);

      let loadedCount = 0;
      const loaderOverlay = document.getElementById(loaderId);

      checkboxes.forEach(cb => {
        loadDataset(cb, map, layers, () => {
          loadedCount++;
          if (loadedCount === checkboxes.length) {
            if (loaderOverlay) loaderOverlay.style.setProperty("display", "none", "important");
            fitActiveLayers(map, layers);
          }
        });
      });
    }

    function createMap() {
      const map = L.map(mapId, {
        loadingControl: true
      }).setView([41.9, 12.5], 6);

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
      }).addTo(map);

      return map;
    }

    function parseFieldsText(fieldsText) {
      if (!fieldsText) return {};

      try {
        const decodedText = fieldsText.replace(/&quot;/g, '"');
        const obj = JSON.parse(decodedText);
        const map = {};

        for (const key in obj) {
          if (Object.hasOwn(obj, key)) {
            map[key] = obj[key];
          }
        }

        return map;
      } catch (e) {
        console.warn("Errore parsing fieldsText:", e);
        return {};
      }
    }

    function loadDataset(checkbox, map, layers, onLoad) {
      const url = checkbox.dataset.geojson;
      const fieldsText = checkbox.getAttribute('data-fields-text') || '{}';
      const fieldLabels = parseFieldsText(fieldsText);

      const datasetName = checkbox.nextElementSibling
        ? checkbox.nextElementSibling.innerText.trim()
        : placeDefaultLabel;

      map.fire("dataloading");

      fetch(url)
        .then(res => res.json())
        .then(data => {
          const clusterGroup = L.markerClusterGroup();


          if (data && Array.isArray(data.features)) {
            data.features = data.features.slice(0, 1000);
          }

          const geoLayer = L.geoJson(data, {
            pointToLayer: function(feature, latlng) {
              let icon = L.divIcon({
                html: '<i class="fa fa-map-marker fa-4x text-primary"></i>',
                iconSize: [28, 48],
                iconAnchor: [14, 48],
                popupAnchor: [0, -50],
                className: 'customDivIcon'
              });
              return L.marker(latlng, { icon: icon });
            },
            onEachFeature: function(feature, layer) {
              let props = feature.properties || {};
              let hiddenKeys = ['_createdAt', '_creator', '_guid', '_modifiedAt'];
              let contentText = '';

              function isLatLong(value) {
                if (typeof value !== 'string') return false;
                const trimmed = value.trim();
                const regex = /^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$/;
                if (!regex.test(trimmed)) return false;
                const [lat, lon] = trimmed.split(',').map(Number);
                return (
                  lat >= -90 && lat <= 90 &&
                  lon >= -180 && lon <= 180
                );
              }

              let itemsCount = 0;
              for (const key of Object.keys(props)) {
                const value = props[key];
                if (hiddenKeys.includes(key) || isLatLong(value)) continue;
                if (value === null || value === undefined || value === '') continue;
                
                const label = fieldLabels[key] || key;
                contentText += `<div><strong>${label}:</strong> <span>${value}</span></div>`;
                itemsCount++;
                if (itemsCount >= 5) break;
              }
              let popupContent = `
                <div class="card-wrapper border border-light rounded shadow-sm pb-0">
                  <div class="card no-after rounded bg-white">
                    <div class="card-body">
                      <div class="category-top">
                        <span class="title-xsmall-semi-bold fw-semibold">
                          ${datasetName}
                        </span>
                      </div>
                      <div class="card-text">
                        ${contentText}
                      </div>
                    </div>
                  </div>
                </div>
              `;

              layer.bindPopup(popupContent, { minWidth: 250 });
            }
          });

          clusterGroup.addLayer(geoLayer);
          layers[checkbox.id] = clusterGroup;
          map.addLayer(clusterGroup);
          checkbox.checked = true;

          checkbox.addEventListener("change", () => {
            toggleLayer(map, layers);
          });

          if (typeof onLoad === "function") onLoad(clusterGroup);
        })
        .catch(err => console.error("Errore caricamento GeoJSON:", url, err))
        .finally(() => {
          map.fire("dataload");
        });
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
{undef $scripts}
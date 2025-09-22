{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}
  {if count($block.valid_nodes)|gt(0)}
    <div class="{$valid_node|access_style}">
      <div class="row mb-5" id="dataset-map-block-{$block.id}">
        <div class="col-12 col-lg-4 ps-lg-5 mb-4 mb-lg-0" id="dataset-controls-{$block.id}">
          <fieldset>
            <legend class="h6 mb-3 ps-0">{'Type'|i18n('bootstrapitalia')}</legend>
              <div class="row">
                {foreach $block.valid_nodes as $valid_node}
                  {if and($valid_node.object.class_identifier|eq('dataset'), $valid_node.data_map.csv_resource.content.views|contains('map'))}
                    {def $custom_repository = concat('dataset-', $valid_node.data_map.csv_resource.contentclass_attribute_identifier, '-',$valid_node.data_map.csv_resource.contentobject_id)}
                    <div class="col-12 col-sm-6 col-lg-12">
                      <div class="form-check">
                        <input id="checkbox-{$valid_node.node_id}" type="checkbox" checked="checked" data-geojson="{concat('/customgeo/',$custom_repository)|ezurl(no)}/">
                        <label for="checkbox-{$valid_node.node_id}">{$valid_node.data_map.csv_resource.content.item_name|wash()}</label>
                      </div>
                    </div>
                  {else}
                    {editor_warning(concat("Non sono presenti luoghi georeferenziati con vista mappa per il dataset: ",$valid_node.name))}
                  {/if}
                {/foreach}
              </div>
            </fieldset>
        </div>
        <div class="order-lg-first col-12 col-lg-8">
          <div class="position-relative">
            <div id="dataset-map-loader-{$block.id}" class="position-absolute top-0 start-0 w-100 h-100 d-flex justify-content-center align-items-center bg-white bg-opacity-75">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Caricamento...</span>
              </div>
            </div>
            <div id="dataset-map-{$block.id}" style="height:500px;"></div>
          </div>
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
    'leaflet/Control.Loading.css',
    'leaflet/MarkerCluster.css',
    'leaflet/MarkerCluster.Default.css',

))}

{literal}  
  <script>
    const blockId = 'dataset-map-block-{/literal}{$block.id}{literal}';
    const mapId = 'dataset-map-{/literal}{$block.id}{literal}';
    const controlsId = 'dataset-controls-{/literal}{$block.id}{literal}';
    const loaderId = 'dataset-map-loader-{/literal}{$block.id}{literal}';
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

    function loadDataset(checkbox, map, layers, onLoad) {
      const url = checkbox.dataset.geojson;

      const datasetName = checkbox.nextElementSibling
        ? checkbox.nextElementSibling.innerText.trim()
        : placeDefaultLabel;

      map.fire("dataloading");

      fetch(url)
        .then(res => res.json())
        .then(data => {
          const clusterGroup = L.markerClusterGroup();

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
              let title = props.Name || 'Nessun titolo';
              let hiddenKeys = ['_createdAt', '_creator', '_guid', '_modifiedAt', 'Geo', 'Name'];
              let contentText = '';

              Object.keys(props).forEach(key => {
                if (!hiddenKeys.includes(key)) {
                  let value = props[key];
                  if (value !== null && value !== undefined && value !== "") {
                    contentText += `${value}<br>`;
                  }
                }
              });

              let popupContent = `
                <div class="card-wrapper border border-light rounded shadow-sm pb-0">
                  <div class="card no-after rounded bg-white">
                    <div class="card-body">
                      <div class="category-top">
                        <span class="title-xsmall-semi-bold fw-semibold">
                          ${datasetName}
                        </span>
                      </div>
                      <h3 class="h5 card-title">${title}</h3>
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
{undef $openpa $scripts}
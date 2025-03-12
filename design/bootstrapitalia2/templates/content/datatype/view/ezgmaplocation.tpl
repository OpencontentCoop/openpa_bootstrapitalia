{if and( $attribute.content.latitude, $attribute.content.longitude )}

    {def $geo_link = concat('https://www.google.com/maps/dir//', $attribute.content.latitude, ',', $attribute.content.longitude, '/@', $attribute.content.latitude, ',', $attribute.content.longitude, ',15z?hl=it')}
    {if openpaini('Attributi', 'GeoMapLink', 'google')|eq('nominatim')}
        {set $geo_link = concat('https://www.openstreetmap.org/directions?route=', $attribute.content.latitude, ', ', $attribute.content.longitude)}
    {elseif openpaini('Attributi', 'GeoMapLink', 'google')|eq('disabled')}
        {set $geo_link = concat('#geo:', $attribute.content.latitude, ',', $attribute.content.longitude)}
    {/if}

    {if and(is_set($only_address), $only_address)}
      {if $attribute.content.address|ne('')}
      <a href="{$geo_link}"
        target="_blank"
        rel="noopener noreferrer"
        class="text-decoration-none">
        <i aria-hidden="true" class="fa fa-map"></i> {$attribute.content.address}
      </a>
      {/if}
    {else}
    {if $attribute.content.address}
    <div class="card-wrapper card-teaser-wrapper">
        <div class="font-sans-serif card card-teaser shadow mt-3 rounded">
            <div class="card-body">
                <div class="card-text">
                    <div class="row g-0">
                        <div class="col-1 mt-2 text-center">
                            {display_icon('it-pin', 'svg', 'icon')}
                        </div>
                        <p class="col">
                            <a class="d-block ps-3" href="{$geo_link}" rel="noopener noreferrer" target="_blank">
                                {$attribute.content.address}
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    {/if}
    <div class="map-wrapper map-column mt-4 mb-5">
      <div id="map-{$attribute.id}" style="width: 100%; height: 320px;"></div>

      {ezscript_require(array('leaflet/leaflet.0.7.2.js','leaflet/Leaflet.MakiMarkers.js'))}
      {run-once}
      {literal}
        <script type="text/javascript">
          var drawMap = function(latlng,id){
            var map = new L.Map('map-'+id);
            map.scrollWheelZoom.disable();
            var customIcon = L.divIcon({html: '<i class="fa fa-map-marker fa-4x text-primary"></i>',iconSize: [20, 20],className: 'myDivIcon'});
            var postMarker = new L.marker(latlng,{icon:customIcon});
            postMarker.addTo(map);
            map.setView(latlng, 18);
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
              attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);
          }
        </script>
      {/literal}
      {/run-once}

      <script type="text/javascript">
      $(document).ready(function () {ldelim}
        drawMap([{$attribute.content.latitude},{$attribute.content.longitude}],{$attribute.id});
      {rdelim});
      </script>
    </div>
{/if}
{undef $geo_link}
{/if}

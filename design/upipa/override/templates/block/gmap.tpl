{set_defaults( hash('show_title', true()) )}
{def $key = $block.custom_attributes.key
     $location = $block.custom_attributes.location}

{ezscript_require( 'ezjsc::yui3' )}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>

    {/if}
    <div class="openpa-widget-content">
        <div id="map-container-{$block.id}" class="map-container"></div>

        {if ne( $key, '' )}
        <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=true&amp;key={$key}" type="text/javascript"></script>
        {/if}

        <script>
            YUI(YUI3_config).use('event', function(Y) {ldelim}
                Y.on('domready', function() {ldelim}
                    if (GBrowserIsCompatible()) {ldelim}
                        var mapContainer = document.getElementById("map-container-{$block.id}");
                        var map = new GMap2(mapContainer);
                        var geocoder = new GClientGeocoder();
                        geocoder.getLatLng("{$location}", function(point) {ldelim}
                            if (point) {ldelim}
                                map.setCenter(point, 13);
                                var marker = new GMarker(point);
                                map.addOverlay(marker);
                                marker.openInfoWindowHtml("{$location}");
                                {rdelim}
                            {rdelim});
                        {rdelim}
                    {rdelim});
                {rdelim});
        </script>

        {undef $key $location}
    </div>
</div>

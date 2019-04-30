{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}

{run-once}
{ezcss_require(array(
    'leaflet/geocoder/Control.Geocoder.css',
    'leaflet/Control.Loading.css',
    'leaflet.draw.css',
    'spectrum.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'leaflet/Control.Loading.js',
    'leaflet/geocoder/Control.Geocoder.js',
    'leaflet.draw.js',
    'leaflet-osm-data.js',
    'spectrum.js',
    'jquery.ocdrawmap.js'
))}
{/run-once}
<div id="ocdrawmap-{$attribute.id}">
    <div class="map" style="width: 100%; height: 400px; margin: 10px 0"></div>

    <p>
        <strong>Colore layers</strong>
        <input type='text'
                   class="Form-input map-color"
                   name="{$attribute_base}_ocdrawmap_osm_color_{$attribute.id}"
                   value="{if $attribute.content.color}{$attribute.content.color}{else}#3388ff{/if}" />
    </p>
    <strong>Importa dati</strong>
    <div class="row">
        <div class="col">
            <select class="map-import-type form-control"
                    name="{$attribute_base}_ocdrawmap_osm_type_{$attribute.id}">
                <option>Seleziona sorgente</option>
                <option value="osm" {if $attribute.content.type|eq('osm')}selected="selected"{/if}>Openstreet map full xml</option>
                <option value="ocql_geo" {if $attribute.content.type|eq('ocql_geo')}selected="selected"{/if}>Opencontent Geo API</option>
            </select>
        </div>
        <div class="col-8">
            <input class="form-control map-import-url"
                   name="{$attribute_base}_ocdrawmap_osm_url_{$attribute.id}"
                   value="{$attribute.content.source|wash()}"
                   placeholder="Url sorgente"
                   type="text"/>
        </div>
        <div class="col">
            <input class="btn btn-info map-import-submit" type="submit" id="import-osm-url"
                   {if $attribute.content.source|ne('')}style="display: none;"{/if}
                   name="CustomActionButton[{$attribute.id}_ocdrawmap_save_osm_url]"
                   value="Importa" />
        </div>
    </div>

    <input class="map-data"
           type="hidden"
           name="{$attribute_base}_ocdrawmap_data_text_{$attribute.id}"
           value="{$attribute.content.geo_json|wash()}" />
</div>
<style>
    .leaflet-div-icon {ldelim}
        background: #fff !important;
        border: 1px solid #666 !important;
    {rdelim}
</style>
<script>
$(document).ready(function(){ldelim}
    $('#ocdrawmap-{$attribute.id}').oceditmap();
{rdelim});
</script>

    
{/default}

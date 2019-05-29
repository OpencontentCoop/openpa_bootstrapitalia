{ezscript_require(array(
    'ezjsc::jquery',
    'ezjsc::jqueryUI',
    'bootstrap.min.js',
    'bootstrap/tooltip.js',
    'bootstrap/popover.js',
    'plugins/chosen.jquery.js',
    'moment.min.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap.js',
    'jquery.opendataDataTable.js',
    'jquery.opendataTools.js',
    'summernote/summernote-bs4.js',
    'handlebars.min.js',
    'moment-with-locales.min.js',
    'bootstrap-datetimepicker.min.js',
    'jquery.fileupload.js',
    'jquery.fileupload-process.js',
    'jquery.fileupload-ui.js',
    'jquery.tag-editor.js',
    'popper.min.js',
    'alpaca.js',
    'leaflet/leaflet.0.7.2.js',
    'leaflet/Control.Geocoder.js',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/leaflet.activearea.js',
    'leaflet/leaflet.markercluster.js',
    'jquery.price_format.min.js',
    'jquery.opendatabrowse.js',
    'fields/OpenStreetMap.js',
    'fields/RelationBrowse.js',
    'fields/LocationBrowse.js',
    'fields/Tags.js',
    ezini('JavascriptSettings', 'IncludeScriptList', 'ocopendata_connectors.ini'),
    'jquery.opendataform.js'
))}
{ezcss_require(array(
    'ocbootstrap.css',
    'alpaca.min.css',
    'leaflet/leaflet.0.7.2.css',
    'leaflet/Control.Loading.css',
    'leaflet/MarkerCluster.css',
    'leaflet/MarkerCluster.Default.css',
    'bootstrap-datetimepicker.min.css',
    'jquery.fileupload.css',
    'summernote/summernote-bs4.css',
    'jquery.tag-editor.css',
    'alpaca-custom.css'
))}
{literal}
<script type="text/javascript">
$(document).ready(function(){    
    $('.ezobject-relationlist-browse').each(function(){
        var self = $(this);
        var subtree = $(this).data('subtree');        
        var classes = $(this).data('classes') ? $(this).data('classes').split(',') : false;
        var attributeBase = $(this).data('attribute_base');
        var attributeId = $(this).data('attribute');        
        var showThumbnail = $(this).data('show_thumbnail') == 1;

        self.opendataBrowse({
            'subtree': subtree,
            'addCloseButton': true,
            'addCreateButton': true,
            'classes': classes,
            'showThumbnail': showThumbnail
        }).on('opendata.browse.select', function (event, opendataBrowse) {
            var container = self.parents('.ezobject-relationlist-container').find('tbody');
            var priority = container.find('td.related-order').last().find('input').val() || -1;
            priority++;
            console.log(opendataBrowse.selection);
            $.each(opendataBrowse.selection, function(){                
                var row = $('<tr></tr>');
                $('<td class="related-id"><input type="checkbox" name="'+attributeBase+'_selection['+attributeId+'][]" value="'+this.contentobject_id+'" /><input type="hidden" name="'+attributeBase+'_data_object_relation_list_'+attributeId+'[]" value="'+this.contentobject_id+'" /></td>').appendTo(row);
                var thumbnail = showThumbnail ? '<div style="margin:0 10px;background-image:url('+this.thumbnail_url+');background-size: cover;background-position: center center;width: 50px;height: 50px;display: inline-block;vertical-align: middle;"></div>' : '';
                $('<td class="related-name">'+thumbnail+this.name+' <small>('+this.class_name+')</small></td>').appendTo(row);
                $('<td class="related-section"><small></small></td>').appendTo(row);
                $('<td><input size="2" type="text" name="'+attributeBase+'_priority['+attributeId+'][]" value="'+priority+'" /></td>').appendTo(row);                
                container.find('tr.buttons').before(row);
                if(container.find('.related-id').length > 0){
                    container.find('.ezobject-relationlist-remove-button').show();
                }else{
                    container.find('.ezobject-relationlist-remove-button').hide();
                }
            });
            opendataBrowse.reset();
            self.toggle();
            self.parents('.ezobject-relationlist-container').find('.ezobject-relationlist-add-button').toggle();
        }).on('opendata.browse.close', function (event, opendataBrowse) {
            self.toggle();
            self.parents('.ezobject-relationlist-container').find('.ezobject-relationlist-add-button').toggle();
        }).hide();
    });
    $('.ezobject-relationlist-add-button').on('click', function(e){
        $(this).parents('.ezobject-relationlist-container').find('.ezobject-relationlist-browse').toggle();
        $(this).toggle();
        e.preventDefault();
    });
});  
</script>
{/literal}
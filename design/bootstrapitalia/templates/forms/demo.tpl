<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<head>
    <title>Forms Demo</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    {ezscript(array(
        'ezjsc::jquery',
        'ezjsc::jqueryUI',
        'ezjsc::jqueryio',
        'jquery.search-gui.js',
        'popper.js',
        'owl.carousel.js',
        'moment-with-locales.min.js',
        'chosen.jquery.js',
        'jquery.opendataTools.js',
        'leaflet/leaflet.0.7.2.js',
        'leaflet/Control.Geocoder.js',
        'leaflet/Control.Loading.js',
        'leaflet/Leaflet.MakiMarkers.js',
        'leaflet/leaflet.activearea.js',
        'leaflet/leaflet.markercluster.js',
        'jquery.dataTables.js',
        'dataTables.bootstrap4.min.js',
        'jquery.opendataDataTable.js',
        'jquery.blueimp-gallery.min.js',
        'handlebars.min.js',
        'bootstrap-datetimepicker.min.js',
        'jquery.fileupload.js',
        'jquery.fileupload-ui.js',
        'jquery.fileupload-process.js',
        'jquery.caret.min.js',
        'jquery.tag-editor.js',
        'alpaca.js',
        'jquery.price_format.min.js',
        'jquery.opendatabrowse.js',
        'jstree.min.js',
        'fields/OpenStreetMap.js',
        'fields/RelationBrowse.js',
        'fields/LocationBrowse.js',
        'fields/Tags.js',
        'fields/Ezxml.js',
        'fields/Tree.js',
        ezini('JavascriptSettings', 'IncludeScriptList', 'ocopendata_connectors.ini'),
        'jquery.opendataform.js'
    ))}
    {def $plugin_list = ezini('EditorSettings', 'Plugins', 'ezoe.ini',,true() )
         $ez_locale = ezini( 'RegionalSettings', 'Locale', 'site.ini')
         $language = '-'|concat( $ez_locale )
         $dependency_js_list = array( 'ezoe::i18n::'|concat( $language ) )}
    {foreach $plugin_list as $plugin}
        {set $dependency_js_list = $dependency_js_list|append( concat( 'plugins/', $plugin|trim, '/editor_plugin.js' ))}
    {/foreach}
    <script id="tinymce_script_loader" type="text/javascript" src={"javascript/tiny_mce_jquery.js"|ezdesign} charset="utf-8"></script>
    {ezscript( $dependency_js_list )}

    {ezcss(array(
        'default.css',
        'alpaca.min.css',
        'bootstrap-datetimepicker.min.css',
        'jquery.fileupload.css',
        'jquery.tag-editor.css',
        'alpaca-custom.css',
        'jstree.min.css'
    ))}

</head>
<body class="p-5">

    <div id="modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="clearfix">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    </div>
                    <div id="form" class="clearfix p-4"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <h1>Opendata Forms Demo</h1>

        <p class="lead">Implementazione di <a href="http://www.alpacajs.org/">alpacajs <i class="fa fa-external-link"></i> </a>
            per eZPublish con OpenContentOpendata</p>

        <h2>Demo form</h2>
        <p>Form dimostrativo: non utitlizza nessun valore dinamico e non salva alcun dato. E' l'implemetazione del tutorial di
            <a href="http://www.alpacajs.org/tutorial.html">alpacajs <i class="fa fa-external-link"></i> </a></p>
        <button id="showdemo" class="btn btn-lg btn-success">Open Demo Form</button>
        <div id="staticform"></div>
        <hr/>
        <p>Utilizza la classe <code>\Opencontent\Ocopendata\Forms\Connectors\DemoConnector</code></p>

        <h2>Class form</h2>
        <p>Form di creazione e modifica dinamico per ciascuna classe. <strong>Crea e modifica realmente i dati ez!</strong></p>
        <div class="container">
            <div class="row">
                <div class="col-sm-4">
                    <div class="input-group input-group-lg">
                        <select id="selectclass" class="custom-select input-lg">
                            {def $class_list = fetch(class, list, hash(sort_by, array(name, true())))}
                            {foreach $class_list as $class}
                                <option value="{$class.identifier}">{$class.name|wash()}</option>
                            {/foreach}
                        </select>
                        <div class="input-group-append">
                            <button id="showclass" class="btn btn-lg btn-success">Create</button>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="input-group input-group-lg">
                        <input id="selectobject" type="text" class="custom-select input-lg" placeholder="Object ID" value=""/>
                        <div class="input-group-append">
                            <button id="editobject" class="btn btn-lg btn-success">Edit</button>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="input-group input-group-lg">
                        <input id="selectviewobject" type="text" class="custom-select input-lg" placeholder="Object ID" value=""/>
                        <div class="input-group-append">
                            <button id="viewobject" class="btn btn-lg btn-success">View</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="demo-contents-containers">
                <div class="col-sm-12">
                    <hr/>
                    <p>In questa tabella puoi vedere i contenuti che gengeri in questa sessione di demo</p>
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Class</th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody id="demo-contents">

                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <hr/>
        <p>Utilizza la classe <code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector</code> che richiama l'handler di
            default <code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector</code></p>
        <p>Sono mappati gli attibuti di tipo;</p>
        <table class="table">
            <tr>
                <td>ezselection</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\SelectionField</code></td>
            </tr>
            <tr>
                <td>ezprice</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\PriceField</code></td>
            </tr>
            <tr>
                <td>ezkeyword</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\KeywordsField</code></td>
            </tr>
            <tr>
                <td>eztags</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\TagsField</code></td>
            </tr>
            <tr>
                <td>ezgmaplocation</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\GeoField</code></td>
            </tr>
            <tr>
                <td>ezdate</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\DateField</code></td>
            </tr>
            <tr>
                <td>ezdatetime</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\DateTimeField</code></td>
            </tr>
            <tr>
                <td>eztime</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\TimeField</code></td>
            </tr>
            <tr>
                <td>ezmatrix</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\MatrixField</code></td>
            </tr>
            <tr>
                <td>ezxmltext</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\EzXmlField</code></td>
            </tr>
            <tr>
                <td>ezauthor</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\AuthorField</code></td>
            </tr>
            <tr>
                <td>ezobjectrelation</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RelationField</code></td>
            </tr>
            <tr>
                <td>ezobjectrelationlist</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RelationsField</code></td>
            </tr>
            <tr>
                <td>ezbinaryfile</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\FileField</code></td>
            </tr>
            <tr>
                <td>ezimage</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\ImageField</code></td>
            </tr>
            <tr>
                <td>ezpage</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\PageField</code></td>
            </tr>
            <tr>
                <td>ezboolean</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\BooleanField</code></td>
            </tr>
            <tr>
                <td>ezuser</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\UserField</code></td>
            </tr>
            <tr>
                <td>ezfloat</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\FloatField</code></td>
            </tr>
            <tr>
                <td>ezinteger</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\IntegerField</code></td>
            </tr>
            <tr>
                <td>ezstring</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\StringField</code></td>
            </tr>
            <tr>
                <td>ezsrrating</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RatingField</code></td>
            </tr>
            <tr>
                <td>ezemail</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\EmailField</code></td>
            </tr>
            <tr>
                <td>ezcountry</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\CountryField</code></td>
            </tr>
            <tr>
                <td>ezurl</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\UrlField</code></td>
            </tr>
            <tr>
                <td>eztext</td>
                <td><code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\TextField</code></td>
            </tr>
        </table>


        <h2>Browse demo</h2>
        <p>Plugin jQuery per il content browse dinamico <code>jquery.opendatabrowse.js</code></p>
        <button id="showdemobrowse" class="btn btn-lg btn-success">Show/Hide</button>
        <div id="browse"></div>
    </div>

    {literal}
    <script type="text/javascript">
    $(document).ready(function () {

        $.opendataFormSetup({
            onBeforeCreate: function(){
                $('#modal').modal('show')
            },
            onSuccess: function(data){
                $('#modal').modal('hide');
            },
            i18n: {{/literal}
                'store': "{'Store'|i18n('opendata_forms')}",
                'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
                'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
                'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"

            {literal}}
        });

        $('#demo-contents-containers').hide();

        var classSelect = $('#selectclass');

        var showDemoForm = function () {
            $('#modal').modal('show');
            $("#form").alpaca('destroy').alpaca({
                "connector":{
                    "id": "opendataform",
                    "config": {
                        "connector": 'demo',
                        "params": {}
                    }
                }
            });
        };

        var appendNewData = function(data){
            $('#demo-contents-containers').show();
            var language = 'ita-IT';
            var newRow = $('<tr id="object-'+data.content.metadata.id+'"></tr>');
            newRow.append($('<td>'+data.content.metadata.id+'</td>'));
            newRow.append($('<td><a href="">'+data.content.metadata.name[language]+'</a></td>'));
            newRow.append($('<td><a href="">'+data.content.metadata.classIdentifier+'</a></td>'));
            var buttonCell = $('<td width="1" style="white-space:nowrap"></td>');
            $('<button class="btn btn-warning" data-object="'+data.content.metadata.id+'"><i class="fa fa-edit"></i></button>')
                .bind('click', function(e){
                    $('#form').opendataFormEdit({object: $(this).data('object')});
                    e.preventDefault();
                }).appendTo(buttonCell);
            $('<button class="btn btn-success" data-object="'+data.content.metadata.id+'"><i class="fa fa-eye"></i></button>')
                .bind('click', function(e){
                    $('#form').opendataFormView({object: $(this).data('object')});
                    e.preventDefault();
                }).appendTo(buttonCell);
            $('<button class="btn btn-danger" data-object="'+data.content.metadata.id+'"><i class="fa fa-trash"></i></button>')
                .bind('click', function(e){
                    var object = $(this).data('object')
                    $('#form').opendataFormDelete({object: object},{
                        onSuccess: function(data){
                            $('#demo-contents-containers').find('#object-'+object).remove();
                            $('#modal').modal('hide');
                        }
                    });
                    e.preventDefault();
                }).appendTo(buttonCell);
            $('<button class="btn btn-info" data-node="'+data.content.metadata.mainNodeId+'"><i class="fa fa-code-fork"></i></button>')
                .bind('click', function(e){
                    var node = $(this).data('node')
                    $('#form').opendataFormManageLocation({source: node});
                    e.preventDefault();
                }).appendTo(buttonCell);    
            buttonCell.appendTo(newRow);
            $('#demo-contents').append(newRow);
        }

        $('#showclass').on('click', function (e) {
            $('#form').opendataFormCreate({class: classSelect.val()}, {
                onSuccess: function(data){
                    appendNewData(data);
                    $('#modal').modal('hide');
                }
            });

            e.preventDefault();
        });

        $('#showdemo').on('click', function (e) {
            showDemoForm();
            e.preventDefault();
        });

        $('#editobject').on('click', function (e) {
            $('#form').opendataFormEdit({object: $('#selectobject').val()});
            e.preventDefault();
        });

        $('#viewobject').on('click', function (e) {
            $('#form').opendataFormView({object: $('#selectviewobject').val()});
            e.preventDefault();
        });

        $('#browse').opendataBrowse({
            'subtree': 43,
            'addCloseButton': true,
            'addCreateButton': true,
            'classes': ['folder','image'],
            'i18n':{{/literal}
                clickToClose: "{'Click to close'|i18n('opendata_forms')}",
                clickToOpenSearch: "{'Click to open search engine'|i18n('opendata_forms')}",
                search: "{'Search'|i18n('opendata_forms')}",
                clickToBrowse: "{'Click to browse contents'|i18n('opendata_forms')}",
                browse: "{'Browse'|i18n('opendata_forms')}",
                createNew: "{'Create new'|i18n('opendata_forms')}",
                create: "{'Create'|i18n('opendata_forms')}",
                allContents: "{'All contents'|i18n('opendata_forms')}",
                clickToBrowseParent: "{'Click to view parent'|i18n('opendata_forms')}",
                noContents: "{'No contents'|i18n('opendata_forms')}",
                back: "{'Back'|i18n('opendata_forms')}",
                goToPreviousPage: "{'Go to previous'|i18n('opendata_forms')}",
                goToNextPage: "{'Go to next'|i18n('opendata_forms')}",
                clickToBrowseChildren: "{'Click to view children'|i18n('opendata_forms')}",
                clickToPreview: "{'Click to preview'|i18n('opendata_forms')}",
                preview: "{'Preview'|i18n('opendata_forms')}",
                closePreview: "{'Close preview'|i18n('opendata_forms')}",
                addItem: "{'Add'|i18n('opendata_forms')}",
                selectedItems: "{'Selected items'|i18n('opendata_forms')}",
                removeFromSelection: "{'Remove from selection'|i18n('opendata_forms')}",
                addToSelection: "{'Add to selection'|i18n('opendata_forms')}",
                store: "{'Store'|i18n('opendata_forms')}",
                storeLoading: "{'Loading...'|i18n('opendata_forms')}"
            {literal}}
        }).on('opendata.browse.select', function (event, opendataBrowse) {
            alert(JSON.stringify(opendataBrowse.selection));
        }).on('opendata.browse.close', function (event, opendataBrowse) {
            $('#browse').toggle();
        }).hide();

        $('#showdemobrowse').on('click', function (e) {
            $('#browse').toggle();
        });


    });
    </script>
    {/literal}

    <script>window.__PUBLIC_PATH__ = "{'fonts'|ezdesign(no)}"</script>
    <script src="{'javascript/app.min.js'|ezdesign(no)}"></script>

{* This comment will be replaced with actual debug report (if debug is on). *}
<!--DEBUG_REPORT-->
</body>
</html>

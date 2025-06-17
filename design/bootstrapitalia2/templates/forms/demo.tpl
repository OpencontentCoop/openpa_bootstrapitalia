{def $theme = current_theme()
     $avail_translation = array()}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
    <title>Forms Demo</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    {include uri='design:page_head_style.tpl'}
    {include uri='design:page_head_script.tpl'}
    {def $footer_css_loader = ezcss_load(array('common.css'))}
</head>
<body>
{include uri='design:load_ocopendata_forms.tpl'}

<div id="modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg" style="padding: 15px">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div id="form" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>

<div class="container my-5">
    <div class="row">
        <div class="col">
            <h1>Opendata Forms Demo</h1>

            <p class="lead">Implementazione di form asincroni con <a href="http://www.alpacajs.org/" target="_blank">alpacajs <i aria-hidden="true" class="fa fa-external-link"></i> </a> per la creazione di contenuti</p>

            <div class="d-none">
                <h2>Demo form</h2>
                <p>Form dimostrativo: non utitlizza nessun valore dinamico e non salva alcun dato. E' l'implemetazione del tutorial di
                    <a href="http://www.alpacajs.org/tutorial.html">alpacajs <i aria-hidden="true" class="fa fa-external-link"></i> </a></p>
                <button id="showdemo" class="btn btn-lg btn-success">Open Demo Form</button>
                <div id="staticform"></div>
                <hr/>
                <p>Utilizza la classe <code>\Opencontent\Ocopendata\Forms\Connectors\DemoConnector</code></p>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col">
            <p class="lead">Form di creazione e modifica dinamico per ciascuna classe di contenuto. <strong>Attenzione: crea e modifica i dati nel sistema</strong></p>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-4">
            <div class="form-group">
                <div class="input-group">
                    <select id="selectclass" class="form-control">
                        {def $class_list = fetch(class, list, hash(sort_by, array(name, true())))}
                        {foreach $class_list as $class}
                            <option value="{$class.identifier}">{$class.name|wash()}</option>
                        {/foreach}
                    </select>
                    <div class="input-group-append">
                        <button id="showclass" class="btn btn-lg btn-success">Crea</button>
                    </div>
                </div>
                <div class="row">
                    <div class="col">
                        <div class="toggles">
                            <label for="useEssential">
                                <input type="checkbox" id="useEssential" />
                                <span class="lever" style="margin: 0;display: inline-block;float:none"></span>
                                Solo campi obbligatori
                            </label>
                        </div>
                    </div>
                    <div class="col">
                        <p class="text-end mt-1">
                            <a id="debugclass" href="#"><small style="font-size:.8em">Debug connettori <i aria-hidden="true" class="fa fa-external-link"></i></small></a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="form-group">
                <div class="input-group">
                    <input id="selectobject" type="text" class="form-control" placeholder="Object ID" value=""/>
                    <div class="input-group-append">
                        <button id="editobject" class="btn btn-lg btn-success">Modifica</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="form-group">
                <div class="input-group">
                    <input id="selectviewobject" type="text" class="form-control" placeholder="Object ID" value=""/>
                    <div class="input-group-append">
                        <button id="viewobject" class="btn btn-lg btn-success">Visualizza</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="demo-contents-containers">
        <div class="col-sm-12">
            <hr/>
            <p>In questa tabella puoi vedere i contenuti che generi in questa sessione di demo</p>
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


    <div class="row">
        <div class="col">
            <h4><code>jquery.opendatabrowse.js</code> demo</h4>
            <p class="lead">Plugin jQuery per la navigazione asincrona dei contenuti</p>
            <button id="showdemobrowse" class="btn btn-lg btn-success">Mostra/Nascondi browser dei contenuti</button>
            <div id="browse" class="relationbrowse-container"></div>
<pre class="my-5">
$('#browse').opendataBrowse({ldelim}

  'subtree': 43,
  'addCloseButton': true,
  'addCreateButton': true,
  'classes': ['folder', 'image']
  {rdelim}).on('opendata.browse.select', function (event, opendataBrowse) {ldelim}

    alert(JSON.stringify(opendataBrowse.selection));

{rdelim})
</pre>
        </div>
    </div>

    <div class="cmp-accordion mt-5">
        <div class="accordion-item">
            <h2 class="accordion-header" id="heading-settings">
                <button class="accordion-button collapsed" type="button"
                        data-bs-toggle="collapse" data-bs-target="#collapse-settings" aria-expanded="false" aria-controls="collapse-settings">
                    Connettori di form configurati
                </button>
            </h2>
            <div id="collapse-settings" class="accordion-collapse collapse" role="region" aria-labelledby="heading-settings">
                <div class="accordion-body">
                    <p>Utilizza la classe <code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector</code> che richiama l'handler di
                        default <code>\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector</code></p>
                    <p>Sono mappati gli attibuti di tipo;</p>
                    <table class="table">
                        {foreach $connector_by_datatype as $datatype => $class}
                            <tr>
                                <td>{$datatype|wash()}</td>
                                <td><code>{$class|wash()}</code></td>
                            </tr>
                        {/foreach}
                    </table>
                </div>
            </div>
        </div>
    </div>

</div>

{literal}
<script type="text/javascript">
  $(document).ready(function () {

    var form = $('#relation-form');
    var modalContainer = $('#relation-modal');
    modalContainer.find('.modal-dialog').addClass('p-5')
    var defaultOptions = {
      onBeforeCreate: function () {
        modalContainer.modal('show')
      },
      onSuccess: function (data) {
        modalContainer.modal('hide');
      },
      i18n: {
        'store': "{/literal}{'Store'|i18n('opendata_forms')}{literal}",
        'storeLoading': "{/literal}{'Loading...'|i18n('opendata_forms')}{literal}",
        'cancelDelete': "{/literal}{'Cancel deletion'|i18n('opendata_forms')}{literal}",
        'confirmDelete': "{/literal}{'Confirm deletion'|i18n('opendata_forms')}{literal}"
      }
    };

    $.opendataFormSetup(defaultOptions);

    $('#demo-contents-containers').hide();

    var classSelect = $('#selectclass');

    var showDemoForm = function () {
      modalContainer.modal('show');
      form.alpaca('destroy').alpaca({
        "connector": {
          "id": "opendataform",
          "config": {
            "connector": 'demo',
            "params": {}
          }
        }
      },defaultOptions);
    };

    var appendNewData = function (data) {
      $('#demo-contents-containers').show();
      var language = 'ita-IT';
      var newRow = $('<tr id="object-' + data.content.metadata.id + '"></tr>');
      newRow.append($('<td>' + data.content.metadata.id + '</td>'));
      newRow.append($('<td><a href="">' + data.content.metadata.name[language] + '</a></td>'));
      newRow.append($('<td><a href="">' + data.content.metadata.classIdentifier + '</a></td>'));
      var buttonCell = $('<td width="1" style="white-space:nowrap"></td>');
      $('<button class="me-2 btn btn-xs btn-warning" data-object="' + data.content.metadata.id + '"><i aria-hidden="true" class="fa fa-edit"></i></button>')
        .bind('click', function (e) {
          form.opendataFormEdit({object: $(this).data('object')});
          e.preventDefault();
        }).appendTo(buttonCell);
      $('<button class="me-2 btn btn-xs btn-success" data-object="' + data.content.metadata.id + '"><i aria-hidden="true" class="fa fa-eye"></i></button>')
        .bind('click', function (e) {
          form.opendataFormView({object: $(this).data('object')});
          e.preventDefault();
        }).appendTo(buttonCell);
      $('<button class="me-2 btn btn-xs btn-danger" data-object="' + data.content.metadata.id + '"><i aria-hidden="true" class="fa fa-trash"></i></button>')
        .bind('click', function (e) {
          var object = $(this).data('object')
          form.opendataFormDelete({object: object}, {
            onSuccess: function (data) {
              $('#demo-contents-containers').find('#object-' + object).remove();
              modalContainer.modal('hide');
            }
          });
          e.preventDefault();
        }).appendTo(buttonCell);
      $('<button class="me-2 btn btn-xs btn-info" data-node="' + data.content.metadata.mainNodeId + '"><i aria-hidden="true" class="fa fa-code-fork"></i></button>')
        .bind('click', function (e) {
          var node = $(this).data('node')
          form.opendataFormManageLocation({source: node});
          e.preventDefault();
        }).appendTo(buttonCell);
      buttonCell.appendTo(newRow);
      $('#demo-contents').append(newRow);
    }

    $('#showclass').on('click', function (e) {
      if ($('#useEssential').is(':checked')) {
        defaultOptions.connector = 'essential'
      }
      form.opendataFormCreate({class: classSelect.val()}, $.extend({}, defaultOptions, {
        onSuccess: function (data) {
          appendNewData(data);
          modalContainer.modal('hide');
        }
      }));
      e.preventDefault();
    });

    $('#showdemo').on('click', function (e) {
      showDemoForm();
      e.preventDefault();
    });

    $('#editobject').on('click', function (e) {
      form.opendataFormEdit(
        {object: $('#selectobject').val()},
        defaultOptions
      );
      e.preventDefault();
    });

    $('#viewobject').on('click', function (e) {
      form.opendataFormView(
        {object: $('#selectviewobject').val()},
        defaultOptions
      );
      e.preventDefault();
    });

    $('#debugclass').on('click', function (e) {
      open('/forms/connector/default/debug?class='+classSelect.val(), '_blank')
      e.preventDefault();
    });

    $('#browse').opendataBrowse({
      'subtree': 43,
      'addCloseButton': true,
      'addCreateButton': true,
      'classes': ['folder', 'image', 'link', 'banner', 'document'],
      'i18n': {
        clickToClose: "{/literal}{'Click to close'|i18n('opendata_forms')}{literal}",
        clickToOpenSearch: "{/literal}{'Click to open search engine'|i18n('opendata_forms')}{literal}",
        search: "{/literal}{'Search'|i18n('opendata_forms')}{literal}",
        clickToBrowse: "{/literal}{'Click to browse contents'|i18n('opendata_forms')}{literal}",
        browse: "{/literal}{'Browse'|i18n('opendata_forms')}{literal}",
        createNew: "{/literal}{'Create new'|i18n('opendata_forms')}{literal}",
        create: "{/literal}{'Create'|i18n('opendata_forms')}{literal}",
        allContents: "{/literal}{'All contents'|i18n('opendata_forms')}{literal}",
        clickToBrowseParent: "{/literal}{'Click to view parent'|i18n('opendata_forms')}{literal}",
        noContents: "{/literal}{'No contents'|i18n('opendata_forms')}{literal}",
        back: "{/literal}{'Back'|i18n('opendata_forms')}{literal}",
        goToPreviousPage: "{/literal}{'Go to previous'|i18n('opendata_forms')}{literal}",
        goToNextPage: "{/literal}{'Go to next'|i18n('opendata_forms')}{literal}",
        clickToBrowseChildren: "{/literal}{'Click to view children'|i18n('opendata_forms')}{literal}",
        clickToPreview: "{/literal}{'Click to preview'|i18n('opendata_forms')}{literal}",
        preview: "{/literal}{'Preview'|i18n('opendata_forms')}{literal}",
        closePreview: "{/literal}{'Close preview'|i18n('opendata_forms')}{literal}",
        addItem: "{/literal}{'Add'|i18n('opendata_forms')}{literal}",
        selectedItems: "{/literal}{'Selected items'|i18n('opendata_forms')}{literal}",
        removeFromSelection: "{/literal}{'Remove from selection'|i18n('opendata_forms')}{literal}",
        addToSelection: "{/literal}{'Add to selection'|i18n('opendata_forms')}{literal}",
        store: "{/literal}{'Store'|i18n('opendata_forms')}{literal}",
        storeLoading: "{/literal}{'Loading...'|i18n('opendata_forms')}{literal}"
      }
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

{include uri='design:page_footer_script.tpl'}

{* This comment will be replaced with actual debug report (if debug is on). *}
<!--DEBUG_REPORT-->

</body>
</html>

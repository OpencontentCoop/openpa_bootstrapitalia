{def $states = object_handler(fetch('openpa', 'homepage')).albo_on_line.states}
{def $class_identifiers = array(
	'deliberazione',
	'determinazione',
	'bando',
	'concorso',
	'avviso',
    'decreto'
)}
{def $current_year = currentdate()|datetime( 'custom', '%Y' )}
{def $classes = fetch(class, list, hash('class_filter', $class_identifiers))}
{def $first_year = api_search(concat('classes [', $class_identifiers|implode(','), '] sort [anno=>asc] limit 1')).searchHits[0].data['ita-IT'].anno}
{if $first_year}
    {if or($first_year|eq(null()), $first_year|lt(2007))}
        {set $first_year = $current_year|sub(10)}
    {elseif is_array($first_year)}
        {set $first_year = $first_year[0]}
        {if $first_year|eq('')}
            {set $first_year = $current_year|sub(10)}
        {/if}
    {/if}
{else}
    {set $first_year = $current_year|sub(10)}
{/if}

<h2 class="u-text-h2">Cruscotto Albo On Line</h2>


<div class="facet-navigation row mb-3">
    <div class="col-2">
    <small>FILTRA PER STATO</small>
    </div>
    <div class="col-10">
    {foreach $states as $state}
		<a class="button"
		   data-field="state"
		   data-operator="in"
		   data-value='["{$state.id}"]'
		   href="#"
		   style="margin: 3px">
			{$state.current_translation.name|wash()}
		</a>
	{/foreach}
    </div>
</div>

<div class="facet-navigation row mb-3">
    <div class="col-2">
    <small>FILTRA PER TIPO</small>
    </div>
    <div class="col-10">
    {foreach $classes as $class}
		<a class="button"
		   data-field="class"
		   data-operator="in"
		   data-value='["{$class.identifier}"]'
		   href="#"
		   style="margin: 3px">
			{$class.name|wash()}
		</a>
	{/foreach}
    </div>
</div>

<div class="facet-navigation row mb-3">
    <div class="col-2">
    <small>FILTRA PER ANNO</small>
    </div>
    <div class="col-10">
    {for $first_year to $current_year as $year}
		<a class="button"
		   data-field="anno"
		   data-operator="in"
		   data-value='["{$year}"]'
		   href="#"
		   style="margin: 3px">
			{$year|wash()}
		</a>
	{/for}
    </div>
</div>

<div class="table-container my-3"></div>

<div id="albboonline-preview" class="modal fade" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div id="albboonline-content" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>


{ezscript_require(array(
    'jquery.dataTables.js',
    'jquery.opendataTools.js',
    'jquery.opendataDataTable.js',
    'dataTables.bootstrap.js',
    'moment-with-locales.min.js',
    'moment-timezone-with-data.js',
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

{ezcss_require(array(
    'alpaca.min.css',
    'bootstrap-datetimepicker.min.css',
    'jquery.fileupload.css',
    'jquery.tag-editor.css',
    'alpaca-custom.css',
    'jstree.min.css'
))}

<script type="text/javascript" language="javascript">
var AlboClasses = [{foreach $classes as $class}{ldelim}"id":"{$class.id}", "identifier":"{$class.identifier}", "name":"{$class.name|wash(javascript)}"{rdelim}{delimiter},{/delimiter}{/foreach}];
var AlboStates = [{foreach $states as $state}{ldelim}"id":"{$state.id}", "identifier":"{$state.identifier}", "name":"{$state.current_translation.name|wash(javascript)}"{rdelim}{delimiter},{/delimiter}{/foreach}];
{literal}
$(document).ready(function () {

  moment.locale('it');
  var array_column = function (array, columnName) {
    return array.map(function (value, index) {
      return value[columnName];
    })
  };
  var tableContainer = $('.table-container');
  var dataTable = tableContainer.opendataDataTable({
    "builder": {
      "query": 'classes [' + array_column(AlboClasses, 'identifier').join(',') + '] sort [anno=>desc,progressivo_albo=>desc,published=>desc]'
    },
    "table": {
      "template": '<table class="table table-sm"></table>',
    },
    "datatable": {
      "pageLength": 50,
      "responsive": false,
      "order": [[0, 'desc'], [1, 'desc']],
      "ajax": {
        url: "{/literal}{'opendata/api/datatable/search'|ezurl(no)}{literal}/"
      },
      "language": {
        "decimal": "",
        "emptyTable": "Non sono attualmente presenti atti in questa sezione",
        "info": "Vista da _START_ a _END_ di _TOTAL_ elementi",
        "infoEmpty": "",
        "infoFiltered": "(filtrati da _MAX_ elementi totali)",
        "infoPostFix": "",
        "thousands": ",",
        "lengthMenu": "Visualizza _MENU_ elementi",
        "loadingRecords": "Caricamento...",
        "processing": "Elaborazione...",
        "search": "Cerca:",
        "zeroRecords": "La ricerca non ha portato alcun risultato",
        "paginate": {
          "first": "Inizio",
          "last": "Fine",
          "next": "Successivo",
          "previous": "Precedente"
        },
        "aria": {
          "sortAscending": ": attiva per ordinare la colonna in ordine crescente",
          "sortDescending": ": attiva per ordinare la colonna in ordine decrescente"
        }
      },
      "columns": [
        /* 0 */{"data": "data['ita-IT'].anno", "name": 'anno', "title": 'Anno'},
        /* 1 */{"data": "data['ita-IT'].progressivo_albo", "name": 'progressivo_albo', "title": 'Progressivo'},
        /* 2 */{"data": "metadata.classIdentifier", "name": 'class', "title": 'Tipo'},
        /* 3 */{"data": "metadata.name.ita-IT", "name": 'name', "title": 'Titolo'},
        /* 4 */{"data": "metadata.published", "name": 'published', "title": 'Inserimento'},
        /* 5 */{"data": "metadata.modified", "name": 'modified', "title": 'Ultima modifica'},
        /* 6 */{"data": "metadata.stateIdentifiers", "name": 'state', "title": 'Stato', "orderable": false},
        /* 7 */{"data": "metadata.id", "name": 'id', "title": '', "orderable": false}
      ],
      "columnDefs": [
        {
          "render": function (data, type, row, meta) {
            return row.data['ita-IT'].anno;
          },
          "targets": [0]
        },
        {
          "render": function (data, type, row, meta) {
            data = row.data['ita-IT'].progressivo_albo;
            return data !== 0 ? data : '';
          },
          "targets": [1]
        },
        {
          "render": function (data, type, row, meta) {
            var classes = $.grep(AlboClasses, function (e) {
              return e.identifier === data;
            });
            var value = classes.length > 0 ? classes[0].name : data;
            return '<small style="white-space:nowrap">' + value + '</small>';
          },
          "targets": [2]
        },
        {
          "render": function (data, type, row, meta) {
            var validDate = moment(data);
            if (validDate.isValid()) {
              return '<span style="white-space:nowrap">' + validDate.format("D MMMM YYYY") + '</span>';
            }
            return '';
          },
          "targets": [4, 5]
        },
        {
          "render": function (data, type, row, meta) {
            var prefix = 'albo_on_line.';
            var state;
            $.each(data, function () {
              if (this.startsWith(prefix)) {
                state = this;
              }
            });
            var states = $.grep(AlboStates, function (e) {
              return prefix + e.identifier === state;
            });
            var value = states.length > 0 ? states[0].name : state ? state.replace(prefix, '') : '';
            return '<small style="white-space:nowrap">' + value + '</small>';
          },
          "targets": [6]
        },
        {
          "render": function (data, type, row, meta) {
            return '<div style="white-space:nowrap">' +
              '<a href="#" data-view="' + row.metadata.id + '"' +
              '<span class="fa-stack"><i class="fa fa-square fa-stack-2x"></i><i class="fa fa-eye fa-stack-1x fa-inverse"></i></span>' +
              '<a>' +
              '<a href="#" data-edit="' + row.metadata.id + '" class="edit-object">' +
              '<span class="fa-stack text-warning"><i class="fa fa-square fa-stack-2x"></i><i class="fa fa-pencil fa-stack-1x fa-inverse"></i></span>' +
              '</a>' +
              '</div>';
          },
          "targets": [7]
        }
      ]
    }
  }).on( 'draw.dt', function ( e, datatableSettings, json ) {

    tableContainer.find("[data-edit]").on('click', function (e) {
      var object = $(this).data('edit');
      $('#albboonline-content').opendataFormEdit({
        'object': object
      }, {
        onBeforeCreate: function () {
          $('#albboonline-preview').modal('show');
        },
        onSuccess: function () {
          $('#albboonline-preview').modal('hide');
          dataTable.datatable.ajax.reload(null, false);
        }
      });
      e.preventDefault();
    });
    tableContainer.find("[data-view]").on('click', function (e) {
      var object = $(this).data('view');
      $('#albboonline-content').opendataFormView({
        'object': object
      }, {
        onBeforeCreate: function () {
          $('#albboonline-preview').modal('show');
        },
        onSuccess: function () {
          $('#albboonline-preview').modal('hide');
        }
      });
      e.preventDefault();
    });

  }).data('opendataDataTable');

  var setCurrentFilters = function () {
    $('.facet-navigation').each(function () {
      var currentFilterName = $(this).find('.defaultbutton').data('field');
      var currentFilterOperator = $(this).find('.defaultbutton').data('operator');
      var currentFilterValue = $(this).find('.defaultbutton').data('value');
      dataTable.settings.builder.filters[currentFilterName] = {
        'field': currentFilterName,
        'operator': currentFilterOperator,
        'value': currentFilterValue
      };
    });
  };
  setCurrentFilters();

  $('.facet-navigation .defaultbutton').on('click', function (e) {
    e.preventDefault();
  });
  $('.facet-navigation .button').on('click', function (e) {
    if ($(this).hasClass('defaultbutton')) {
      $(this).removeClass('defaultbutton');
      var currentFilterName = $(this).data('field');
      dataTable.settings.builder.filters[currentFilterName] = null;
    } else {
      $(this).parent().find('.defaultbutton').removeClass('defaultbutton');
      $(this).addClass('defaultbutton');
      setCurrentFilters();
    }
    dataTable.loadDataTable();
    e.preventDefault();
  });

  dataTable.loadDataTable();
});
</script>
<style type="text/css">
.defaultbutton{background: #f00;}
.dataTables_wrapper .dataTables_length select{padding: 0}
.dataTables_wrapper .pagination .disabled{display: none !important;}
</style>
{/literal}


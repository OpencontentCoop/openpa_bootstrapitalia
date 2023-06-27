{ezscript_require(array(
	'jquery.dataTables.js',
	'jquery.opendataTools.js',
	'jquery.opendataDataTable.js',
	'dataTables.bootstrap.js',
	'dataTables.responsive.min.js',
	'moment-with-locales.min.js',
	'moment-timezone-with-data.js',
	'bootstrap/modal.js',
	'bootstrap/tooltip.js',
	'bootstrap/popover.js',
	'bootstrap-editable.min.js'
))}
{ezcss_require(array(
	'dataTables.bootstrap.css',
	'responsive.dataTables.min.css',
	'bootstrap3-editable/css/bootstrap-editable.css'
))}

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

<small>FILTRA PER STATO</small>
<div class="facet-navigation" style="margin-bottom: 10px">
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

<small>FILTRA PER TIPO</small>
<div class="facet-navigation" style="margin-bottom: 10px">
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

<small>FILTRA PER ANNO</small>
<div class="facet-navigation" style="margin-bottom: 10px">
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

<div class="table-container" style="margin: 20px 0"></div>

<div id="albboonline-preview" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	    </div>
        <div class="modal-content"></div>
    </div>
</div>

<script type="text/javascript" language="javascript">
var AlboClasses = [{foreach $classes as $class}{ldelim}"id":"{$class.id}", "identifier":"{$class.identifier}", "name":"{$class.name|wash(javascript)}"{rdelim}{delimiter},{/delimiter}{/foreach}];
var AlboStates = [{foreach $states as $state}{ldelim}"id":"{$state.id}", "identifier":"{$state.identifier}", "name":"{$state.current_translation.name|wash(javascript)}"{rdelim}{delimiter},{/delimiter}{/foreach}];
{literal}
$(document).ready(function () {

    moment.locale('it');
    var array_column = function(array, columnName) {
	    return array.map(function(value,index) {
	        return value[columnName];
	    })
	};

    var dataTable = $('.table-container').opendataDataTable({
        "builder":{
          "query": 'classes ['+array_column(AlboClasses, 'identifier').join(',')+'] sort [anno=>desc,progressivo_albo=>desc,published=>desc]'
        },
        "datatable":{
            "pageLength": 50,
            "responsive": false,
            "order": [[ 0, 'desc' ],[ 1, 'desc' ]],
            "ajax": {
                url: "{/literal}{'opendata/api/datatable/search'|ezurl(no)}{literal}/"
            },
            "language":{
				"decimal":        "",
				"emptyTable":     "Non sono attualmente presenti atti in questa sezione",
				"info":           "Vista da _START_ a _END_ di _TOTAL_ elementi",
				"infoEmpty":      "",
				"infoFiltered":   "(filtrati da _MAX_ elementi totali)",
				"infoPostFix":    "",
				"thousands":      ",",
				"lengthMenu":     "Visualizza _MENU_ elementi",
				"loadingRecords": "Caricamento...",
				"processing":     "Elaborazione...",
				"search":         "Cerca:",
				"zeroRecords":    "La ricerca non ha portato alcun risultato",
				"paginate": {
					"first":      "Inizio",
					"last":       "Fine",
					"next":       "Successivo",
					"previous":   "Precedente"
				},
				"aria": {
					"sortAscending":  ": attiva per ordinare la colonna in ordine crescente",
					"sortDescending": ": attiva per ordinare la colonna in ordine decrescente"
				}
			},
            "columns": [
                /* 0 */{"data": "data['ita-IT'].anno", "name": 'anno', "title": 'Anno'},
                /* 1 */{"data": "data['ita-IT'].progressivo_albo", "name": 'progressivo_albo', "title": 'Progressivo'},
                /* 2 */{"data": "metadata.classIdentifier","name": 'class',"title": 'Tipo'},
                /* 3 */{"data": "metadata.name.ita-IT", "name": 'name', "title": 'Titolo'},
                /* 4 */{"data": "metadata.published", "name": 'published', "title": 'Inserimento'},
                /* 5 */{"data": "metadata.modified", "name": 'modified', "title": 'Ultima modifica'},
                /* 6 */{"data": "metadata.stateIdentifiers", "name": 'state', "title": 'Stato', "orderable": false},
                /* 7 */{"data": "metadata.id", "name": 'id', "title": '', "orderable": false}
            ],
            "columnDefs": [
            	{
            		"render": function ( data, type, row, meta ) {
            			return row.data['ita-IT'].anno;
            		},
            		"targets": [0]
            	},
            	{
            		"render": function ( data, type, row, meta ) {
            			var data = row.data['ita-IT'].progressivo_albo;
            			var value = data != 0 ? data : '';
            			return value
            		},
            		"targets": [1]
            	},
            	{
            		"render": function ( data, type, row, meta ) {
            			var classes = $.grep(AlboClasses, function(e){ return e.identifier == data; });
            			var value = classes.length > 0 ? classes[0].name : data;
            			return '<small style="white-space:nowrap">'+value+'</small>';
            		},
            		"targets": [2]
            	},
            	{
            		"render": function ( data, type, row, meta ) {
            			var validDate = moment(data);
			            if (validDate.isValid()) {
		                    return '<span style="white-space:nowrap">' + validDate.format("D MMMM YYYY") + '</span>';
			            }
			            return '';
            		},
            		"targets": [4,5]
            	},
            	{
            		"render": function ( data, type, row, meta ) {
            			var prefix = 'albo_on_line.';
            			var state;
            			$.each(data, function(){
            				if(this.startsWith(prefix)){
            					state = this;
            				}
            			});
            			var states = $.grep(AlboStates, function(e){ return prefix+e.identifier == state; });
            			var value = states.length > 0 ? states[0].name : state ? state.replace(prefix, '') : '';
            			return '<small style="white-space:nowrap">'+value+'</small>';
            		},
            		"targets": [6]
            	},
            	{
            		"render": function ( data, type, row, meta ) {
            			return '<div style="white-space:nowrap"><a href="/content/view/full/'+row.metadata.mainNodeId+'"><span class="fa-stack fa-lg"><i class="fa fa-square fa-stack-2x"></i><i class="fa fa-eye fa-stack-1x fa-inverse"></i></span><a><a href="/content/edit/'+row.metadata.id+'/f" class="edit-object"><span class="fa-stack fa-lg text-warning"><i class="fa fa-square fa-stack-2x"></i><i class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a></div>';
            		},
            		"targets": [7]
            	}
            ]
        }
    }).on('xhr.dt', function ( e, datatableSettings, json, xhr ) {

	}).data('opendataDataTable');

	var setCurrentFilters = function(){
	  	$('.facet-navigation').each(function(){
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

	$('.facet-navigation .defaultbutton').on('click', function(e){
    	e.preventDefault();
    });
	$('.facet-navigation .button').on('click', function(e){
		if ($(this).hasClass('defaultbutton')){
			$(this).removeClass('defaultbutton');
			var currentFilterName = $(this).data('field');
			dataTable.settings.builder.filters[currentFilterName] = null;
		}else{
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
#albboonline-preview .content-container .extra, #albboonline-preview .Button, #albboonline-preview #editor_tools{display: none !important;}
#albboonline-preview .content-container .withExtra{width: 100% !important;}
[role="button"] {cursor: pointer;}
.modal-open {overflow: hidden;}
.modal {display: none;overflow: hidden;position: fixed;top: 0;right: 0;bottom: 0;left: 0;z-index: 1050;-webkit-overflow-scrolling: touch;outline: 0;}
.modal.fade .modal-dialog {-webkit-transform: translate(0, -25%);-ms-transform: translate(0, -25%);-o-transform: translate(0, -25%);transform: translate(0, -25%);-webkit-transition: -webkit-transform 0.3s ease-out;-o-transition: -o-transform 0.3s ease-out;transition: transform 0.3s ease-out;}
.modal.in .modal-dialog {-webkit-transform: translate(0, 0);-ms-transform: translate(0, 0);-o-transform: translate(0, 0);transform: translate(0, 0);}
.modal-open .modal { overflow-x: hidden;overflow-y: auto;}
.modal-dialog {position: relative;width: auto;margin: 10px;background-color: #ffffff;padding:10px;}
.modal-content {position: relative;      outline: 0;  }
.modal-backdrop {position: fixed;top: 0;right: 0;bottom: 0;left: 0;z-index: 1040;background-color: #000000;}
.modal-backdrop.fade {opacity: 0;filter: alpha(opacity=0);}
.modal-backdrop.in {opacity: 0.5;filter: alpha(opacity=50);}
.modal-header {padding: 0 15px;  min-height: 16.42857143px;  }
.modal-title {margin: 0;line-height: 1.42857143;}
.modal-body {position: relative;padding: 15px;}
.modal-scrollbar-measure {position: absolute;top: -9999px;width: 50px;height: 50px;overflow: scroll;}
.close {float: right;font-size: 35px;font-weight: bold;line-height: 1;color: #000;text-shadow: 0 1px 0 #fff;filter: alpha(opacity=20);opacity: .2;}
button.close {-webkit-appearance: none;padding: 0;cursor: pointer;background: transparent;border: 0;}
.close:hover, .close:focus {color: #000;text-decoration: none;cursor: pointer;filter: alpha(opacity=50);opacity: .5;}
@media (min-width: 768px) {.modal-dialog {width: 600px;margin: 30px auto;}  .modal-sm {width: 300px;}}
@media (min-width: 992px) {.modal-lg {width: 900px;}}
.text-success { color: #3c763d; }
a.text-success:hover { color: #2b542c; }
.text-info { color: #31708f; }
a.text-info:hover { color: #245269; }
.text-warning { color: #8a6d3b; }
a.text-warning:hover { color: #66512c; }
.text-danger { color: #a94442; }
a.text-danger:hover { color: #843534; }
.tooltip {
  position: absolute;
  z-index: 1070;
  display: block;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 12px;
  font-weight: normal;
  line-height: 1.4;
  visibility: visible;
  filter: alpha(opacity=0);
  opacity: 0;
}
.tooltip.in {
  filter: alpha(opacity=90);
  opacity: .9;
}
.tooltip.top {
  padding: 5px 0;
  margin-top: -3px;
}
.tooltip.right {
  padding: 0 5px;
  margin-left: 3px;
}
.tooltip.bottom {
  padding: 5px 0;
  margin-top: 3px;
}
.tooltip.left {
  padding: 0 5px;
  margin-left: -3px;
}
.tooltip-inner {
  max-width: 200px;
  padding: 3px 8px;
  color: #fff;
  text-align: center;
  text-decoration: none;
  background-color: #000;
  border-radius: 4px;
}
.tooltip-arrow {
  position: absolute;
  width: 0;
  height: 0;
  border-color: transparent;
  border-style: solid;
}
.tooltip.top .tooltip-arrow {
  bottom: 0;
  left: 50%;
  margin-left: -5px;
  border-width: 5px 5px 0;
  border-top-color: #000;
}
.tooltip.top-left .tooltip-arrow {
  right: 5px;
  bottom: 0;
  margin-bottom: -5px;
  border-width: 5px 5px 0;
  border-top-color: #000;
}
.tooltip.top-right .tooltip-arrow {
  bottom: 0;
  left: 5px;
  margin-bottom: -5px;
  border-width: 5px 5px 0;
  border-top-color: #000;
}
.tooltip.right .tooltip-arrow {
  top: 50%;
  left: 0;
  margin-top: -5px;
  border-width: 5px 5px 5px 0;
  border-right-color: #000;
}
.tooltip.left .tooltip-arrow {
  top: 50%;
  right: 0;
  margin-top: -5px;
  border-width: 5px 0 5px 5px;
  border-left-color: #000;
}
.tooltip.bottom .tooltip-arrow {
  top: 0;
  left: 50%;
  margin-left: -5px;
  border-width: 0 5px 5px;
  border-bottom-color: #000;
}
.tooltip.bottom-left .tooltip-arrow {
  top: 0;
  right: 5px;
  margin-top: -5px;
  border-width: 0 5px 5px;
  border-bottom-color: #000;
}
.tooltip.bottom-right .tooltip-arrow {
  top: 0;
  left: 5px;
  margin-top: -5px;
  border-width: 0 5px 5px;
  border-bottom-color: #000;
}
.popover {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1060;
  display: none;
  max-width: 276px;
  padding: 1px;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 14px;
  font-weight: normal;
  line-height: 1.42857143;
  text-align: left;
  white-space: normal;
  background-color: #fff;
  -webkit-background-clip: padding-box;
          background-clip: padding-box;
  border: 1px solid #ccc;
  border: 1px solid rgba(0, 0, 0, .2);
  border-radius: 6px;
  -webkit-box-shadow: 0 5px 10px rgba(0, 0, 0, .2);
          box-shadow: 0 5px 10px rgba(0, 0, 0, .2);
}
.popover.top {
  margin-top: -10px;
}
.popover.right {
  margin-left: 10px;
}
.popover.bottom {
  margin-top: 10px;
}
.popover.left {
  margin-left: -10px;
}
.popover-title {
  padding: 8px 14px;
  margin: 0;
  font-size: 14px;
  background-color: #f7f7f7;
  border-bottom: 1px solid #ebebeb;
  border-radius: 5px 5px 0 0;
}
.popover-content {
  padding: 9px 14px;
}
.popover > .arrow,
.popover > .arrow:after {
  position: absolute;
  display: block;
  width: 0;
  height: 0;
  border-color: transparent;
  border-style: solid;
}
.popover > .arrow {
  border-width: 11px;
}
.popover > .arrow:after {
  content: "";
  border-width: 10px;
}
.popover.top > .arrow {
  bottom: -11px;
  left: 50%;
  margin-left: -11px;
  border-top-color: #999;
  border-top-color: rgba(0, 0, 0, .25);
  border-bottom-width: 0;
}
.popover.top > .arrow:after {
  bottom: 1px;
  margin-left: -10px;
  content: " ";
  border-top-color: #fff;
  border-bottom-width: 0;
}
.popover.right > .arrow {
  top: 50%;
  left: -11px;
  margin-top: -11px;
  border-right-color: #999;
  border-right-color: rgba(0, 0, 0, .25);
  border-left-width: 0;
}
.popover.right > .arrow:after {
  bottom: -10px;
  left: 1px;
  content: " ";
  border-right-color: #fff;
  border-left-width: 0;
}
.popover.bottom > .arrow {
  top: -11px;
  left: 50%;
  margin-left: -11px;
  border-top-width: 0;
  border-bottom-color: #999;
  border-bottom-color: rgba(0, 0, 0, .25);
}
.popover.bottom > .arrow:after {
  top: 1px;
  margin-left: -10px;
  content: " ";
  border-top-width: 0;
  border-bottom-color: #fff;
}
.popover.left > .arrow {
  top: 50%;
  right: -11px;
  margin-top: -11px;
  border-right-width: 0;
  border-left-color: #999;
  border-left-color: rgba(0, 0, 0, .25);
}
.popover.left > .arrow:after {
  right: 1px;
  bottom: -10px;
  content: " ";
  border-right-width: 0;
  border-left-color: #fff;
}
</style>
{/literal}
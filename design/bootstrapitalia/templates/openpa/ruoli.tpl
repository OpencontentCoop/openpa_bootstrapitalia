{ezpagedata_set('show_path', false())}
{def $class_identifier = 'time_indexed_role'
	 $parent_node_id = openpa_roles_parent_node_id()
	 $parent_node = fetch(content, node, hash(node_id, $parent_node_id))
	 $can_create = cond($parent_node.can_create, true(), false())}

<div class="row">
	<div class="col-md-12">
	  	<h3>Gestione dei ruoli</h3> 
	</div>		
	<div class="col-md-{if $can_create}10{else}12{/if}">
		<div class="input-group">
		  <input type="text" class="form-control" id="name">
		  <div class="input-group-append">
		    <button class="btn btn-info" type="button" id="FindContents">Cerca</button>
		    <button class="btn btn-danger" type="button" style="display: none;" id="ResetContents">Annulla ricerca</button>
		  </div>
		</div>
	</div>
	{if $can_create}
	<div class="col-md-2">
		<button type="submit" class="btn btn-success rounded-0" id="AddContent">
		  Crea nuovo
		</button>	          
	</div>
	{/if}
	<div class="col-md-12">
		<table class="table table-striped" id="data">
			<thead>
				<tr>				
					<th>Ruolo</th>
					<th>Persona</th>
					<th>Struttura</th>
					{if $can_create}<th width="1"></th>{/if}
		        </tr>
			</thead>
			<tbody></tbody>
		</table>
	</div>
</div>

<div id="data-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                </div>
                <div id="data-form" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>

{ezscript_require(array(
    'jsrender.js',
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

{literal}
<script id="tpl-results" type="text/x-jsrender">    
{{for searchHits}}
<tr>
	<td>
		{{if ~i18n(data,'role')}}{{:~i18n(data,'role')}}{{/if}}
	</td>
	<td>
		{{if ~i18n(data,'person') ~baseUrl=baseUrl}}
            {{for ~i18n(data,'person')}}<a href="{{:~baseUrl}}content/view/full/{{:mainNodeId}}">{{:~i18n(name)}}</a>{{/for}}
        {{/if}}
	</td>
    <td>
        {{if ~i18n(data,'for_entity') ~baseUrl=baseUrl}}
            {{for ~i18n(data,'for_entity')}}<a href="{{:~baseUrl}}content/view/full/{{:mainNodeId}}">{{:~i18n(name)}}</a>{{/for}}
        {{/if}}
	</td>	
    {/literal}{if $can_create}{literal}
	<td style="white-space: nowrap;">
		<a href="#" class="edit-object" data-object="{{:metadata.id}}"><span class="fa-stack"><i class="fa fa-square fa-stack-2x"></i><i class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
		<a href="#" class="delete-object" data-object="{{:metadata.id}}"><span class="fa-stack text-danger"><i class="fa fa-square fa-stack-2x"></i><i class="fa fa-trash-o fa-stack-1x fa-inverse"></i></span></a>
	</td>
	{/literal}{/if}{literal}
</tr>	
{{/for}}
{{if prevPageQuery || nextPageQuery }}
<tr>
	<td colspan="4">
		{{if prevPageQuery}}
			<div class="pull-left"><a href="#" id="prevPage" data-query="{{>prevPageQuery}}">Pagina precedente</a></div>
		{{/if}}
		{{if nextPageQuery }}
			<div class="pull-right"><a href="#" id="nextPage" data-query="{{>nextPageQuery}}">Pagina successiva</a></div>		
		{{/if}}
	</td>
</tr>	
{{/if}}
</script>
{/literal}

<script type="text/javascript" language="javascript">
	var ParentNodeId = {$parent_node_id};
	var ContainerSelector = "#data";
	var FormSelector = "#data-form";
	var ClassIdentifier = "{$class_identifier}";
	var ModalSelector = "#data-modal"
	{literal}

	$(document).ready(function () {

        var baseUrl = '/';
        if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            baseUrl = UriPrefix + '/';
        }

	    var tools = $.opendataTools;
		$.views.helpers(tools.helpers);

	    var pageLimit = 50;
	    var template = $.templates('#tpl-results');
	    var classQuery = '';
	    if (ClassIdentifier){
	    	classQuery = 'classes ['+ClassIdentifier+'] ';
	    }
	    var mainQuery = classQuery+'subtree [' + ParentNodeId + '] sort [name=>asc] limit ' + pageLimit;
	    var $container = $(ContainerSelector).find('tbody');

	    var currentPage = 0;
	    var queryPerPage = [];

	    var runQuery = function (query) {        
	        tools.find(query, function (response) {            
	            queryPerPage[currentPage] = query;
	            response.currentPage = currentPage;
	            response.prevPageQuery = jQuery.type(queryPerPage[currentPage - 1]) === "undefined" ? null : queryPerPage[currentPage - 1];

                $.each(response.searchHits, function(){
                    this.baseUrl = baseUrl;
                });
	            var renderData = $(template.render(response));

	            renderData.find('.edit-object').on('click', function (e) {
	                var object = $(this).data('object');
	                $(FormSelector).opendataFormEdit({'object': object},{
		                onBeforeCreate: function () {$(ModalSelector).modal('show');},
		                onSuccess: function () {$(ModalSelector).modal('hide');runQuery(query);}
		            });
	                e.preventDefault();
	            });

	            renderData.find('.delete-object').on('click', function (e) {
	                var object = $(this).data('object');                
	                $(FormSelector).opendataFormDelete(object,{
		                onBeforeCreate: function () {$(ModalSelector).modal('show');},
		                onSuccess: function () {$(ModalSelector).modal('hide');runQuery(query);}
		            });	                
	                e.preventDefault();
	            });

	            $container.html(renderData);

	            $container.find('#nextPage').on('click', function (e) {
	                currentPage++;
	                runQuery($(this).data('query'));
	                e.preventDefault();
	            });

	            $container.find('#prevPage').on('click', function (e) {
	                currentPage--;
	                runQuery($(this).data('query'));
	                e.preventDefault();
	            });
	        });
	    };

	    var loadContents = function () {
	        $('#name').val('');        
	        runQuery(mainQuery);
	    };

	    $('#FindContents').on('click', function (e) {
	        var name = $('#name').val();
	        var filters = '';
	        if (name) {
	            filters += 'q = "' + name + '" and ';            
	            var searchQuery = classQuery+'subtree [' + ParentNodeId + '] and ' + filters + ' limit ' + pageLimit;
	            runQuery(searchQuery);
	            $('#ResetContents').show();
	            currentPage = 0;
	        }else{
                loadContents();
	        }                
	        e.preventDefault();
	    });

	    $('#ResetContents').on('click', function (e) {
	        $('#name').val('');
	        $('#ResetContents').hide();
	        currentPage = 0;
	        runQuery(mainQuery);
	        e.preventDefault();
	    });

	    $('#AddContent').on('click', function (e) {	        
	        $(FormSelector).opendataFormCreate({
		            class: ClassIdentifier,
		            parent: ParentNodeId
	        	},{
	        		onBeforeCreate: function () {$(ModalSelector).modal('show');},
	                onSuccess: function () {
	                	$(ModalSelector).modal('hide');
	                	$('#ResetContents').trigger('click');
                	}
	        	}
	        );
	        e.preventDefault();
	    });

	    loadContents();
	});  
{/literal}
</script>
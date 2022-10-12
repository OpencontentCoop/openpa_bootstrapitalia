{ezpagedata_set('show_path', false())}
{def $class_identifier = 'time_indexed_role'
	 $parent_node_id = openpa_roles_parent_node_id()
	 $parent_node = fetch(content, node, hash(node_id, $parent_node_id))
	 $can_create = cond($parent_node.can_create, true(), false())}
<div class="p-3">
<div class="row">
	<div class="col-md-12">
		<h3>
			Gestione dei ruoli amministrativi e politici
			{*<a class="btn btn-xs btn-primary rounded-0" href="{'bootstrapitalia/role_list'|ezurl(no)}">
				Ruoli
			</a>*}
		</h3>
	</div>		
	<div class="col-md-{if $can_create}10{else}12{/if}">
		<div class="input-group">
		  <input type="text" class="form-control" id="name">
		  <div class="input-group-append">
		    <button class="btn btn-info py-2" type="button" id="FindContents">{'Search'|i18n('openpa/search')}</button>
		    <button class="btn btn-danger py-2" type="button" style="display: none;" id="ResetContents">Annulla ricerca</button>
		  </div>
		</div>
		<div class="form-group form-check">
			<input id="OnlyExpired"
				   class="form-check-input"
				   type="checkbox"
				   name="OnlyExpired"
				   value="" />
			<label class="form-check-label" for="OnlyExpired">
				Mostra solo ruoli scaduti
			</label>
		</div>
	</div>
	{if $can_create}
	<div class="col-md-2">
		<button type="submit" class="btn btn-success rounded-0 py-2" id="AddContent">
		  Crea nuovo
		</button>	          
	</div>
	{/if}
	<div class="col-md-12">
		<table class="table table-striped table-hover" id="data">
			<thead>
				<tr>				
					<th width="1"></th>
					<th>Ruolo</th>
					<th>Persona</th>
					<th>Struttura</th>
					<th class="text-nowrap">Valido dal</th>
					<th class="text-nowrap">Valido al</th>
					<th>Priorità</th>
					{if $can_create}<th width="1"></th>{/if}
		        </tr>
			</thead>
			<tbody></tbody>
		</table>
	</div>
</div>
</div>
<div id="data-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
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
{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
<script>
	$.opendataTools.settings('language', "{$current_language}");
	$.opendataTools.settings('locale', "{$moment_language}");
	$.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
</script>
{literal}
<script id="tpl-results" type="text/x-jsrender">    
{{for searchHits}}
<tr>
	<td style="white-space: nowrap;">
		{{if translations.length > 1}}
		{{for translations}}
			{{if active}}
				<img src="/share/icons/flags/{{:language}}.gif" />
			{{else}}
				<img style="opacity:0.2" src="/share/icons/flags/{{:language}}.gif" />
			{{/if}}
		{{/for}}
		{{/if}}
	</td>
	<td class="{{if ~i18n(data,'ruolo_principale')}}font-weight-bold{{/if}}">
		{{if ~i18n(data,'role')}}
			{{:~i18n(data,'role')}}
		{{/if}}
	</td>
	<td>
		{{if ~i18n(data,'person') ~baseUrl=baseUrl}}
            {{for ~i18n(data,'person')}}<a class="d-block" href="{{:~baseUrl}}content/view/full/{{:mainNodeId}}">{{:~i18n(name)}}</a>{{/for}}
        {{/if}}
	</td>
    <td>
        {{if ~i18n(data,'for_entity') ~baseUrl=baseUrl}}
            {{for ~i18n(data,'for_entity')}}<a class="d-block" href="{{:~baseUrl}}content/view/full/{{:mainNodeId}}">{{:~i18n(name)}}</a>{{/for}}
        {{/if}}
	</td>
	<td>
		{{if ~i18n(data,'start_time')}}
			{{:~formatDate(~i18n(data,'start_time'), dateFormat)}}
		{{/if}}
	</td>
	<td>
		{{if ~i18n(data,'end_time')}}
			{{:~formatDate(~i18n(data,'end_time'), dateFormat)}}
		{{/if}}
	</td>
	<td class="text-center">
		{{if ~i18n(data,'priorita')}}
			{{:~i18n(data,'priorita')}}
		{{/if}}
	</td>
	<td style="white-space: nowrap;">
    {/literal}{if $can_create}{literal}
		<a href="#" class="edit-object" data-object="{{:metadata.id}}"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
		<a href="#" class="delete-object" data-object="{{:metadata.id}}"><span class="fa-stack text-danger"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-trash-o fa-stack-1x fa-inverse"></i></span></a>
	{/literal}{/if}{literal}
	</td>
</tr>	
{{/for}}
{{if prevPageQuery || nextPageQuery }}
<tr>
	<td colspan="{/literal}{if $can_create}8{else}7{/if}{literal}">
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

<script>
	var ParentNodeId = {$parent_node_id};
	var ContainerSelector = "#data";
	var FormSelector = "#data-form";
	var ClassIdentifier = "{$class_identifier}";
	var ModalSelector = "#data-modal";
	$.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
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
	    var $container = $(ContainerSelector).find('tbody');
		var onlyExpired = $('#OnlyExpired')
		var reset = $('#ResetContents');

	    var currentPage = 0;
	    var queryPerPage = [];

	    var baseQuery = classQuery+'subtree [' + ParentNodeId + '] sort [raw[attr_priorita_si]=>desc,person.name=>asc] limit ' + pageLimit;
	    var buildQuery = function (){
	    	var query = baseQuery;
			var name = $('#name').val();
			var filters = '';
			if (onlyExpired.is(':checked')){
				query =  'end_time range [\'*\', \'1 hour ago\'] and ' + query;
			}
			if (name) {
				query =  'q = "' + name + '" and ' + query;
			}
			if (query !== baseQuery){
				reset.show();
			}
			return query;
		}

	    var runQuery = function (query) {        
	        tools.find(query, function (response) {            
	            queryPerPage[currentPage] = query;
	            response.currentPage = currentPage;
	            response.prevPageQuery = jQuery.type(queryPerPage[currentPage - 1]) === "undefined" ? null : queryPerPage[currentPage - 1];

                $.each(response.searchHits, function(){
					var self = this;
                	this.baseUrl = baseUrl;
					this.languages = $.opendataTools.settings('languages');
					this.dateFormat = MomentDateFormat;
					this.dateTimeFormat = MomentDateTimeFormat;
					var translations = [];
					if (this.languages.length > 1) {
						var currentTranslations = $.map(this.data, function (value, key) {
							return key;
						});
						$.each(this.languages, function () {
							translations.push({
								'id': self.metadata.id,
								'language': this,
								'active': $.inArray(this.toString(), currentTranslations) > -1
							});
						});
					}
					this.translations = translations;
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
	        runQuery(buildQuery());
	    };

	    $('#FindContents').on('click', function (e) {
			currentPage = 0;
			runQuery(buildQuery());
	        e.preventDefault();
	    });

		reset.on('click', function (e) {
	        $('#name').val('');
			if (onlyExpired.is(':checked')){
				onlyExpired.trigger('click');
			}
			reset.hide();
	        currentPage = 0;
			runQuery(buildQuery());
	        e.preventDefault();
	    });

		onlyExpired.on('change', function (){
			currentPage = 0;
			runQuery(buildQuery());
			e.preventDefault();
		})

	    $('#AddContent').on('click', function (e) {	        
	        $(FormSelector).opendataFormCreate({
		            class: ClassIdentifier,
		            parent: ParentNodeId
	        	},{
	        		onBeforeCreate: function () {$(ModalSelector).modal('show');},
	                onSuccess: function () {
	                	$(ModalSelector).modal('hide');
						reset.trigger('click');
                	}
	        	}
	        );
	        e.preventDefault();
	    });

	    loadContents();
	});  
{/literal}
</script>

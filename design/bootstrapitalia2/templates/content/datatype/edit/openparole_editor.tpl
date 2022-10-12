{def $parent_node_id = openpa_roles_parent_node_id()
	 $parent_node = fetch(content, node, hash(node_id, $parent_node_id))
	 $can_create = cond($parent_node.can_create, true(), false())}

<div id="roles-gui-{$attribute.id}"
	 data-openparole-editor
	 data-parent="{$parent_node_id}"
	 data-class="time_indexed_role">
	<textarea style="display: none" data-query>{$attribute.content.query}</textarea>
	<div class="col-md-12">
		<table class="table table-striped table-hover" data-role_list>
			<thead>
			<tr>
				<th width="1"></th>
				<th>Ruolo</th>
				<th>Persona</th>
				<th>Struttura</th>
				<th class="text-nowrap">Valido dal</th>
				<th class="text-nowrap">Valido al</th>
				<th>Priorità</th>
				{if $can_create}<th width="1" class="text-end">
					<a href="#" data-role_add>
						<span class="fa-stack">
							<i aria-hidden="true" class="fa fa-square fa-stack-2x"></i>
							<i aria-hidden="true" class="fa fa-plus fa-stack-1x fa-inverse"></i>
						</span>
					</a>
				</th>{/if}
			</tr>
			</thead>
			<tbody></tbody>
		</table>
	</div>
	<div data-role_modal class="modal fade modal-fullscreen" data-bs-backdrop="static" style="z-index:10000">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">
				<div class="modal-body">
					<div class="clearfix">
						<button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
					</div>
					<div data-role_form class="clearfix p-4"></div>
				</div>
			</div>
		</div>
	</div>
</div>

{run-once}

<script>
{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
$.opendataTools.settings('language', "{$current_language}");
$.opendataTools.settings('locale', "{$moment_language}");
$.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
{literal}
$(document).ready(function () {
	$('[data-openparole-editor]').each(function (){
		var ParentNodeId = $(this).data('parent');
		var ClassIdentifier = $(this).data('class');
		var ContainerSelector = $(this).find('[data-role_list]');
		var FormSelector = $(this).find('[data-role_form]');
		var ModalSelector = $(this).find('[data-role_modal]');
		var TemplateSelector = "#tpl-results-roles";
		var Query = $(this).find('[data-query]').val();
		var AddButton = $(this).find('[data-role_add]');

		var baseUrl = (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/') ? baseUrl = UriPrefix + '/' : '/';
		var tools = $.opendataTools;
		$.views.helpers(tools.helpers);
		var pageLimit = 50;
		var template = $.templates(TemplateSelector);
		var $container = $(ContainerSelector).find('tbody');
		var currentPage = 0;
		var queryPerPage = [];

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
						onSuccess: function () {
							$(ModalSelector).modal('hide');
							$(document).trigger("roles:update");
						}
					});
					e.preventDefault();
				});
				renderData.find('.delete-object').on('click', function (e) {
					var object = $(this).data('object');
					$(FormSelector).opendataFormDelete(object,{
						onBeforeCreate: function () {$(ModalSelector).modal('show');},
						onSuccess: function () {
							$(ModalSelector).modal('hide');
							$(document).trigger("roles:update");
						}
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
			runQuery(Query);
		};
		$(document).on("roles:update", function (){
			loadContents();
		});
		AddButton.on('click', function (e) {
			$(FormSelector).opendataFormCreate({
						class: ClassIdentifier,
						parent: ParentNodeId
					},{
						onBeforeCreate: function () {$(ModalSelector).modal('show');},
						onSuccess: function () {
							$(ModalSelector).modal('hide');
							$(document).trigger("roles:update");
						}
					}
			);
			e.preventDefault();
		});
		loadContents();
	});
});
</script>
<script id="tpl-results-roles" type="text/x-jsrender">
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
{/run-once}
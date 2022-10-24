<div data-faq_group="{$node.node_id}" data-showeditor="{cond($node.can_create,1,2)}" data-capabilities="{cond($node.can_edit, '1', '0')}"></div>

{if or($node.can_edit, $node.can_create)}
<a href="#" data-create_faq="{$node.node_id}" class="btn btn-success btn-sm mt-2"><i class="fa fa-plus"></i></a>
{run-once}
{ezscript_require(array(
    'handlebars.min.js',
    'alpaca.js',
    'jstree.min.js',
    'fields/Ezxml.js',
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
    'alpaca-custom.css'
))}
<script>{literal}
$(document).ready(function(){
    $.opendataFormSetup({
        i18n: {{/literal}
            'store': "{'Store'|i18n('opendata_forms')}",
            'cancel': "{'Cancel'|i18n('opendata_forms')}",
            'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
            'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
            'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
        {literal}}
    });
});
{/literal}</script>
<div id="faq-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div id="faq-form" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>
{/run-once}
{/if}

{run-once}
{literal}
<script id="tpl-faq-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
</div>
</script>
<script id="tpl-faq-results" type="text/x-jsrender">
{{if totalCount > 0}}
    <div class="collapse-div collapse-right-icon">
    {{for searchHits}}
        <div class="collapse-header" id="heading-{{:metadata.id}}">
            <button class="px-1" data-toggle="collapse" data-bs-toggle="collapse" data-target="#collapse-{{:metadata.id}}" data-bs-target="#collapse-{{:metadata.id}}" aria-expanded="false" aria-controls="collapse-{{:metadata.id}}">
                {{if metadata.userAccess && metadata.userAccess.canEdit}}<a href="#" class="pr-2 pe-2 pe-2" data-edit={{:metadata.id}}><i class="fa fa-pencil"></i></a>{{/if}}
                {{if metadata.userAccess && metadata.userAccess.canRemove}}<a href="#" class="pr-2 pe-2 pe-2" data-remove={{:metadata.id}}><i class="fa fa-trash"></i></a>{{/if}}
                {{if ~i18n(data, 'question')}}{{:~i18n(data, 'question')}}{{/if}}
            </button>
        </div>
        <div id="collapse-{{:metadata.id}}" class="collapse" aria-labelledby="heading-{{:metadata.id}}">
            <div class="collapse-body px-1">
                {{if ~i18n(data, 'answer')}}{{:~i18n(data, 'answer')}}{{/if}}
            </div>
        </div>
    {{/for}}
    </div>
{{/if}}
{{if pageCount > 1}}
<div class="row mt-lg-4">
    <div class="col">
        <nav class="pagination-wrapper justify-content-center" aria-label="{/literal}{'Navigation'|i18n('design/ocbootstrap/menu')}{literal}">
            <ul class="pagination">
                {{if prevPageQuery}}
                <li class="page-item">
                    <a class="page-link prevPage" data-page="{{>prevPage}}" href="#">
                        <svg class="icon icon-primary">
                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
                        </svg>
                        <span class="sr-only">Pagina precedente</span>
                    </a>
                </li>
                {{/if}}
                {{for pages ~current=currentPage}}
                    <li class="page-item"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>
                {{/for}}
                {{if nextPageQuery }}
                <li class="page-item">
                    <a class="page-link nextPage" data-page="{{>nextPage}}" href="#">
                        <span class="sr-only">Pagina successiva</span>
                        <svg class="icon icon-primary">
                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
                        </svg>
                    </a>
                </li>
                {{/if}}
            </ul>
        </nav>
    </div>
</div>
{{/if}}
</script>
{/literal}
{/run-once}

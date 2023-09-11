<div data-faq_group="{$node.node_id}"
     data-showeditor="{cond($node.can_create,1,2)}"
     data-capabilities="{cond($node.can_edit, '1', '0')}">
    <div class="cmp-input-search">
        <div class="form-group autocomplete-wrapper mb-2 mb-lg-4">
            <div class="input-group">
                <label for="autocomplete-autocomplete-three" class="visually-hidden">{'Search'|i18n('openpa/search')}</label>
                <input type="search" class="autocomplete form-control faqSearchInput" placeholder="{'Search'|i18n('openpa/search')}" id="autocomplete-autocomplete-three" name="autocomplete-three" data-bs-autocomplete="[]">
                <div class="input-group-append">
                    <button class="btn btn-primary faqSearchSubmit" type="button" id="button-3">{'Submit'|i18n('survey')}</button>
                </div>
                <span class="autocomplete-icon" aria-hidden="true">
                {display_icon('it-search', 'svg', 'icon icon-sm icon-primary', 'Search'|i18n('openpa/search'))}
            </span>
            </div>
        </div>
    </div>
    <div data-faq_list></div>
    <div data-faq_pagination></div>
</div>
{ezscript_require(array('jquery.faqs.js'))}
{if or($node.can_edit, $node.can_create)}
    <div class="my-2 text-right">
        <a href="#" data-create_faq="{$node.node_id}" class="btn btn-success btn-sm"><i class="fa fa-plus"></i> {'Add item'|i18n( 'design/standard/block/edit' )}</a>
    </div>
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
<script>
  $.opendataTools.settings('language', "{/literal}{ezini('RegionalSettings','Locale')}{literal}");
  $.opendataTools.settings('languages', ['{/literal}{ezini('RegionalSettings','SiteLanguageList')|implode("','")}{literal}']);
</script>
<script id="tpl-faq-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
</div>
</script>
<script id="tpl-faq-results" type="text/x-jsrender">
{{if totalCount > 0}}
    <div class="accordion">
    {{for searchHits}}
    <div class="accordion-item">
        <h2 class="accordion-header" id="heading-{{:metadata.id}}">
            <button class="accordion-button collapsed" data-bs-toggle="collapse" data-bs-target="#collapse-{{:metadata.id}}" aria-expanded="false" aria-controls="collapse-{{:metadata.id}}">
                {{if metadata.userAccess && metadata.userAccess.canEdit}}<a href="#" class="pr-2 pe-2 pe-2" data-edit={{:metadata.id}}><i class="fa fa-pencil"></i></a>{{/if}}
                {{if metadata.userAccess && metadata.userAccess.canRemove}}<a href="#" class="pr-2 pe-2 pe-2" data-remove={{:metadata.id}}><i class="fa fa-trash"></i></a>{{/if}}
                {{if ~i18n(data, 'question')}}{{:~i18n(data, 'question')}}{{/if}}
            </button>
        </h2>
        <div id="collapse-{{:metadata.id}}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{{:metadata.id}}">
            <div class="accordion-body">
                {{if ~i18n(data, 'answer')}}{{:~i18n(data, 'answer')}}{{/if}}
            </div>
        </div>
    </div>
    {{/for}}
    </div>
{{/if}}
</script>
<script id="tpl-faq-pagination" type="text/x-jsrender">
{{if pageCount > 1}}
    {{if nextPageQuery }}
        <a class="btn btn-outline-primary w-100 mt-40 mb-40 title-medium-bold moreResults" data-page="{{>nextPage}}">Carica altre domande</a>
    {{/if}}
{{/if}}
</script>
{/literal}
{/run-once}

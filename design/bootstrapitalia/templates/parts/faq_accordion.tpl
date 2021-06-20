<div data-faq_group="{$node.node_id}" data-showeditor="{cond($node.can_create,1,2)}"></div>
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
            <button class="px-1" data-toggle="collapse" data-target="#collapse-{{:metadata.id}}" aria-expanded="false" aria-controls="collapse-{{:metadata.id}}">
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
        <nav class="pagination-wrapper justify-content-center" aria-label="Esempio di navigazione della pagina">
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
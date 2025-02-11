{set_defaults( hash(
  'wrapper_class', 'py-5 position-relative',
  'container_class', 'container'
))}
{def $openpa = object_handler($block)}

{def $searchPlaceholder = $block.custom_attributes.input_search_placeholder
	 $subtree = cond(and($block.custom_attributes.subtree, is_set($block.custom_attributes.subtree)), $block.custom_attributes.subtree, 1)
	 $limit = $block.custom_attributes.limit
	 $itemsPerRow = $block.custom_attributes.items_per_row
     $facets = array('Struttura:raw[submeta_for_entity___name____t]', 'Ruolo:role')}

{def $query = 'classes [public_person] sort [name=>asc]'}

<div class="{$wrapper_class} search-people-wrapper">
    <div class="{$container_class}">

        {include uri='design:parts/block_name.tpl'}

        <div class="row" id="search-people-{$block.id}">
            <div class="col-12 col-lg-4 ps-lg-5">
                <ul class="nav d-block nav-pills text-center text-md-right hide">
                    <li class="nav-item pr-1 pe-1 text-center d-inline-block">
                        <a data-toggle="tab" data-bs-toggle="tab"
                           class="nav-link active rounded view-selector text-uppercase"
                           href="#search-people-{$block.id}-list">
                            <i aria-hidden="true" class="fa fa-list"></i> {'List'|i18n('editorialstuff/dashboard')}
                        </a>
                    </li>
                </ul>

                {def $index = 0
                     $facetsFields = array()}
                {foreach $facets as $facet}
                    {def $facets_parts = $facet|explode(':')}
                    {if is_set($facets_parts[1])}
                        <div class="px-0 my-4 mb-5">
                            <label class="h6 ms-0 ps-0" for="facet-{$block.id}-{$index}">{$facets_parts[0]|wash()}</label>
                            <select id="facet-{$block.id}-{$index}" data-placeholder="{'Select'|i18n('design/admin/content/browse')}" data-facets_select="facet-{$index}" class="d-none" multiple></select>
                        </div>
                        {set $index = $index|inc()}
                        {set $facetsFields = $facetsFields|append($facets_parts[1])}
                    {/if}
                    {undef $facets_parts}
                {/foreach}
            </div>

            <section class="order-md-first col-12 col-lg-8 pt-lg-2 pb-lg-2 mb-5 mb-lg-0">
                {def $placeHolder = cond($searchPlaceholder|eq(''), 'Search by keyword'|i18n('bootstrapitalia'), $searchPlaceholder)}
                <div class="form-group mb-2 mb-lg-4 search-form">
                    <div class="input-group">
                        <span class="input-group-text h-auto">{display_icon('it-search', 'svg', 'icon icon-sm')}</span>
                        <label for="search-input-{$block.id}" class="visually-hidden">{$placeHolder|wash()}</label>
                        <input type="text" class="form-control" id="search-input-{$block.id}" data-search="q" placeholder="{$placeHolder|wash()}" name="search-input-{$block.id}">
                        <div class="input-group-append">
                            <button class="btn btn-primary" type="button" id="button-3">{'Search'|i18n('design/plain/layout')}</button>
                        </div>
                    </div>
                </div>
                {undef $placeHolder}
                <section id="search-people-{$block.id}-list" class="pt-0 pl-0 ps-0"></section>
            </section>
        </div>

    </div>
</div>

{ezscript_require(array(
    'jsrender.js',
    'accessible-autocomplete.min.js',
    'jquery.search_people_by_role.js'
))}
{ezcss_require(array('accessible-autocomplete.min.css'))}

<script>

$(document).ready(function () {ldelim}
  moment.locale($.opendataTools.settings('locale'));
  $.views.helpers($.opendataTools.helpers)
  $("#search-people-{$block.id}").searchPeopleByRole({ldelim}
    localAccessPrefix: '{'/'|ezurl(no)}',
    query: "classes [public_person] and subtree [{$subtree}] sort [name=>asc]",
    subQuery: "select-fields [data.person{ldelim}0{rdelim}.id] and raw[submeta_person___path____si] in ['{$subtree}'] and classes [time_indexed_role] limit 1000",
    facetQuery: "classes [time_indexed_role] and raw[submeta_person___path____si] in ['{$subtree}'] and facets [for_entity.name|alpha,role|alpha] limit 1",
    facets:['{$facetsFields|implode("','")}']
  {rdelim});
{rdelim})

</script>
{undef $searchPlaceholder $query $limit $itemsPerRow}

{include uri='design:parts/opendata_remote_gui_templates.tpl' block=$block show_search=false()}
{unset_defaults( array('wrapper_class','container_class'))}
{def $params = parse_search_get_params()
     $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )
     $topic_menu_label = 'Topics'|i18n('bootstrapitalia')}

{if fetch('openpa', 'homepage')|has_attribute('topic_menu_label')}
    {set $topic_menu_label = fetch('openpa', 'homepage')|attribute('topic_menu_label').content}
{/if}

{set $page_limit = 20}
{def $filters = array()
     $search_hash = $params._search_hash|merge(hash('offset', $view_parameters.offset,'limit', $page_limit ))
     $search = fetch( extraindex, search_with_external_data, $search_hash )}

{def $classes = array()}
{if openpaini('MotoreRicerca', 'IncludiClassi', array())|count()}
    {set $classes = fetch(class, list, hash(class_filter, openpaini('MotoreRicerca', 'IncludiClassi'), sort_by, array( 'name', true() )))}
{/if}

<div class="row">
    <div class="col-12 mt-5 pb-4 border-bottom">        
        <h2>{if $params.text|ne('')}{'Search results for %searchtext'|i18n('openpa/search',,hash('%searchtext',concat('<em>',$params.text|wash(),'</em>')))}{else}{'Search results'|i18n('openpa/search')}{/if}</h2>
    </div>
</div>


{def $subtree_facets = $search.SearchExtras.facet_fields[0].countList
     $topic_facets = $search.SearchExtras.facet_fields[1].countList
     $class_facets = $search.SearchExtras.facet_fields[2].countList}

<form class="mt-3 mb-5" action="{'content/search'|ezurl(no)}" method="get">
    
    <div class="d-block d-lg-none d-xl-none text-center">
        <a href="#categoryCollapse" role="button" class="btn btn-primary btn-xs text-uppercase collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="categoryCollapse">{'Filters'|i18n('bootstrapitalia')}</a>
    </div>

    <div class="row">
        <aside class="col-lg-3">
            <div class="d-lg-block d-xl-block collapse mt-5" id="categoryCollapse">
                
                <div class="form-group floating-labels">
                    <div class="form-label-group pr-2 pe-2 pe-2">
                        <input type="text"
                               class="form-control pl-0 ps-0"
                               id="search-text"
                               name="SearchText"
                               value="{$params.text|wash()}"
                               placeholder="{'Search text'|i18n('bootstrapitalia/documents')}"/>
                        <label class="pl-0 ps-0" for="search-text">{'Search'|i18n('openpa/search')}</label>
                        <button type="submit" class="autocomplete-icon btn btn-link" aria-label="{'Search'|i18n('openpa/search')}">
                            {display_icon('it-search', 'svg', 'icon')}
                        </button>
                    </div>
                </div>

                {if count($top_menu_node_ids)}
                <div class="pt-4 pt-lg-0">
                    <h6 class="text-uppercase">{'Sections'|i18n('openpa/search')}</h6>
                    <div class="mt-4">
                    {foreach $top_menu_node_ids as $id}
                        {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu'))}
                        {def $has_children = false()}
                        {def $display = false()}

                        {foreach $tree_menu.children as $child}
                            {if $child.item.node_id|eq($tree_menu.item.node_id)}{skip}{/if} {*tag menu*}
                            {set $has_children = true()}
                            {if $params.subtree|contains($child.item.node_id)}
                                {set $display = true()}
                                {break}
                            {/if}
                        {/foreach}

                        {if $params.subtree_boundary|eq($id)}
                            {set $display = true()}
                        {/if}
                        
                        <div class="form-check custom-control custom-checkbox m-0">
                            <input name="Subtree[]" {if $has_children}data-checkbox-container {/if}id="subtree-{$tree_menu.item.node_id}" value="{$tree_menu.item.node_id|wash()}" {if or($params.subtree|contains($id), and($display, $has_children|not()))}checked="checked"{elseif $display}data-indeterminate="1"{/if} class="custom-control-input" type="checkbox" />
                            <label class="custom-control-label"{if $has_children} style="max-width: 80%"{/if} for="subtree-{$tree_menu.item.node_id}">{$tree_menu.item.name|wash()} {if is_set($subtree_facets[$id])}<small>({$subtree_facets[$id]})</small>{/if}</label>
                            {if $has_children}
                            <a class="float-right float-end" aria-label="{'Expand section'|i18n('bootstrapitalia')}" href="#more-subtree-{$tree_menu.item.node_id}" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="more-subtree-{$tree_menu.item.node_id}" role="button">
                                {display_icon('it-more-items', 'svg', 'icon icon-primary right')}                    
                            </a>
                            {/if}
                        </div>
                        {if $has_children}
                        <div class="pl-4 ps-4 collapse{*if $display} show{/if*}" id="more-subtree-{$tree_menu.item.node_id}">
                            {foreach $tree_menu.children as $child}
                                {if $child.item.node_id|eq($tree_menu.item.node_id)}{skip}{/if} {*tag menu*}
                                <div class="form-check custom-control custom-checkbox m-0">
                                    <input data-checkbox-child name="Subtree[]" id="subtree-{$child.item.node_id}" value="{$child.item.node_id|wash()}" {if $params.subtree|contains($child.item.node_id)}checked="checked"{/if} class="custom-control-input" type="checkbox">
                                    <label class="custom-control-label" for="subtree-{$child.item.node_id}">{$child.item.name|wash()} {if is_set($subtree_facets[$child.item.node_id])}<small>({$subtree_facets[$child.item.node_id]})</small>{/if}</label>
                                </div>
                            {/foreach}                    
                        </div>
                        {/if}

                        {undef $tree_menu $display $has_children}

                    {/foreach}
                    </div>
                </div>
                {/if}
                
                {def $topics = fetch(content, object, hash(remote_id, 'topics'))}
                {if $topics}
                    {def $topic_list = tree_menu( hash( 'root_node_id', $topics.main_node_id, 'user_hash', false(), 'scope', 'side_menu'))
                         $topic_list_children = $topic_list.children
                         $custom_topic_container = fetch(content, object, hash(remote_id, 'custom_topics'))
                         $custom_topic_container_item = false
                         $already_displayed = array()
                         $count = 0
                         $max = 6
                         $total = count($topic_list_children)
                         $sub_count = 0}
                    {if count($topic_list_children)}
                    <div class="pt-4 pt-lg-5">
                            <h6 class="text-uppercase">{$topic_menu_label|wash()}</h6>
                            {* argomenti selezionati *}
                            {foreach $topic_list_children as $child}
                                {if and($custom_topic_container, $custom_topic_container.main_node_id|eq($child.item.node_id))}
                                    {set $custom_topic_container_item = $child}
                                    {skip}
                                {/if}
                                {if menu_item_tree_contains($child, $params.topic)}
                                    {set $already_displayed = $already_displayed|append($child.item.node_id)}
                                    {include name="topic_search_input" uri='design:parts/search/topic_search_input.tpl' topic=$child topic_facets=$topic_facets checked=true() selected=$params.topic recursion=0}
                                    {set $count = $count|inc()}
                                {/if}
                            {/foreach}

                            {* argomenti selezionabili *}
                            {if $count|lt($max)}
                                {foreach $topic_list_children as $child}
                                    {if and($custom_topic_container, $custom_topic_container.main_node_id|eq($child.item.node_id))}{skip}{/if}
                                    {if and($already_displayed|contains($child.item.node_id)|not(), is_set($topic_facets[$child.item.node_id]))}
                                        {set $already_displayed = $already_displayed|append($child.item.node_id)}
                                        {include name="topic_search_input" uri='design:parts/search/topic_search_input.tpl' topic=$child topic_facets=$topic_facets checked=false() selected=$params.topic recursion=0}
                                        {if $count|eq($max)}{break}{/if}
                                        {set $count = $count|inc()}
                                    {/if}
                                {/foreach}
                            {/if}

                            {* altri argomenti *}
                            {if $count|lt($max)}
                                {set $sub_count = $max|sub($count)}
                                {def $sub_index = 0}
                                {foreach $topic_list_children as $child}
                                    {if and($custom_topic_container, $custom_topic_container.main_node_id|eq($child.item.node_id))}{skip}{/if}
                                    {if $already_displayed|contains($child.item.node_id)|not()}
                                        {set $sub_index = $sub_index|inc()}
                                        {set $already_displayed = $already_displayed|append($child.item.node_id)}
                                        {include name="topic_search_input" uri='design:parts/search/topic_search_input.tpl' topic=$child topic_facets=$topic_facets checked=false() selected=$params.topic recursion=0}
                                        {set $count = $count|inc()}
                                        {if $sub_index|eq($sub_count)}{break}{/if}
                                    {/if}
                                {/foreach}
                            {/if}

                            {* altri argomenti collassati *}
                            {if $count|lt($total)}
                                <a href="#more-topics" aria-label="{'Expand section'|i18n('bootstrapitalia')}" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="more-topics">
                                    {display_icon('it-more-items', 'svg', 'icon icon-primary right')}
                                </a>
                                <div class="collapse" id="more-topics">
                                {foreach $topic_list_children as $child}
                                    {if and($custom_topic_container, $custom_topic_container.main_node_id|eq($child.item.node_id))}{skip}{/if}
                                    {if $already_displayed|contains($child.item.node_id)|not()}
                                        {include uri='design:parts/search/topic_search_input.tpl' topic=$child topic_facets=$topic_facets checked=false() selected=$params.topic recursion=0}
                                    {/if}
                                {/foreach}
                                </div>
                            {/if}


                            {undef $topics $topic_list $count $max $total $already_displayed $sub_count}

                            {if and($custom_topic_container_item, $custom_topic_container_item.has_children)}
                            <div class="pt-3 pt-lg-3">
                                <h6 class="text-uppercase text-black-50">{$custom_topic_container.name|wash()}</h6>
                                {foreach $custom_topic_container_item.children as $child}
                                    {include uri='design:parts/search/topic_search_input.tpl' topic=$child topic_facets=$topic_facets checked=cond(menu_item_tree_contains($child,$params.topic), true(), false()) selected=$params.topic recursion=0}
                                {/foreach}
                            </div>
                            {/if}
                    </div>
                    {/if}
                {/if}

                {if count($classes)}
                    <div class="{if or(count($top_menu_node_ids), $topics)}pt-4 pt-lg-5{/if}">
                        <h6 class="text-uppercase">{'Content type'|i18n('openpa/search')}</h6>
                        {foreach $classes as $class}
                            {def $count_by_class = 0}
                            {if is_set($class_facets[$class.id])}
                                {set $count_by_class = $class_facets[$class.id]}
                            {/if}
                            {if is_set($params['_class_alias'][$class.id])}
                                {foreach $params['_class_alias'][$class.id] as $add_class_id}
                                    {if is_set($class_facets[$add_class_id])}
                                        {set $count_by_class = $count_by_class|sum($class_facets[$add_class_id])}
                                    {/if}
                                {/foreach}
                            {/if}
                            <div class="form-check custom-control custom-checkbox m-0">
                                <input name="Class[]" id="class-{$class.id}" value={$class.id|wash()} {if $params.class|contains($class.id)}checked="checked"{/if} class="custom-control-input" type="checkbox">
                                <label class="custom-control-label" for="class-{$class.id}">{$class.name|wash()} {if $count_by_class|gt(0)}<small>({$count_by_class|wash()})</small>{/if}</label>
                            </div>
                            {undef $count_by_class}
                        {/foreach}
                    </div>
                {/if}
                
                {if or($params.from,$params.to,$params.only_active)}
                <div class="pt-4 pt-lg-5">
                    <h6 class="text-uppercase">{'Options'|i18n('openpa/search')}</h6>
                    {if $params.only_active}
                        <div class="form-check custom-control custom-checkbox">
                            <input name="OnlyActive" id="onlyactive" value=1 checked="checked" class="custom-control-input" type="checkbox">
                            <label class="custom-control-label" for="onlyactive">{'Active contents'|i18n('openpa/search')}
                        </div>                            
                    {/if}
                    {if $params.from}
                        <div class="form-check custom-control custom-checkbox">
                            <input name="From" id="from" checked="checked" class="custom-control-input" type="checkbox" value="{$params.from|l10n( 'shortdate' )|wash()}">
                            <label class="custom-control-label" for="from">{'from'|i18n('openpa/search')} {$params.from|l10n( 'shortdate' )}
                        </div>                            
                    {/if}
                    {if $params.to}                                
                        <div class="form-check custom-control custom-checkbox">
                            <input name="To" id="to" checked="checked" class="custom-control-input" type="checkbox" value="{$params.to|l10n( 'shortdate' )|wash()}">
                            <label class="custom-control-label" for="to">{'to'|i18n('openpa/search')} {$params.to|l10n( 'shortdate' )}
                        </div>
                    {/if}
                </div>
                {/if}

                <div class="pt-4 pt-lg-5">
                    <button type="submit" class="btn btn-primary">
                        {'Apply filters'|i18n('openpa/search')}
                    </button>
                </div>

            </div>
        </aside>
        
        <section class="col-lg-9">
            <div class="search-results mb-4 pl-lg-5 mt-3 mt-lg-5">
                {if $search.SearchCount|gt(0)}                
                
                    <div class="row">
                        <div class="col-md-12 col-lg-2 mb-3 text-center text-lg-left text-lg-start">
                        {if $search.SearchCount|eq(1)}
                            <p class="m-0 text-nowrap" style="line-height:2"><small>{'Found a result'|i18n('openpa/search')}</small></p>
                        {else}
                            <p class="m-0 text-nowrap" style="line-height:2"><small>{'Found %count results'|i18n('openpa/search',,hash('%count', $search.SearchCount))}</small></p>
                        {/if}
                        </div>
                        <div class="col-sm-12 col-md-5 col-lg-4 mb-4 text-center text-md-right text-md-end">
                            <label class="d-inline-block text-black" for="Sort"><small>{'Sorting by'|i18n('openpa/search')}</small></label>
                            <select class="d-inline-block w-50 form-control form-control-sm" id="Sort" name="Sort">
                                <option {if $params.sort|eq('score')} selected="selected"{/if} value="score">{'Score'|i18n('openpa/search')}</option>
                                <option {if $params.sort|eq('published')} selected="selected"{/if} value="published">{'Publication date'|i18n('openpa/search')}</option>
                                <option {if $params.sort|eq('class_name')} selected="selected"{/if} value="class_name">{'Content type'|i18n('openpa/search')}</option>
                                <option {if $params.sort|eq('name')} selected="selected"{/if} value="name">{'Name'|i18n('openpa/search')}</option>
                            </select>
                        </div>
                        <div class="col-sm-12 col-md-5 col-lg-4 mb-4 text-center text-md-right text-md-end">
                            <label class="d-inline-block text-black" for="Order"><small>{'Sorting'|i18n('openpa/search')}</small></label>
                            <select class="d-inline-block w-50 form-control form-control-sm" id="Order" name="Order">
                                <option {if $params.order|eq('desc')} selected="selected"{/if} value="desc">{'Descending'|i18n('openpa/search')}</option>
                                <option {if $params.order|eq('asc')} selected="selected"{/if} value="asc">{'Ascending'|i18n('openpa/search')}</option>
                            </select>
                        </div>
                        <div class="col-sm-12 col-md-2 col-lg-1 mb-4 text-center text-md-right text-md-end">
                            <button type="submit" class="btn btn-primary btn-xs">
                                {'Apply'|i18n('design/standard/ezoe')}
                            </button>
                        </div>
                    </div>

                    <div class="row row-cols-1 row-cols-md-2">
                        {foreach $search.SearchResult as $child}
                        <div class="col mb-3">
                            {if is_set($child.is_external_data)}
                                {include name=external_data uri='design:parts/search/external_data_search_result.tpl' data=$child}
                            {else}
                                {node_view_gui content_node=$child view=search_result show_icon=true() image_class=widemedium}
                            {/if}
                        </div>
                        {/foreach}
                    </div>

                    {include name=Navigator
                             uri='design:navigator/google.tpl'
                             page_uri='content/search'
                             page_uri_suffix=$params._uri_suffix
                             item_count=$search.SearchCount
                             view_parameters=$view_parameters
                             item_limit=$page_limit}                 
                {else}
                    <p><small>{'No results were found'|i18n('openpa/search')}</small></p>
                    {if $search.SearchExtras.hasError}<div class="alert alert-danger">{$search.SearchExtras.error|wash}</div>{/if}
                {/if}
            </div>
        </section>

    </div>
</form>

{literal}
<script>
$(document).ready(function () {
    $('[data-indeterminate]').prop('indeterminate', true);
    $('[data-checkbox-container]').on('click', function(){
        var isChecked = $(this).is(':checked');
        $(this).parent().next().find('input').prop('checked', isChecked);
    });
    $('[data-checkbox-child]').on('click', function(){        
        var parentDiv = $(this).parents('div.collapse')
        var length = parentDiv.find('input').length;
        var checked = parentDiv.find('input:checked').length;
        var container = parentDiv.prev().find('input');
        if (checked === length){ 
            container.prop('checked', true);
        } else if (checked > 0) {
            container.prop('indeterminate', true);
        } else {
            container.prop('checked', false);
        }
    });
{/literal}
    $('#searchModal').on('search_gui_initialized', function (event, searchGui) {ldelim}
        {if $params.subtree|count()}
        {foreach $params.subtree as $subtree}
        searchGui.activateSubtree({$subtree|strip_tags()|wash(javascript)});
        {/foreach}
        {elseif $params.subtree_boundary}
        searchGui.activateSubtree({$params.subtree_boundary|strip_tags()|wash(javascript)});
        {/if}
        {if $params.topic|count()}
        {foreach $params.topic as $topic}
        searchGui.activateTopic({$topic|strip_tags()|wash(javascript)});
        {/foreach}
        {/if}
        {if $params.from}
        searchGui.activateFrom("{$params.from|l10n( 'shortdate' )|strip_tags()|wash(javascript)}");
        {/if}
        {if $params.to}
        searchGui.activateTo("{$params.to|l10n( 'shortdate' )|strip_tags()|wash(javascript)}");
        {/if}
        {if $params.only_active}
        searchGui.activateActiveContent();
        {/if}
        {if $params.text}
        $('#search-gui-text').val('{$params.text|strip_tags()|wash(javascript)}');
        {/if}
    {rdelim});
{literal}
});    
</script>
{/literal}

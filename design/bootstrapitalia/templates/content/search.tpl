{def $params = parse_search_get_params()
     $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )}

<script>
$(document).ready(function () {ldelim}
    $('#searchModal').on('search_gui_initialized', function (event, searchGui) {ldelim}
        {if $params.subtree|count()}
        {foreach $params.subtree as $subtree}
            searchGui.activateSubtree({$subtree});
        {/foreach}
        {elseif $params.subtree_boundary}
        searchGui.activateSubtree({$params.subtree_boundary});
        {/if}
        {if $params.topic|count()}
        {foreach $params.topic as $topic}
        searchGui.activateTopic({$topic});
        {/foreach}
        {/if}
        {if $params.from}
        searchGui.activateFrom("{$params.from|datetime( 'custom', '%j/%m/%Y' )}");
        {/if}
        {if $params.to}
        searchGui.activateTo("{$params.to|datetime( 'custom', '%j/%m/%Y' )}");
        {/if}
        {if $params.only_active}
        searchGui.activateActiveContent();
        {/if}
        {if $params.text}
        $('#search-gui-text').val('{$params.text|wash()}');
        {/if}
    {rdelim});
{rdelim});
</script>

{set $page_limit = 20}
{def $filters = array()
     $search_hash = $params._search_hash|merge(hash('offset', $view_parameters.offset,'limit', $page_limit ))
     $search = fetch( ezfind, search, $search_hash )}

{def $classes = array()}
{if $params.class|count()}
    {set $classes = fetch(class, list, hash(class_filter, $params.class))}
{/if}

<div class="row">
    <div class="col-12 px-lg-4 py-lg-2">
        <form class="mt-3 mb-5" action="{'content/search'|ezurl(no)}" method="get">
            <div class="form-group floating-labels">
                <div class="form-label-group">
                    <input type="text"
                           class="form-control"
                           id="search-text"
                           name="SearchText"
                           value="{$params.text|wash()}"
                           placeholder="Cerca"
                           aria-invalid="false"/>
                    <label class="" for="search-text">
                        Cerca
                    </label>
                    <button type="submit" class="autocomplete-icon btn btn-link">
                        {display_icon('it-search', 'svg', 'icon')}
                    </button>
                </div>
            </div>

            <div class="section-search-form-filters">
                <h6 class="small">Filtri</h6>
                <a href="#" class="chip chip-lg selected selected no-minwith"
                   data-section_subtree_group="all">
                    <span class="chip-label">Tutto</span>
                </a>
                <a href="#"
                   class="btn btn-outline-primary btn-icon btn-xs align-top ml-1 mt-1"
                   id="toggleSearch">
                    {display_icon('it-plus', 'svg', 'icon icon-primary mr-1')} Aggiungi filtro
                </a>
            </div>
            {foreach $classes as $class}
                <input type="hidden" name="Class[]" value="{$class.id}" />
            {/foreach}
        </form>
        <h2>Risultati della ricerca</h2>
    </div>
</div>

{def $subtree_facets = $search.SearchExtras.facet_fields[0].countList
     $topic_facets = $search.SearchExtras.facet_fields[1].countList}

<div class="row border-top row-column-border row-column-menu-left attribute-list">
    <aside class="col-lg-3 col-md-4">
        {if count($classes)}
            <div class="link-list-wrapper pt-4">
                <ul class="link-list">
                    <li>
                        <h3 class="text-uppercase">Tipo di contenuto</h3>
                    </li>                    
                    {foreach $classes as $class}
                        <li>
                            <a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item" href="{concat('content/search?', filtered_search_params_query_string($params, hash('class', $class.id)))|ezurl(no)}">
                                {display_icon('it-close', 'svg', 'icon icon-primary icon-sm mr-1')}
                                {$class.name|wash()}
                            </a>
                        </li>
                    {/foreach}
                </ul>
            </div>
        {/if}
        {if or($params.subtree|count(), $params.subtree_boundary)}
        <div class="link-list-wrapper pt-4">
            <ul class="link-list">
                <li>
                    <h3 class="text-uppercase">Sezioni</h3>
                </li>
                {foreach $top_menu_node_ids as $id}
                    {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu'))
                         $display = false()}
                    {if or($params.subtree_boundary|eq($id), $params.subtree|contains($id))}
                        {set $display = true()}
                    {else}
                        {foreach $tree_menu.children as $child}
                            {if $params.subtree|contains($child.item.node_id)}
                                {set $display = true()}
                                {break}
                            {/if}
                        {/foreach}
                    {/if}
                    {if $display}
                        {def $top_menu_node = fetch(content, node, hash(node_id, $id))}
                        <li>
                            <a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item right-icon" href="#dropdown-search-{$top_menu_node.node_id}" data-toggle="collapse" aria-expanded="false" aria-controls="dropdown-search-{$top_menu_node.node_id}">
                                {*display_icon($top_menu_node|attribute('icon').content|wash(), 'svg', 'icon icon-primary icon-sm mr-1')*}
                                <span>{$top_menu_node.name|wash()} {if is_set($subtree_facets[$id])}({$subtree_facets[$id]}){/if}</span>
                                {display_icon('it-expand', 'svg', 'icon icon-primary right m-0')}
                            </a>
                            <ul class="link-sublist collapse" id="dropdown-search-{$top_menu_node.node_id}">
                                {foreach $tree_menu.children as $child}
                                    {if or($params.subtree|contains($child.item.node_id), count($params.subtree)|eq(0))}
                                        <li><a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item" href="#">{$child.item.name|wash()} {if is_set($subtree_facets[$child.item.node_id])}({$subtree_facets[$child.item.node_id]}){/if}</a></li>
                                    {/if}
                                {/foreach}
                            </ul>
                        </li>
                        {undef $top_menu_node}
                    {/if}
                    {undef $tree_menu $display}
                {/foreach}
            </ul>
        </div>
        {/if}
        {if $params.topic|count()}
        <div class="link-list-wrapper pt-4">
            <ul class="link-list">
                <li>
                    <h3 class="text-uppercase">Argomenti</h3>
                </li>
                {def $topics = fetch(content, object, hash(remote_id, 'topics'))
                     $topic_list = tree_menu( hash( 'root_node_id', $topics.main_node_id, 'scope', 'side_menu'))}
                {foreach $topic_list.children as $child}
                    {if $params.topic|contains($child.item.node_id)}
                        <li><a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item" href="#">{$child.item.name|wash()} {if is_set($topic_facets[$child.item.node_id])}({$topic_facets[$child.item.node_id]}){/if}</a></li>
                    {/if}
                {/foreach}
                {undef $topics $topic_list}
            </ul>
        </div>
        {/if}
        {if or($params.from,$params.to,$params.only_active)}
        <div class="link-list-wrapper pt-4">
            <ul class="link-list">
                <li>
                    <h3 class="text-uppercase">Opzioni</h3>
                </li>
                {if $params.only_active}
                    <li><a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item" href="#">{display_icon('it-settings', 'svg', 'icon icon-primary icon-sm mr-1')} Contenuti attivi</a></li>
                {/if}
                {if $params.from}
                    <li>
                        <a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item" href="#">
                            {display_icon('it-calendar', 'svg', 'icon icon-primary icon-sm mr-1')}
                            Da {$params.from|datetime( 'custom', '%j/%m/%Y' )}
                        </a>
                    </li>
                {/if}
                {if $params.to}
                    <li>
                        <a style="line-height: 1.5em;padding: 5px 24px;" {*TODO*} class="list-item" href="#">
                            {display_icon('it-calendar', 'svg', 'icon icon-primary icon-sm mr-1')}
                            Fino a {$params.to|datetime( 'custom', '%j/%m/%Y' )}
                        </a>
                    </li>
                {/if}
            </ul>
        {/if}
    </aside>
    <section class="col-lg-9 col-md-8">
        {if $search.SearchCount|gt(0)}
            {if $search.SearchCount|eq(1)}
                <p><small>Trovato un risultato</small></p>
            {else}
                <p><small>Trovati {$search.SearchCount} risultati</small></p>
            {/if}
            {foreach $search.SearchResult as $result}
                {node_view_gui view=search_result content_node=$result}
            {/foreach}

            {include name=Navigator
                     uri='design:navigator/google.tpl'
                     page_uri='content/search'
                     page_uri_suffix=$params._uri_suffix
                     item_count=$search.SearchCount
                     view_parameters=$view_parameters
                     item_limit=$page_limit}
        {else}
            <p><small>Nessun risultato ottenuto</small></p>
            {if $search.SearchExtras.hasError}<div class="alert alert-danger">{$search.SearchExtras.error|wash}</div>{/if}
        {/if}

    </section>
</div>
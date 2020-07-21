{def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )
     $topics = fetch(content, object, hash(remote_id, 'topics'))
     $topic_list = cond($topics, tree_menu( hash( 'root_node_id', $topics.main_node_id, 'scope', 'side_menu')), array())
     $topic_menu_label_extended = 'All topics...'|i18n('bootstrapitalia')
     $topic_menu_label = 'Topics'|i18n('bootstrapitalia')}

{if $pagedata.homepage|has_attribute('topic_menu_label')}
    {set $topic_menu_label = $pagedata.homepage|attribute('topic_menu_label').content
         $topic_menu_label_extended = $topic_menu_label}
{/if}

<div class="modal modal-fullscreen modal-search" tabindex="-1" role="dialog" id="searchModal">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header my-3">
                <div class="container">
                    <div class="row">
                        <div class="offset-md-12 col-sm-12 text-center pb12 search-gui-header">
                            <button class="close float-left mt-1" type="button" data-dismiss="modal" aria-label="Close">
                                {display_icon('it-arrow-left-circle', 'svg', 'icon')}
                            </button>
                            <button class="back-to-search hide float-left mt-1" type="button">
                                {display_icon('it-arrow-left-circle', 'svg', 'icon')}
                                <span class="close-help">Cerca</span>
                            </button>
                            <h1 class="d-none d-sm-block">Cerca</h1>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-body p-0">
                <form action="{'content/search'|ezurl(no)}" method="get">
                    <div class="container search-gui">
                        <div class="row">
                            <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                <div class="form-group floating-labels">
                                    <div class="form-label-group">
                                        <input type="text"
                                               class="form-control"
                                               id="search-gui-text"
                                               name="SearchText"
                                               placeholder="Cerca"
                                               aria-invalid="false"/>
                                        <label class="" for="search-gui-text">
                                            Cerca
                                        </label>
                                        <button type="submit" class="autocomplete-icon btn btn-link">
                                            {display_icon('it-search', 'svg', 'icon')}
                                        </button>
                                    </div>
                                </div>

                                <div class="search-filter-by-section mt-4">
                                    <h6 class="small">Sezioni</h6>
                                    <a href="#" class="btn btn-outline-primary btn-icon btn-xs mr-2 mb-2 selected"
                                       data-subtree_group="all">Tutto</a>
                                    {foreach $top_menu_node_ids as $id}
                                        {def $top_menu_node = fetch(content, node, hash(node_id, $id))}
                                        <a href="#"
                                           class="btn btn-outline-primary btn-icon btn-xs mr-2 mb-2"
                                           data-subtree_group="{$id}">
                                            {if $top_menu_node|has_attribute('icon')}
                                                {display_icon($top_menu_node|attribute('icon').content|wash(), 'svg', 'icon icon-primary mr-1')}
                                            {/if}
                                            {$top_menu_node.name|wash()}
                                        </a>
                                        {undef $top_menu_node}
                                    {/foreach}
                                    <a href="#"
                                       class="btn btn-outline-primary btn-icon btn-xs mr-2 mb-2 px-3 trigger-subtree">...</a>
                                </div>

                                <div class="search-filter-by-topic mt-5">
                                    <h6 class="small">{$topic_menu_label|wash()}</h6>
                                    <a href="#" class="chip chip-simple chip-lg selected">
                                        <span class="chip-label">{$topic_menu_label_extended|wash()}</span>
                                    </a>
                                    <a href="#" class="chip chip-simple chip-lg chip-trigger trigger-topic">
                                        <span class="chip-label">...</span>
                                    </a>
                                </div>

                                <div class="search-filter-by-option mt-5">
                                    <h6 class="small">Opzioni</h6>
                                    <a href="#" class="chip chip-simple chip-lg selected">
                                        <span class="chip-label">Tutte le date</span>
                                    </a>
                                    <a href="#" class="chip chip-simple chip-lg chip-trigger trigger-option">
                                        <span class="chip-label">...</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="filters-gui hide container position-relative">
                        <div class="nav-tabs-hidescroll w-100">
                            <div class="row">
                                <div class="col-12">
                                    <ul class="nav nav-tabs auto" role="tablist">
                                        <li class="nav-item">
                                            <a role="tab" data-toggle="tab" class="nav-link active"
                                               href="#filter-by-section">
                                                Sezioni
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a role="tab" data-toggle="tab" class="nav-link"
                                               href="#filter-by-topic">
                                                {$topic_menu_label|wash()}
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a role="tab" data-toggle="tab" class="nav-link"
                                               href="#filter-by-option">
                                                Opzioni
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <button class="do-search btn btn-outline-primary btn-icon btn-sm mt-3" style="position: absolute;top: -84px;z-index: 100;right: 10px;" type="submit">Conferma</button>
                        <div class="tab-content mt-5">
                            <div class="tab-pane active" id="filter-by-section">
                                <div class="row">
                                    <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                        <div class="row">
                                    {foreach $top_menu_node_ids as $id}
                                        {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu'))}
                                        <div class="col-md-6 mb-5" data-subtree_group="{$tree_menu.item.node_id}">
                                            <div class="form-check custom-control custom-checkbox">
                                                <input id="subtree-filter-{$tree_menu.item.node_id}"
                                                       type="checkbox"
                                                       name="Subtree[]"
                                                       value="{$tree_menu.item.node_id}"
                                                       class="custom-control-input"
                                                       data-subtree="{$tree_menu.item.node_id}">
                                                <label for="subtree-filter-{$tree_menu.item.node_id}" class="custom-control-label">
                                                    <strong class="text-primary">{$tree_menu.item.name|wash()}</strong>
                                                </label>
                                            </div>
                                            {if $tree_menu.has_children}
                                                {foreach $tree_menu.children as $child}
                                                    {if $child.item.node_id|eq($tree_menu.item.node_id)}{skip}{/if} {*tag menu*}
                                                    <div class="form-check">
                                                        <input id="subtree-filter-{$child.item.node_id}"
                                                               type="checkbox"
                                                               class="form-check-input"
                                                               name="Subtree[]"
                                                               value="{$child.item.node_id}"
                                                               data-subtree="{$child.item.node_id}"
                                                               data-main_subtree="{$tree_menu.item.node_id}">
                                                        <label for="subtree-filter-{$child.item.node_id}" class="form-check-label">
                                                            {$child.item.name|wash()}
                                                        </label>
                                                    </div>
                                                {/foreach}
                                            {/if}
                                        </div>
                                        {undef $tree_menu}
                                    {/foreach}
                                </div>
                                    </div>
                                </div>
                            </div>
                            <div class="tab-pane" id="filter-by-topic">
                                <div class="row">
                                    <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                        {if count($topic_list)|gt(0)}
                                        {def $max = count($topic_list.children)|div(2)|ceil()}
                                        <div class="row">
                                            <div class="col-md-6">
                                            {foreach $topic_list.children as $child max $max}                                            
                                                <div class="form-check">
                                                    <input id="topic-filter-{$child.item.node_id}"
                                                           type="checkbox"
                                                           class="form-check-input"
                                                           name="Topic[]"
                                                           value="{$child.item.node_id}"
                                                           data-topic="{$child.item.node_id}">
                                                    <label for="topic-filter-{$child.item.node_id}" class="form-check-label">
                                                        {$child.item.name|wash()}
                                                    </label>
                                                </div>
                                            {/foreach}
                                            </div>
                                            <div class="col-md-6">
                                            {foreach $topic_list.children as $child offset $max}
                                                <div class="form-check">
                                                    <input id="topic-filter-{$child.item.node_id}"
                                                           type="checkbox"
                                                           class="form-check-input"
                                                           name="Topic[]"
                                                           value="{$child.item.node_id}"
                                                           data-topic="{$child.item.node_id}">
                                                    <label for="topic-filter-{$child.item.node_id}" class="form-check-label">
                                                        {$child.item.name|wash()}
                                                    </label>
                                                </div>                                        
                                            {/foreach}
                                            </div>
                                        </div>
                                        {undef $max}
                                        {/if}
                                    </div>
                                </div>
                            </div>
                            <div class="tab-pane" id="filter-by-option">
                                <div class="row">
                                    <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                        <div class="row">
                                    <div class="col-md-12 col-sm-12 mb-4">
                                        <div class="form-check form-check-group">
                                            <div class="toggles">
                                                <label for="OnlyActive">
                                                    Cerca solo tra i contenuti attivi
                                                    <input type="checkbox" id="OnlyActive" name="OnlyActive" value="1">
                                                    <span class="lever"></span>
                                                </label>
                                            </div>
                                        </div>
                                        <p class="small">Verranno esclusi dalla ricerca i contenuti archiviati e non più
                                            validi come gli eventi terminati o i bandi scaduti.</p>
                                    </div>
                                    <div class="col-md-6 col-sm-12 mb-4">
                                        <div class="it-datepicker-wrapper">
                                            <div class="form-group">
                                                <label for="datepicker_start">Data inizio</label>
                                                <input class="form-control it-date-datepicker" id="datepicker_start" type="text" name="From" placeholder="inserisci la data in formato gg/mm/aaaa" value="">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 col-sm-12 mb-4">
                                        <div class="it-datepicker-wrapper">
                                            <div class="form-group">
                                                <label for="datepicker_end">Data fine</label>
                                                <input class="form-control it-date-datepicker" id="datepicker_end" type="text" name="To" placeholder="inserisci la data in formato gg/mm/aaaa" value="">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>


{literal}
<script>
$(document).ready(function () {
    $('#searchModal').searchGui({'spritePath': '{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}'});
});
</script>
{/literal}

{undef $top_menu_node_ids $topics $topic_list $topic_menu_label $topic_menu_label_extended}


{* https://github.com/blueimp/Gallery vedi atom/gallery.tpl *}
<div id="blueimp-gallery" class="blueimp-gallery blueimp-gallery-controls">
    <div class="slides"></div>
    <h3 class="title"><span class="sr-only">gallery</span></h3>
    <a class="prev">‹</a>
    <a class="next">›</a>
    <a class="close">×</a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
</div>

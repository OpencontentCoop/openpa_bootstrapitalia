{def $top_menu_node_ids = array()
	 $selected_topic_list = array()
	 $topic_menu_label = 'Tutti gli argomenti...'
	 $topics = false()
	 $topic_list = array()}

{if and( $pagedata.is_login_page|not(), array( 'edit', 'browse' )|contains( $ui_context )|not(), openpaini( 'TopMenu', 'ShowMegaMenu', 'enabled' )|eq('enabled') )}
    {def $is_area_tematica = is_area_tematica()}
    {if and($is_area_tematica, $is_area_tematica|has_attribute('link_al_menu_orizzontale'))}
        {set $top_menu_node_ids = array()}
        {foreach $is_area_tematica|attribute('link_al_menu_orizzontale').content.relation_list as $item}
            {set $top_menu_node_ids = $top_menu_node_ids|append($item.node_id)}
        {/foreach}
    {else}
        {set $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )}
    {/if}
    {undef $is_area_tematica}

    {if $pagedata.homepage|has_attribute('topics')}
        {foreach $pagedata.homepage|attribute('topics').content.relation_list as $item}
            {set $selected_topic_list = $selected_topic_list|append(fetch(content, node, hash(node_id, $item.node_id)))}
        {/foreach}
    {/if}

    {if $pagedata.homepage|has_attribute('topic_menu_label')}
        {set $topic_menu_label = $pagedata.homepage|attribute('topic_menu_label').content}
    {/if}

    {set $topics = fetch(content, object, hash(remote_id, 'topics'))
         $topic_list = cond(and($topics, count($selected_topic_list)|eq(0)), tree_menu( hash( 'root_node_id', $topics.main_node_id, 'scope', 'side_menu')), array())}

{/if}

<div class="it-header-navbar-wrapper{* theme-light*}">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <nav class="navbar navbar-expand-lg has-megamenu">
                    <button class="custom-navbar-toggler"
                            type="button"
                            aria-controls="main-menu"
                            aria-expanded="false"
                            aria-label="Toggle navigation"
                            data-target="#main-menu">
                        {display_icon('it-burger', 'svg', 'icon')}
                    </button>
                    <div class="navbar-collapsable" id="main-menu">
                        <div class="overlay"></div>
                        <div class="menu-wrapper">
                            <div class="close-div">
                                <button class="btn close-menu" type="button">
                                    {display_icon('it-close-circle', 'svg', 'icon')}
                                </button>
                            </div>
                            <ul class="navbar-nav">
                            {foreach $top_menu_node_ids as $id}
                                {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'top_menu'))}
                                {include name=top_menu
                                         uri='design:header/menu_item.tpl'
                                         show_children=false()
                                         menu_item=$tree_menu}
                                {undef $tree_menu}
                            {/foreach}
                            </ul>
                            {if or(count($topic_list)|gt(0), count($selected_topic_list)|gt(0))}
                            <ul class="navbar-nav navbar-secondary">
                                {if count($selected_topic_list)|gt(0)}
                                    {foreach $selected_topic_list as $selected_topic max 3}
                                    <li class="nav-item">
                                        <a class="nav-link text-truncate" href="{$selected_topic.url_alias|ezurl(no)}">
                                            <span>{$selected_topic.name|wash()}</span>
                                        </a>
                                    </li>
                                    {/foreach}
                                {elseif $pagedata.homepage|has_attribute('topic_menu_label')|not()}
                                    {foreach $topic_list.children as $child max 3}
                                    <li class="nav-item">
                                        <a class="nav-link text-truncate" href="{$child.item.url|ezurl(no)}">
                                            <span>{$child.item.name|wash()}</span>
                                        </a>
                                    </li>
                                    {/foreach}
                                {/if}
                                <li class="nav-item">
                                    <a class="nav-link text-truncate" href="{$topics.main_node.url_alias|ezurl(no)}">
                                        <span class="font-weight-bold">{$topic_menu_label|wash}</span>
                                    </a>
                                </li>                                
                            </ul>
                            {/if}
                        </div>
                    </div>
                </nav>
            </div>
        </div>
    </div>
</div>
<script>{literal}
$(document).ready(function() {
    $('#main-menu a').each(function (e) {
        var node = $(this).data('node');
        if (node) {
            var href = $(this).attr('href');
            if (UiContext === 'browse') {
                href = '/content/browse/' + node;
            }
            $(this).attr('href', href);
            var self = $(this);
            $.each(PathArray, function (i, v) {
                if (v === node) {
                    self.addClass('active').parents('li').addClass('active');
                    if (i === 0)
                        self.addClass('active').parents('li').addClass('active');
                }
            });
        }
    });
});
{/literal}</script>
{undef $top_menu_node_ids $topics $topic_list}
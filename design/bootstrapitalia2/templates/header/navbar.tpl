{def $top_menu_node_ids = array()
	 $selected_topic_list = array()
	 $topic_menu_label = 'All topics...'|i18n('bootstrapitalia')
	 $topics = false()
	 $topic_list = array()
     $show_topic_menu = true()
     $show_children = false()}

{if $pagedata.homepage|has_attribute('show_extended_menu')}
    {set $show_children = cond($pagedata.homepage|attribute('show_extended_menu').data_int|eq(1), true(), false())}
{/if}

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

    {if $pagedata.homepage|has_attribute('hide_topic_menu')}
        {set $show_topic_menu = cond($pagedata.homepage|attribute('hide_topic_menu').data_int|eq(1), false(), true())}
    {/if}

    {if $show_topic_menu}
        {if $pagedata.homepage|has_attribute('topics')}
            {foreach $pagedata.homepage|attribute('topics').content.relation_list as $item}
                {def $selected_topic = fetch(content, node, hash(node_id, $item.node_id))}
                {if $selected_topic.object.section_id|eq(1)}
                    {set $selected_topic_list = $selected_topic_list|append($selected_topic)}
                {/if}
                {undef $selected_topic}
            {/foreach}
        {/if}

        {if $pagedata.homepage|has_attribute('topic_menu_label')}
            {set $topic_menu_label = $pagedata.homepage|attribute('topic_menu_label').content}
        {/if}

        {set $topics = fetch(content, object, hash(remote_id, 'topics'))
             $topic_list = cond(and($topics, count($selected_topic_list)|eq(0)), tree_menu( hash( 'root_node_id', $topics.main_node_id, 'user_hash', false(), 'scope', 'side_menu')), array())}
    {/if}
{/if}
<div id="header-nav-wrapper" class="it-header-navbar-wrapper{if current_theme_has_variation('light_center')} theme-light{/if} {if current_theme_has_variation('light_navbar')} theme-light-desk border-bottom{/if}">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <nav class="navbar navbar-expand-lg has-megamenu" aria-label="{'Main menu'|i18n('bootstrapitalia')}">
                    <button class="custom-navbar-toggler"
                            type="button"
                            aria-controls="main-menu"
                            aria-expanded="false"
                            aria-label="{'Toggle navigation'|i18n('bootstrapitalia')}"
                            title="{'Toggle navigation'|i18n('bootstrapitalia')}"
                            data-bs-target="#main-menu"
                            data-bs-toggle="navbarcollapsible">
                        {display_icon('it-burger', 'svg', 'icon')}
                    </button>
                    <div class="navbar-collapsable" id="main-menu">
                        <div class="overlay" style="display: none;"></div>
                        <div class="close-div">
                            <button class="btn close-menu" type="button">
                                <span class="visually-hidden">{'hide navigation'|i18n('bootstrapitalia')}</span>
                                {display_icon('it-close-big', 'svg', 'icon')}
                            </button>
                        </div>
                        <div class="menu-wrapper">
                            {include uri='design:header/menu_logo.tpl'}
                            <ul class="navbar-nav" data-element="main-navigation">
                            {foreach $top_menu_node_ids as $id}
                                {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'top_menu'))}
                                {include name=top_menu
                                         uri='design:header/menu_item.tpl'
                                         show_children=$show_children
                                         menu_item=$tree_menu}
                                {undef $tree_menu}
                            {/foreach}
                            </ul>
                            {if $show_topic_menu}
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
                                        <a class="nav-link text-truncate" href="{$topics.main_node.url_alias|ezurl(no)}" data-element="all-topics">
                                            <span class="fw-bold">{$topic_menu_label|wash}</span>
                                        </a>
                                    </li>
                                </ul>
                                {/if}
                            {/if}
                            {include uri='design:header/social.tpl' split_at=6}
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
                    if (i === 0) {
                        self.addClass('active').parents('li').addClass('active');
                    }
                }
            });
        }
    });
});
{/literal}</script>
{undef $top_menu_node_ids $topics $topic_list}
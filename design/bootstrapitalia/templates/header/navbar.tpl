{def $top_menu_node_ids = array()}

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
                        <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-burger"></use></svg>
                    </button>
                    <div class="navbar-collapsable" id="main-menu">
                        <div class="overlay"></div>
                        <div class="menu-wrapper">
                            <div class="close-div">
                                <button class="btn close-menu" type="button">
                                    <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-close-circle"></use></svg>
                                </button>
                            </div>
                            <ul class="navbar-nav">
                            {foreach $top_menu_node_ids as $id}
                                {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'top_menu'))}
                                {include recursion=0
                                         name=top_menu
                                         uri='design:header/menu_item.tpl'
                                         menu_item=$tree_menu}
                                {undef $tree_menu}
                            {/foreach}
                            </ul>
                        </div>
                    </div>
                </nav>
            </div>
        </div>
    </div>
</div>

{undef $top_menu_node_ids}
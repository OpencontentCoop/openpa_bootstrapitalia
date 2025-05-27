{def $top_menu_tree = array()}
{def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array())}
{if count($top_menu_node_ids)|gt(0)}
    {foreach $top_menu_node_ids as $id}
        {set $top_menu_tree = $top_menu_tree|append(tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu', 'hide_empty_tag', true(), 'hide_empty_tag_callback', array('OpenPABootstrapItaliaOperators', 'tagTreeHasContents'))))}
    {/foreach}
{/if}
{undef $top_menu_node_ids}

{def $use_auto_menu = cond(openpaini('GeneralSettings','FooterAutoMenu', 'disabled')|eq('enabled'), true(), false())}
{if $pagedata.homepage|attribute('use_auto_footer_menu')}
    {set $use_auto_menu = cond($pagedata.homepage|attribute('use_auto_footer_menu').data_int|eq(1), true(), false())}
{/if}

<div class="row">
    {if and(count($top_menu_tree), $use_auto_menu)}
        {foreach $top_menu_tree as $tree_menu}
            <div class="col-md-3 footer-items-wrapper">
                {include recursion=0
                         name=top_menu
                         uri='design:footer/menu_item.tpl'
                         menu_item=$tree_menu
                         show_main_link=true()
                         show_more=true()
                         max=5
                         offset=0}
            </div>
        {/foreach}
    {elseif count($top_menu_tree)}
        <div class="col-md-3 footer-items-wrapper">
            <h3 class="footer-heading-title">
                {$top_menu_tree[0].item.name|wash()}
            </h3>
            {include recursion=0
                     name=top_menu
                     uri='design:footer/menu_item.tpl'
                     menu_item=$top_menu_tree[0]
                     show_main_link=false()
                     show_more=true()
                     max=8
                     offset=0}
        </div>
        <div class="col-md-6 footer-items-wrapper">
            <h3 class="footer-heading-title">
                {$top_menu_tree[2].item.name|wash()}
            </h3>
            <div class="row">
                <div class="col-md-6">
                    {include recursion=0
                             name=top_menu
                             uri='design:footer/menu_item.tpl'
                             menu_item=$top_menu_tree[2]
                             show_main_link=false()
                             show_more=false()
                             max=8
                             offset=0}
                </div>
                <div class="col-md-6">
                    {if count($top_menu_tree[2].children)|gt(8)}
                        {include recursion=0
                                 name=top_menu
                                 uri='design:footer/menu_item.tpl'
                                 menu_item=$top_menu_tree[2]
                                 show_main_link=false()
                                 show_more=true()
                                 max=8
                                 offset=8}
                    {/if}
                </div>
            </div>
        </div>
        <div class="col-md-3 footer-items-wrapper">
            <h3 class="footer-heading-title">
                {$top_menu_tree[1].item.name|wash()}
            </h3>
            {include recursion=0
                     name=top_menu
                     uri='design:footer/menu_item.tpl'
                     menu_item=$top_menu_tree[1]
                     show_main_link=false()
                     show_more=true()
                     max=3
                     offset=0}
            <h3 class="footer-heading-title">
                {$top_menu_tree[3].item.name|wash()}
            </h3>
            {include recursion=0
                     name=top_menu
                     uri='design:footer/menu_item.tpl'
                     menu_item=$top_menu_tree[3]
                     show_main_link=false()
                     show_more=true()
                     max=2
                     offset=0}
        </div>
    {/if}
</div>
{undef $top_menu_tree $use_auto_menu}
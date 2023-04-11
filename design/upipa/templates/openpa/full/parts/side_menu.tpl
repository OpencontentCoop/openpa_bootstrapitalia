{def $exp = false()}
{if or($node|has_attribute('image'), $node|has_attribute('abstract'), $node|has_attribute('description'))}
    {set $exp = true()}
{/if}


<aside id="section-menu">
    <nav class="section-menu mb-4">
        <div class="collapse-header border-0 px-0" id="heading-side_menu">
            <button class="border-0" data-toggle="collapse" data-target="#collapse-side_menu" aria-expanded="{if $exp}true{else}false{/if}" aria-controls="collapse-side_menu">
                {$tree_menu.item.name|wash()}
            </button>
        </div>
        <div id="collapse-side_menu" class="collapse {if $exp}show{/if}" aria-labelledby="heading-side_menu">
            <div class="collapse-body p-0">
                <div class="link-list-wrapper">
                    <ul class="link-list">
                    {def $tree_menu_children = $tree_menu.children}
                    {foreach $tree_menu_children as $menu_item}
                        {include name=side_menu uri='design:openpa/full/parts/side_menu_item.tpl' menu_item=$menu_item current_node=$node max_recursion=1 recursion=1}
                    {/foreach}
                    {undef $tree_menu_children}
                    </ul>
                </div>
            </div>
        </div>
    </nav>
</aside>

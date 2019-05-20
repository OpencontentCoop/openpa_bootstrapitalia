{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'narrow_container', true() )}

{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.control_menu.side_menu.root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $show_left = cond(count( $tree_menu.children )|gt(0), true(), false())}
{if $show_left}
    {ezpagedata_set( 'has_section_menu', true() )}
{/if}

<section id="intro">
    <div class="container">
        <div class="row">
            <div class="offset-lg-1 col-lg-6 col-md-7">
                <div class="section-title">

                    <h2>{$node.name|wash()}</h2>

                    {if $node|has_attribute('abstract')}
                        {attribute_view_gui attribute=$node|attribute('abstract')}
                    {/if}

                    {if $node.children_count|gt(0)}
                    {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node}
                    {/if}

                    {if $node|has_attribute('description')}
                        {attribute_view_gui attribute=$node|attribute('description')}
                    {/if}

                </div>
            </div>
            <div class="offset-lg-1 col-lg-3 offset-lg-1 offset-md-1 col-md-4">
                {if $show_left}
                    {include uri='design:openpa/full/parts/side_menu.tpl'}
                {/if}
            </div>
        </div>
</section>

{if $node|has_attribute('layout')}
    {attribute_view_gui attribute=$node|attribute('layout')}
{/if}

{if $node|has_attribute('show_children')}
    <section>
        <div class="container">
            {if $node|has_attribute('menu_name')}
            <div class="row">
                <div class="col-md-12">
                    <div class="section-title">
                            <h3>{$node|attribute('menu_name').content|wash()}</h3>
                    </div>
                </div>
            </div>
            {/if}
            {node_view_gui content_node=$node view=children view_parameters=$view_parameters}
        </div>
    </section>
{/if}
{ezpagedata_set( 'has_container', true() )}

{def $root_node = $openpa.control_menu.side_menu.root_node}
{if or($root_node|not(), $root_node.class_identifier|ne('trasparenza'))}
    {set $root_node = fetch('content', 'tree', hash(
        parent_node_id, 1,
        class_filter_type, 'include',
        class_filter_array, array('trasparenza'),
        limit, 1,
        load_data_map, false()
    ))[0]}
{/if}
{def $tree_menu = tree_menu( hash( 'root_node_id', $root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $menu_type = openpaini('SideMenu', 'AmministrazioneTrasparenteTipoMenu', 'default')}
{if and($root_node|has_attribute('show_browsable_menu'), $root_node|attribute('show_browsable_menu').data_int|eq(1))}
    {set $menu_type = 'browsable'}
{/if}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            {include uri='design:openpa/full/parts/amministrazione_trasparente/intro.tpl' node=$root_node}
            {include uri='design:openpa/full/parts/info.tpl'}
        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

<section class="container">
    <div class="row border-top row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="d-block d-lg-none d-xl-none text-center mb-2">
                <a href="#toogle-sidemenu" role="button" class="btn btn-primary btn-md collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="toogle-sidemenu"><i class="fa fa-bars" aria-hidden="true"></i> {$tree_menu.item.name|wash()}</a>
            </div>
            <div class="d-lg-block d-xl-block collapse" id="toogle-sidemenu">
                <div class="link-list-wrapper menu-link-list pt-2">
                    <ul class="link-list">
                        {foreach $tree_menu.children as $menu_item}
                            {include name=side_menu
                                     uri=cond($menu_type|eq('browsable'), 'design:openpa/full/parts/browsable_side_menu_item.tpl', 'design:openpa/full/parts/side_menu_item.tpl')
                                     menu_item=$menu_item
                                     current_node=$node
                                     max_recursion=3
                                     recursion=1}
                        {/foreach}
                    </ul>
                </div>
            </div>
        </aside>
        <section class="col-lg-8 p-4">
            <h2 class="mb-4">{$node.name|wash()}</h2>
            {include uri='design:openpa/full/parts/attributes_flat.tpl'
                     object=$node.object
                     show_all_attributes=cond(class_extra_parameters($node.class_identifier, 'table_view').enabled, false(), true())}

            {def $find_nota = fetch('content', 'list', hash(
                'parent_node_id', $node.main_node_id,
                'class_filter_type', 'include',
                'class_filter_array', array('nota_trasparenza'),
                'limit', 1
            ))}
            {if is_set($find_nota[0])}
                <div class="callout w-100 mw-100 danger">
                    <div class="callout-title">
                        {display_icon('it-help-circle', 'svg', 'icon')}{'Note'|i18n('bootstrapitalia')}
                        {include uri="design:parts/toolbar/node_edit.tpl" current_node=$find_nota[0]}
                        {include uri="design:parts/toolbar/node_trash.tpl" current_node=$find_nota[0]}
                    </div>
                    <div class="text-serif small neutral-1-color-a7 mb-3">
                        <em>{attribute_view_gui attribute=$find_nota[0].data_map.testo_nota}</em>
                        {if $find_nota[0]|has_attribute('file')}
                            <span>{attribute_view_gui attribute=$find_nota[0]|attribute('file')}</span>
                        {/if}
                    </div>
                </div>
            {/if}
            {undef $find_nota}

            {def $node_children_count = $node.children_count}
            {if $node_children_count}
            <div class="mt-5">
            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                nodes=fetch('content', 'list', hash(
                    'parent_node_id', $node.main_node_id,
                    'class_filter_type', 'exclude',
                    'class_filter_array', array('nota_trasparenza'),
                    'limit', openpaini( 'GestioneFigli', 'limite_paginazione', 25 ),
                    'offset', $view_parameters.offset,
                    'sort_by', $node.sort_array
                ))
                nodes_count=$node_children_count}
            </div>
            {/if}
            {undef $node_children_count}

            <div class="mt-5">
                {include uri=$openpa['content_show_published'].template}
                {include uri=$openpa['content_show_modified'].template}
            </div>
        </section>
    </div>
</section>

{undef $root_node $tree_menu}
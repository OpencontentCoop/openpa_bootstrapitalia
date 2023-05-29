{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path', false() )}

{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.control_menu.side_menu.root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $summary_items = array()
     $table_view = class_extra_parameters($node.class_identifier, 'table_view')}
{foreach $table_view.show as $attribute_identifier}
    {if or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty)}
        {set $summary_items = $summary_items|append(
            hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
        )}
    {/if}
{/foreach}

{def $menu_type = openpaini('SideMenu', 'AmministrazioneTrasparenteTipoMenu', 'default')}
{if and($node|has_attribute('show_browsable_menu'), $node|attribute('show_browsable_menu').data_int|eq(1))}
    {set $menu_type = 'browsable'}
{/if}

<section class="container pt-5">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

{include uri='design:openpa/full/parts/main_image.tpl'}

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
            {foreach $summary_items as $index => $item}
                <article id="{$item.slug|wash()}" class="it-page-section mb-2">
                    {if $item.wrap}                    
                    <div class="card-wrapper card-teaser-wrapper card-teaser-embed">
                    {/if}

                    {foreach $item.attributes as $openpa_attribute}

                        {if $openpa_attribute.full.highlight}
                        <div class="callout important">
                            <div class="callout-title">
                                {display_icon('it-info-circle', 'svg', 'icon')}
                                {if and($openpa_attribute.full.show_label, $openpa_attribute.full.collapse_label|not(), $item.is_grouped)}
                                    {$openpa_attribute.label|wash()}
                                {/if}
                            </div>
                        {elseif and($openpa_attribute.full.show_label, $item.is_grouped)}
                            {if $openpa_attribute.full.collapse_label|not()}
                                <h5 class="no_toc">{$openpa_attribute.label|wash()}</h5>
                            {else}
                                <h6 class="d-inline font-weight-bold">{$openpa_attribute.label|wash()}</h6>
                            {/if}
                        {/if}

                        {if is_set($openpa_attribute.contentobject_attribute)}
                            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                                image_class=medium
                                                relation_view=cond($openpa_attribute.full.show_link|not, 'list', 'banner')
                                                relation_has_wrapper=$item.wrap}
                        {else}
                            {include uri=$openpa_attribute.template}
                        {/if}

                        {if $openpa_attribute.full.highlight}
                        </div>
                        {/if}
                    {/foreach}

                    {if $item.wrap}
                    </div>
                    {/if}

                </article>
            {/foreach}
        </section>
    </div>
</section>

{undef $tree_menu $table_view $summary_items}
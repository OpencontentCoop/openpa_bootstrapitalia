{def $valid_nodes = $block.valid_nodes
$valid_nodes_count = $valid_nodes|count()
$children=array()
$classes= openpaini( 'GestioneClassi', 'classi_da_escludere_dai_blocchi_ezflow', array())
$fetch_params = hash(  'class_filter_type', 'exclude',
'class_filter_array', openpaini( 'GestioneClassi', 'classi_da_escludere_dai_blocchi_ezflow', array()),
'depth', 10,
'limit', 4,
'sort_by', array('published', false())  )}
{set_defaults( hash('show_title', true()) )}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}

    {if $valid_nodes_count|eq(1)}

        {set $children=fetch( 'content', 'tree', $fetch_params|merge(hash('parent_node_id', $valid_nodes[0].node_id)))}
        {if $children|count()}
            <ul class="list-group">
                {foreach $children as $child}
                    <li class="list-group-item">
                        {node_view_gui content_node=$child view=text_linked}
                    </li>
                {/foreach}
            </ul>
        {else}
            <p>Nessun contenuto disponibile in {$valid_nodes[0].name|wash()}</p>
        {/if}



    {elseif $valid_nodes_count|eq(2)}
        <section class="Grid Grid--withGutter">

            <div class="Grid-cell u-md-size1of2 u-lg-size1of2">
                {set $children=fetch( 'content', 'tree', $fetch_params|merge(hash('parent_node_id', $valid_nodes[0].node_id)))}
                {if $children|count()}
                    <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[0] view=text_linked}</h4>
                    <ul class="list-group">
                        {foreach $children as $child}
                            <li class="list-group-item">
                                {node_view_gui content_node=$child view=text_linked}
                            </li>
                        {/foreach}
                    </ul>
                {else}
                    <p>Nessun contenuto disponibile in {$valid_nodes[0].name|wash()}</p>
                {/if}
            </div>

            <div class="Grid-cell u-md-size1of2 u-lg-size1of2">
                {set $children=fetch( 'content', 'tree', $fetch_params|merge(hash('parent_node_id', $valid_nodes[1].node_id)))}
                {if $children|count()}
                    <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[1] view=text_linked}</h4>
                    <ul class="list-group">
                        {foreach $children as $child}
                            <li class="list-group-item">
                                {node_view_gui content_node=$child view=text_linked}
                            </li>
                        {/foreach}
                    </ul>
                {else}
                    <p>Nessun contenuto disponibile in {$valid_nodes[1].name|wash()}</p>
                {/if}
            </div>
        </section>
    {elseif $valid_nodes_count|ge(3)}
        <section class="Grid Grid--withGutter">

            <div class="Grid-cell u-md-size1of3 u-lg-size1of3">
                {set $children=fetch( 'content', 'tree', $fetch_params|merge(hash('parent_node_id', $valid_nodes[0].node_id)))}
                {if $children|count()}
                    <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[0] view=text_linked}</h4>
                    <ul class="list-group">
                        {foreach $children as $child}
                            <li class="list-group-item">
                                {node_view_gui content_node=$child view=text_linked}
                            </li>
                        {/foreach}
                    </ul>
                {else}
                    <p>Nessun contenuto disponibile in {$valid_nodes[0].name|wash()}</p>
                {/if}
            </div>

            <div class="Grid-cell u-md-size1of3 u-lg-size1of3">
                {set $children=fetch( 'content', 'tree', $fetch_params|merge(hash('parent_node_id', $valid_nodes[1].node_id)))}
                {if $children|count()}
                    <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[1] view=text_linked}</h4>
                    <ul class="list-group">
                        {foreach $children as $child}
                            <li class="list-group-item">
                                <small>{$child.object.published|datetime(custom, '%j %F %Y')}</small>
                                <br/>
                                {node_view_gui content_node=$child view=text_linked}
                            </li>
                        {/foreach}
                    </ul>
                {else}
                    <p>Nessun contenuto disponibile in {$valid_nodes[1].name|wash()}</p>
                {/if}
            </div>

            <div class="Grid-cell u-md-size1of3 u-lg-size1of3">
                {set $children=fetch( 'content', 'tree', $fetch_params|merge(hash('parent_node_id', $valid_nodes[2].node_id)))}
                {if $children|count()}
                    <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[2] view=text_linked}</h4>
                    <ul class="list-group">
                        {foreach $children as $child}
                            <li class="list-group-item">
                                {node_view_gui content_node=$child view=text_linked}
                            </li>
                        {/foreach}
                    </ul>
                {else}
                    <p>Nessun contenuto disponibile in {$valid_nodes[2].name|wash()}</p>
                {/if}
            </div>
        </section>
    {/if}

</div>

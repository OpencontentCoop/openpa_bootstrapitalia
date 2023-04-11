{def $valid_nodes = $block.valid_nodes
    $children = array()
    $subchildren = array()
    $children_count = 0
    $item_per_column = 0
    $col-width = 4
    $modulo = 3    
    $classi_da_escludere = openpaini( 'GestioneClassi', 'classi_da_escludere_dai_blocchi_ezflow' )}

<div class="openpa-widget {$block.view} {if iand(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <div class="openpa-widget-content">
        <div class="widget_tabs" id="{$block.id}">
            <ul class="nav nav-tabs" role="tablist">
                {foreach $valid_nodes as $index => $node}
                    <li{if $index|eq(0)} class="active"{/if}>
                        <a href="#{$node.name|slugize()}" role="tab" data-toggle="tab">
                            {$node.name|wash()}
                        </a>
                    </li>
                {/foreach}
            </ul>
            <div class="tab-content widget">
                {foreach $valid_nodes as $index => $node}
                    <div class="tab-pane{if $index|eq(0)} active{/if}" id="{$node.name|slugize()}">
                        {set $children = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                                          'class_filter_type', 'exclude',
                                                                          'class_filter_array', $classi_da_escludere,
                                                                          'sort_by', $node.sort_array,
                                                                          'limit', 20 ) )
                             $subchildren = array()
                             $children_count = $children|count()}

                        {if $children_count|gt(0)}
                          {set $item_per_column = ceil( $children_count|div( 3 ) ) }
                        {/if}

                        <div class="row">
                        {foreach $children as $index => $child}

                          {if $item_per_column|gt(0)}
                            {if $index|eq(0)}
                              <div class="col-md-{$col-width}">
                            {elseif eq($index, $item_per_column)}
                              </div>
                              <div class="col-md-{$col-width}">
                            {elseif eq($index, mul($item_per_column,2))}
                              </div>
                              <div class="col-md-{$col-width}">
                            {/if}
                          {/if}


                            <h4><a title="Informazioni su {$child.name|wash}" href={$child.object.main_node.url_alias|ezurl()}><strong>{$child.name|wash()}</strong></a></h4>
                            {set $subchildren=fetch( 'content', 'list', hash( 'parent_node_id', $child.node_id,
                                                                                'class_filter_type', 'exclude',
                                                                                'class_filter_array', $classi_da_escludere,
                                                                                'sort_by', $node.sort_array,
                                                                                'limit', 10 ) )}
                            {if $subchildren|count()|gt(0)}
                              {foreach $subchildren as $subchild}<a title="Informazioni su {$subchild.name|wash}" href={$subchild.object.main_node.url_alias|ezurl()}>{$subchild.name|wash()}</a>{delimiter}, {/delimiter}{/foreach}
                            {elseif $child|has_abstract()}
                              <div style="font-size:.85em">{$child|abstract()}</div>
                            {/if}


                          {if and( $item_per_column|gt(0), $children_count|eq( $index|inc ) )}
                            </div>
                          {/if}

                        {/foreach}
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
    </div>
</div>

<script>
    {literal}
    $(document).ready(function() {
        $("#{/literal}{$block.id}{literal}").tabs();
    });
    {/literal}
</script>

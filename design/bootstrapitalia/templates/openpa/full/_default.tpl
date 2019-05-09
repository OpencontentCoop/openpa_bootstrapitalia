{ezpagedata_set( 'has_container', true() )}
<div class="class-{$node.class_identifier} container my-4">
    <div class="offset-lg-1 col-lg-9 col-md-12">

        <h1>{$node.name|wash()}</h1>
        <p class="text-right">
            <small class="text-muted">{if $node.object.owner}{$node.object.owner.name|wash()} - {/if}{$node.object.published|l10n( shortdate )}</small>
        </p>
        <div class="row">
            {def $style = ' bg-light'}
            {foreach $node.object.contentobject_attributes as $attribute}
                {if $node|has_attribute( $attribute.contentclass_attribute_identifier )}
                    <div class="col-sm-3 mb-1 p-3{$style}"><strong>{$attribute.contentclass_attribute_name}</strong></div>
                    <div class="col-sm-9 mb-1 p-3{$style}">{attribute_view_gui attribute=$attribute image_class=medium}</div>
                    {if $style|eq('')}{set $style = ' bg-light'}{else}{set $style = ''}{/if}
                {/if}
            {/foreach}
            {undef $style}
        </div>

        {def $children_count = fetch( content, 'list_count', hash( 'parent_node_id', $node.node_id ) )
             $page_limit = 12}
        {if $children_count}
        <div class="row my-4">
            <div class="col-sm-12 p-3">
                <div class="card-children">
                    <div class="card-columns">
                        {foreach fetch( content, list, hash( 'parent_node_id', $node.node_id,
                                                             'offset', $view_parameters.offset,
                                                             'sort_by', $node.sort_array,
                                                             'limit', $page_limit ) ) as $child }
                            {node_view_gui view=line content_node=$child}
                        {/foreach}
                    </div>
                    {include name=navigator
                             uri='design:navigator/google.tpl'
                             page_uri=$node.url_alias
                             item_count=$children_count
                             view_parameters=$view_parameters
                             item_limit=$page_limit}
                </div>
            </div>
        </div>
        {/if}

    </div>
</div>
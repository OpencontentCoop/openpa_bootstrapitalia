{ezpagedata_set( 'has_container', true() )}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node.data_map.act_number.has_content}
                {def $act_number_val = $node.data_map.act_number.content}
                {def $doc_type_tags = $node.data_map.document_type.content.tags}
                <h2 class="h4 py-2">{if $doc_type_tags|count()|gt(0)}{$doc_type_tags[0].keyword|wash()} {/if}{$act_number_val|wash()}{if $node.data_map.act_date.has_content} {'of act date'|i18n('bootstrapitalia/documents')} {$node.data_map.act_date.content.timestamp|l10n('shortdate')}{/if}</h2>
                {undef $act_number_val $doc_type_tags}
            {/if}

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
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</section>

{if $node.children_count}
<div class="section section-muted section-inset-shadow p-4 pt-5">
    {node_view_gui content_node=$node view=children view_parameters=$view_parameters}
</div>
{/if}

{if $openpa['content_tree_related'].full.exclude|not()}
    {include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}

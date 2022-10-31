{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h4 class="py-2">{$node|attribute('short_title').content|wash()}</h4>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}
        </div>
    </div>
</section>

{def $children_count = $node.children_count}
<div class="section section-muted section-inset-shadow p-4 mt-4">
{if $children_count}

    {def $page_limit = 10
         $children = fetch( openpa, list, hash( 'parent_node_id', $node.node_id,
                                                'offset', $view_parameters.offset,
                                                'sort_by', $node.sort_array,
                                                'limit', $page_limit ) )}
    <div class="py-5">
        <div class="container">
            <div class="row">
                <div class="col">

                    <div class="calendar-vertical font-sans-serif">
                    {foreach $children as $child}
                        {def $openpa_child = object_handler($child)}
                        <div class="calendar-date">
                            <div class="calendar-date-day">
                                <small class="calendar-date-day__year">{$child.object.published|datetime( 'custom', '%Y' )}</small>
                                <span class="title-xxlarge-regular d-flex justify-content-center">{$child.object.published|datetime( 'custom', '%d' )}</span>
                                <small class="calendar-date-day__month text-lowercase">{$child.object.published|datetime( 'custom', '%M' )}</small>
                            </div>
                            <div class="calendar-date-description rounded bg-white">
                                <div class="calendar-date-description-content">
                                    <h3 class="title-medium-2 mb-0">
                                        <a class="stretched-link" href="{$openpa_child.content_link.full_link}">{$child.name|wash()}</a>
                                    </h3>
                                    <em>{$child|abstract()|oc_shorten(250)}</em>
                                </div>
                            </div>
                        </div>
                        {undef $openpa_child}
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
    </div>

    {undef $children $page_limit}
</div>
{/if}

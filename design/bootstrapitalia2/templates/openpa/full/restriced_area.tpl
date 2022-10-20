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

                    {*<div class="it-list-wrapper">
                        <ul class="it-list">
                        {foreach $children as $child}
                            {def $openpa_child = object_handler($child)}
                            <li>
                              <a href="{$openpa_child.content_link.full_link}">
                                <div class="it-rounded-icon">
                                    {if $openpa_child.content_icon.icon}
                                        {display_icon($openpa_child.content_icon.icon.icon_text|wash(), 'svg', 'icon')}
                                    {else}
                                        {display_icon('it-file', 'svg', 'icon')}
                                    {/if}
                                </div>
                                <div class="it-right-zone">
                                    <span class="text">{$child.name|wash()} <em>{$child|abstract()|oc_shorten(300)}</em></span>
                                    <span class="metadata">{$child.object.published|datetime( 'custom', '%j %F %Y' )}</span>
                                </div>
                              </a>
                            </li>
                            {undef $openpa_child}
                        {/foreach}
                        </ul>
                    </div>*}

                    <div class="point-list-wrapper my-4">
                    {foreach $children as $child}
                        {def $openpa_child = object_handler($child)}
                        <div class="point-list mb-4">
                            <div class="point-list-aside point-list-warning">
                                <div class="point-date text-monospace">{$child.object.published|datetime( 'custom', '%d' )}</div>
                                <div class="point-month text-monospace">{$child.object.published|datetime( 'custom', '%M' )}/{$child.object.published|datetime( 'custom', '%y' )}</div>
                            </div>
                            <div class="point-list-content">
                                <div class="card card-teaser shadow p-4 rounded border">
                                    <div class="card-body">
                                        <h4 class="card-title">
                                            <a class="stretched-link" href="{$openpa_child.content_link.full_link}">{$child.name|wash()}</a>
                                        </h4>
                                        <em>{$child|abstract()|oc_shorten(250)}</em>
                                    </div>
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

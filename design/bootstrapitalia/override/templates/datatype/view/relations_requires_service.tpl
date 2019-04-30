{def $node_list = array()}
{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}  
<div class="point-list-wrapper my-4">  
    {foreach $node_list as $child }
        {if $child.class_identifier|eq('public_service')}
            {def $day = '?'}
            {def $month = '?'}
            {if $child|has_attribute('has_temporal_coverage')}
                {def $temporal_coverage = fetch(content, object, hash('object_id', $child|attribute('has_temporal_coverage').content.relation_list[0].contentobject_id))}
                {if $temporal_coverage|has_attribute('valid_from')}    
                    {set $day = $temporal_coverage|attribute('valid_from').content.timestamp|datetime( 'custom', '%d' )}
                    {set $month = $temporal_coverage|attribute('valid_from').content.timestamp|datetime( 'custom', '%M' )}
                {/if}
                {undef $temporal_coverage}
            {/if}
            <div class="point-list">
                <div class="point-list-aside point-list-warning">
                    <div class="point-date text-monospace">{$day}</div>
                    <div class="point-month text-monospace">{$month}</div>
                </div>
                <div class="point-list-content">
                    <div class="card card-teaser shadow p-4 rounded border">
                        <div class="card-body">
                            <h5 class="card-title">
                                <a href="{$child.url_alias|ezurl(no)}">
                                    {$child.name|wash()}
                                </a>
                            </h5>
                        </div>
                    </div>
                </div>
            </div>

            {undef $day $month}
        {/if}
    {/foreach}
</div>      
{/if}

{undef $node_list}

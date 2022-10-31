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
    <div class="calendar-vertical mb-3 font-sans-serif">
    {foreach $node_list as $child }
        {if $child.class_identifier|eq('public_service')}
            {def $day = false()}
            {def $month = false()}
            {def $year = false()}
            {def $processing_time = false()}
            {if $child|has_attribute('has_temporal_coverage')}
                {def $temporal_coverage = fetch(content, object, hash('object_id', $child|attribute('has_temporal_coverage').content.relation_list[0].contentobject_id))}
                {if $temporal_coverage|has_attribute('valid_through')}
                    {set $day = $temporal_coverage|attribute('valid_through').content.timestamp|datetime( 'custom', '%d' )}
                    {set $month = $temporal_coverage|attribute('valid_through').content.timestamp|datetime( 'custom', '%M' )}
                    {set $year = $temporal_coverage|attribute('valid_through').content.timestamp|datetime( 'custom', '%Y' )}
                {/if}
                {undef $temporal_coverage}
            {/if}
            {if and($day|eq(false()), $child|has_attribute('has_processing_time'))}
                {set $processing_time = $child|attribute('has_processing_time').content}
            {/if}
            <div class="calendar-date">

                <div class="calendar-date-day {if $day}warning{else}info{/if}">
                    {if $day}
                        <small class="calendar-date-day__year">{$year}</small>
                        <span class="title-xxlarge-regular d-flex justify-content-center">{$days}</span>
                        <small class="calendar-date-day__month text-lowercase">{$month}</small>
                    {elseif $processing_time}
                        <span class="title-xxlarge-regular d-flex justify-content-center">{$processing_time}</span>
                        <small class="calendar-date-day__month text-lowercase">{'days'|i18n('bootstrapitalia')}</small>
                    {/if}
                </div>

                <div class="calendar-date-description rounded">
                    <div class="calendar-date-description-content">
                        <h3 class="title-medium-2 mb-0">
                            <a href="{$child.url_alias|ezurl(no)}">
                                {$child.name|wash()}
                            </a>
                            {if $child|has_attribute('has_temporal_coverage')}
                                <ul class="list-unstyled m-0">
                                {def $tc_count = $child|attribute('has_temporal_coverage').content.relation_list|count()}
                                {foreach $child|attribute('has_temporal_coverage').content.relation_list as $item}
                                    {def $temporal_coverage = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                    <li>
                                        <small>
                                            {if $tc_count|gt(1)}
                                                {attribute_view_gui attribute=$temporal_coverage|attribute('name')}:
                                            {/if}
                                            {$temporal_coverage|attribute('valid_from').content.timestamp|l10n( shortdate )}
                                            {if $temporal_coverage|has_attribute('valid_through')}
                                                <i class="fa fa-arrow-right" aria-hidden="true"></i>
                                                {$temporal_coverage|attribute('valid_through').content.timestamp|l10n( shortdate )}
                                            {/if}
                                        </small>
                                    </li>
                                    {undef $temporal_coverage}
                                {/foreach}
                                {undef $tc_count}
                                </ul>
                            {/if}
                        </h3>
                    </div>
                </div>
            </div>

            {undef $day $month $year $processing_time}
        {/if}
    {/foreach}
</div>      
{/if}

{undef $node_list}

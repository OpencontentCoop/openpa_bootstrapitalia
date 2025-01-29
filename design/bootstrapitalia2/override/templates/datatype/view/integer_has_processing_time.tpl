{if $attribute.data_int|int()|gt(0)}
<div class="calendar-vertical font-sans-serif has-bg-grey p-3">
    <div class="calendar-date">
        <div class="calendar-date-day">
            <span class="title-xxlarge-regular d-flex justify-content-center lh-1">{$attribute.data_int}</span>
            <small class="calendar-date-day__month">{'days'|i18n('bootstrapitalia')}</small>
        </div>
        <div class="calendar-date-description rounded bg-white">
            <div class="calendar-date-description-content">
                <h3 class="title-medium-2 mb-0">{$attribute.contentclass_attribute_name|wash()}</h3>
            </div>
        </div>
    </div>
</div>
{elseif and(
    $attribute.object|has_attribute('has_temporal_coverage')|not(),
    $attribute.object|has_attribute('average_processing_time')|not(),
    $attribute.object|has_attribute('has_processing_time_text')|not()
)}
    <div class="text-paragraph lora mb-4"><p>{openpaini('AttributeHandlers', 'DefaultContent_has_processing_time', 'I tempi e le scadenze non sono al momento disponibili')}</p></div>
{/if}

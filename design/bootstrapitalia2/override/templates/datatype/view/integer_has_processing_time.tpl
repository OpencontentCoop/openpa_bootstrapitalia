<div class="calendar-vertical font-sans-serif has-bg-grey p-3 ps-0">
    <div class="calendar-date">
        <div class="calendar-date-day">
            <span class="title-xxlarge-regular d-flex justify-content-center">{$attribute.data_int}</span>
            <small class="calendar-date-day__month">{'days'|i18n('bootstrapitalia')}</small>
        </div>
        <div class="calendar-date-description rounded bg-white">
            <div class="calendar-date-description-content">
                <h3 class="title-medium-2 mb-0">{$attribute.contentclass_attribute_name|wash()}</h3>
            </div>
        </div>
    </div>
</div>
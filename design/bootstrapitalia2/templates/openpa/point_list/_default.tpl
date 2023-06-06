<div class="calendar-date">
    <div class="calendar-date-day">
        <small class="calendar-date-day__year">{$node.object.published|datetime( 'custom', '%Y' )}</small>
        <span class="title-xxlarge-regular d-flex justify-content-center">{$node.object.published|datetime( 'custom', '%d' )}</span>
        <small class="calendar-date-day__month text-lowercase">{$node.object.published|datetime( 'custom', '%M' )}</small>
    </div>
    <div class="calendar-date-description rounded bg-white">
        <div class="calendar-date-description-content">
            <h3 class="title-medium-2 mb-0">
                {attribute_view_gui attribute=$node|attribute('name')}
            </h3>
        </div>
    </div>
</div>

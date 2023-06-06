<div class="point-list">
    <div class="point-list-aside point-list-warning">
        <div class="point-date text-monospace" style="max-height: 53px;">{$node.object.published|datetime( 'custom', '%d' )}</div>
        <div class="point-month text-monospace" style="max-height: 20px;">{$node.object.published|datetime( 'custom', '%M' )}</div>
    </div>
    <div class="point-list-content">
        <div class="card card-teaser shadow p-4 rounded border">
            <div class="card-body">
                <h5 class="card-title">
                    {attribute_view_gui attribute=$node|attribute('name')}
                </h5>
            </div>
        </div>
    </div>
</div>

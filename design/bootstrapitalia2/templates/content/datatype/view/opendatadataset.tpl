{if $attribute.has_content}
{if module_params().function_name|eq('edit')}
    <table class="table table-sm">
        <caption>{if $attribute.has_content}{$attribute.content.item_name|wash}{/if}</caption>
        <thead>
        <tr>
            <th>{'Label'|i18n('opendatadataset')}</th>
            <th>{'Identifier'|i18n('opendatadataset')}</th>
            <th>{'Type'|i18n('opendatadataset')}</th>
        </tr>
        </thead>
        <tbody>
            {foreach $attribute.content.fields as $field}
                <tr>
                    <td>{$field.label|wash()}</td>
                    <td>{$field.identifier|wash()}</td>
                    <td>{$field.type|wash()}</td>
                </tr>
            {/foreach}
        </tbody>
    </table>

    <div class="mb-5">
        {foreach $attribute.class_content.views as $view => $name}
            <div class="chip chip-{if and($attribute.has_content, $attribute.content.views|contains($view))}primary{else}info{/if}">
                <span class="chip-label">{$name|wash()}</span>
            </div>
        {/foreach}
    </div>
{else}
{def $scripts = array()}
{if fetch('user','current_user').is_logged_in}
    {set $scripts = $scripts|merge(array(
    'jquery.fileupload.js',
    'jquery.fileupload-process.js',
    'jquery.fileupload-ui.js',
    'bootstrap-datetimepicker.min.js'
    ))}
{/if}
{set $scripts = $scripts|merge(array(
    'dataTables.responsive.min.js',
    'handlebars.min.js',
    'moment-with-locales.min.js',
    'leaflet/leaflet.0.7.2.js',
    'leaflet/Control.Geocoder.js',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/leaflet.activearea.js',
    'leaflet/leaflet.markercluster.js',
    'fullcalendar/core/main.js',
    'fullcalendar/core/locales/it.js',
    'fullcalendar/daygrid/main.js',
    'fullcalendar/list/main.js',
    'highcharts/highcharts.js',
    'highcharts/highcharts-3d.js',
    'highcharts/highcharts-more.js',
    'highcharts/modules/funnel.js',
    'highcharts/modules/heatmap.js',
    'highcharts/modules/solid-gauge.js',
    'highcharts/modules/treemap.js',
    'highcharts/modules/boost.js',
    'highcharts/modules/exporting.js',
    'highcharts/modules/no-data-to-display.js',
    'alpaca.js',
    'fields/SimpleOpenStreetMap.js',
    'jquery.opendataform.js',
    'ec.min.js',
    'jquery.opendatadatasetview.js'
))}
{ezscript_require($scripts)}
{ezcss_require(array(
    'datatable.responsive.bootstrap4.min.css',
    'leaflet/leaflet.0.7.2.css',
    'leaflet/Control.Loading.css',
    'leaflet/MarkerCluster.css',
    'leaflet/MarkerCluster.Default.css',
    'bootstrap-datetimepicker.min.css',
    'fullcalendar/core/main.css',
    'fullcalendar/daygrid/main.css',
    'fullcalendar/list/main.css',
    'jquery.fileupload.css',
    'alpaca-custom.css',
    'opendatadataset.css'
))}
{def $custom_repository = concat('dataset-', $attribute.contentclass_attribute_identifier, '-',$attribute.contentobject_id)}

<div id="dataset-{$attribute.id}" class="my-5 w-100">
    <div class="data_actions_and_alerts">
        <div class="data_actions">
            <a href="{concat('/customexport/',$custom_repository)|ezurl(no)}" data-href="{concat('/customexport/',$custom_repository)|ezurl(no)}" data-action="export" class="btn btn-primary btn-xs mb-1 mr-1"><i class="fa fa-download"></i> {'Download CSV'|i18n('opendatadataset')}</a>
            {if and($attribute.content.can_edit, $attribute.content.is_api_enabled)}
                <a href="#" data-action="add" class="btn btn-outline-primary btn-xs mb-1"><i class="fa fa-plus"></i> {'Create new %name'|i18n('opendatadataset',,hash('%name', $attribute.content.item_name|wash()))}</a>
                {*<a href="#" data-action="apidoc" class="btn btn-outline-primary btn-xs mb-1"><i class="fa fa-external-link"></i> {'API Doc'|i18n('opendatadataset')}</a>*}
            {/if}
            {if $attribute.content.can_edit}
                <a href="#" data-action="import" class="btn btn-outline-primary btn-xs mb-1"><i class="fa fa-arrow-up"></i> {'Import from CSV'|i18n('opendatadataset')}</a>
                <a href="#" data-action="google-import" class="btn btn-outline-primary btn-xs mb-1"><i class="fa fa-google"></i> {'Import from Google Sheet'|i18n('opendatadataset')}</a>
            {/if}
            {if $attribute.content.can_truncate}
                <a href="#" data-action="delete-all" class="btn btn-outline-danger btn-xs mb-1"><i class="fa fa-trash"></i> {'Delete data'|i18n('opendatadataset')}</a>
            {/if}
        </div>

        <div class="alert alert-warning my-2 has_pending_action_alert" style="display: none">
            <i class="fa fa-circle-o-notch fa-spin"></i> {'There are data being updated'|i18n('opendatadataset')}
        </div>
        {if $attribute.content.can_edit}
            <div class="alert alert-danger my-2 has_error_action_alert" style="display: none"></div>
            <div class="alert alert-success my-2 has_scheduled_action_alert" style="display: none">
                {'Automatic import enabled'|i18n('opendatadataset')}
                <a href="#" target="_blank" class="spreadsheet_uri btn btn-xs btn-primary p-1 ml-3">
                    <i class="fa fa-external-link"></i> {'Go to source'|i18n('opendatadataset')}
                </a>
                <a href="{concat('/opendatadataset/remove_scheduled_import/', $attribute.id)|ezurl(no)}" class="btn btn-xs btn-danger p-1 ml-3">
                    <i class="fa fa-times"></i> {'Disable'|i18n('opendatadataset')}
                </a>
            </div>
        {/if}
    </div>

    <div class="fullscreenable">
        {if $attribute.content.views|count()|gt(1)}
        <ul class="nav nav-tabs overflow-hidden mt-3">
            {def $index = 0}
            {def $icons = $attribute.class_content.view_icons}
            {foreach $attribute.content.views as $view}
            {def $name = cond(is_set($attribute.class_content.views[$view]), $attribute.class_content.views[$view], false())}
            {if $name}
            <li role="presentation" class="nav-item">
                <a title="{$name|wash()|upfirst}" class="text-decoration-none nav-link{if $index|eq(0)} active{/if} text-sans-serif" data-active_view="{$view}" data-toggle="tab" data-bs-toggle="tab" href="#{$view}-{$attribute.id}">
                    <i class="view_icon {$icons[$view]} me-2"></i> <span class="opendatadataset_view_name me-2">{$name|wash()|upfirst}</span>
                </a>
            </li>
            {set $index = $index|inc()}
            {/if}
            {undef $name}
            {/foreach}
            {undef $index $icons}
            <li role="presentation" class="nav-item ms-auto ml-auto">
                <a href="#" class="text-decoration-none nav-link dataset-fullscreen text-decoration-none">
                    <i class="fa fa-expand" data-reverse="fa fa-compress"></i>
                </a>
            </li>
        </ul>
        {/if}

        <div class="tab-content mt-3">
        {def $index = 0}
        {foreach $attribute.content.views as $view}
            {if is_set($attribute.class_content.views[$view])}
                {if $view|eq('calendar')}
                    <div role="tabpanel" data-view="{$view}" class="tab-pane{if $index|eq(0)} active{/if}" id="{$view}-{$attribute.id}">
                        <div class="block-calendar-default shadow block-calendar block-calendar-big"></div>
                    </div>
                {else}
                    <div role="tabpanel" data-view="{$view}" class="tab-pane{if $index|eq(0)} active{/if}" id="{$view}-{$attribute.id}"></div>
                {/if}
            {set $index = $index|inc()}
        {/if}
        {/foreach}
        {undef $index}
        </div>
    </div>

    {if and($attribute.data_int, $attribute.data_int|gt(0))}
        <div class="my-2">
            <h3 class="h6">{'Last modified'|i18n('bootstrapitalia')}: <span class="h6 fw-normal">{$attribute.data_int|l10n( 'shortdatetime' )}</span></h3>
        </div>
    {/if}

    <div class="dataset-modal modal fade">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-body pb-3">
                    <div class="dataset-form clearfix"></div>
                </div>
            </div>
        </div>
    </div>
</div>

{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
{def $startDateFormat = ''
     $endDateFormat = ''
     $textLabels = hash()
     $facets = array()
     $columns = array()
}
{foreach $attribute.content.fields as $field}
    {if and(is_set($attribute.content.settings.calendar.start_date_field), $field.identifier|eq($attribute.content.settings.calendar.start_date_field))}
        {if is_set($field.date_format)}{set $startDateFormat = $field.date_format}{else}{set $startDateFormat = $field.datetime_format}{/if}
    {/if}
    {if and(is_set($attribute.content.settings.calendar.end_date_field), $field.identifier|eq($attribute.content.settings.calendar.end_date_field))}
        {if is_set($field.date_format)}{set $endDateFormat = $field.date_format}{else}{set $endDateFormat = $field.datetime_format}{/if}
    {/if}
    {if and(is_set($attribute.content.settings.calendar.text_labels), $attribute.content.settings.calendar.text_labels|contains($field.identifier))}
        {set $textLabels = $textLabels|merge(hash($field.identifier, $field.js_label))}
    {/if}
    {if $attribute.content.settings.facets|contains($field.identifier)}
        {set $facets = $facets|append(hash(field, $field.identifier, limit, 10000, sort, 'alpha', name, $field.js_label))}
    {/if}
    {if $attribute.content.settings.table.show_fields|contains($field.identifier)}
        {set $columns = $columns|append(hash(data, $field.identifier, name, $field.identifier, title, $field.js_label, searchable, true(), orderable, cond(array('checkbox', 'geo')|contains($field.type), false(), true())))}
    {/if}
{/foreach}

<script>
    moment.locale('{$moment_language}');
    $(document).ready(function () {ldelim}
        if ($.isFunction($.fn['datasetView'])){ldelim}
            $("#dataset-{$attribute.id}").datasetView({ldelim}
            id: {$attribute.id},
            version: {$attribute.version},
            language: "{$attribute.language_code}",
            facets: JSON.parse('{$facets|json_encode()}'),
            itemName: "{$attribute.content.item_name|wash()}",
            canEdit: {cond(and($attribute.content.can_edit, $attribute.content.is_api_enabled), 'true', 'false')},
            endpoints: {ldelim}
                geo: "{concat('/customgeo/',$custom_repository)|ezurl(no)}/",
                search: "{concat('/customfind/',$custom_repository)|ezurl(no)}/",
                datatable: "{concat('/customdatatable/',$custom_repository)|ezurl(no)}/",
                datatableLanguage: "{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}",
                calendar: "{concat('/customcalendar/',$custom_repository)|ezurl(no)}/",
                csv: "{concat('/customexport/',$custom_repository)|ezurl(no)}/",
                counter: "{concat('/customcount/',$custom_repository)|ezurl(no)}/"
            {rdelim},
            calendar: {ldelim}
                defaultView: "{if is_set($attribute.content.settings.calendar.default_view)}{$attribute.content.settings.calendar.default_view}{else}dayGridWeek{/if}",
                includeWeekends: {cond(and(is_set($attribute.content.settings.calendar.include_weekends), $attribute.content.settings.calendar.include_weekends|eq('true')), 'true', 'false')},
                startDateField: {if is_set($attribute.content.settings.calendar.start_date_field)}"{$attribute.content.settings.calendar.start_date_field}"{else}false{/if},
                startDateFormat: '{$startDateFormat}',
                endDateField: {if is_set($attribute.content.settings.calendar.end_date_field)}"{$attribute.content.settings.calendar.end_date_field}"{else}false{/if},
                endDateFormat: '{$endDateFormat}',
                textFields: [{if is_set($attribute.content.settings.calendar.text_fields)}"{$attribute.content.settings.calendar.text_fields|implode('","')}"{/if}],
                textLabels: JSON.parse('{$textLabels|json_encode()}'),
                eventLimit: {if and(is_set($attribute.content.settings.calendar.event_limit), $attribute.content.settings.calendar.event_limit|gt(0))}{$attribute.content.settings.calendar.event_limit}{else}false{/if},
            {rdelim},
            chart: {ldelim}
                settings: '{if is_set($attribute.content.settings.chart)}{$attribute.content.settings.chart}{/if}'
            {rdelim},
            datatable: {ldelim}
                columns: JSON.parse('{$columns|json_encode()}'),
                defaultOrder: "{cond(and(is_set($attribute.content.settings.table.order),$attribute.content.settings.table.order|eq('asc')), 'asc', 'desc')}",
                viewAsDescriptionList: {cond(and(is_set($attribute.content.settings.table.view),$attribute.content.settings.table.view|eq('description-list')), 'true', 'false')}
            {rdelim},
            counter: {ldelim}
                label: "{if is_set($attribute.content.settings.counter.label)}{$attribute.content.settings.counter.label}{else}{$attribute.content.item_name|wash()}{/if}",
                field: {if is_set($attribute.content.settings.counter.select_field)}"{$attribute.content.settings.counter.select_field}"{else}false{/if},
                stat: "{if is_set($attribute.content.settings.counter.select_stat)}{$attribute.content.settings.counter.select_stat}{else}count{/if}",
                image: {if is_set($attribute.content.settings.counter.image_uri)}"{$attribute.content.settings.counter.image_uri}"{else}false{/if}
            {rdelim},
            i18n: {ldelim}
                filter_by: "{'Filter by'|i18n('opendatadataset')}",
                delete: "{'Delete'|i18n('opendatadataset')}",
                cancel: "{'Cancel operation'|i18n('opendatadataset')}",
                delete_dataset: "{'I understand the consequences, delete this dataset'|i18n('opendatadataset')}",
                import: "{'Import'|i18n('opendatadataset')}",
                select: "{'Select'|i18n('opendatadataset')}",
                search_placeholder: "{'Search by keyword'|i18n('bootstrapitalia')}"
            {rdelim},
            searchInput: {cond($attribute.content.settings.search_form, 'true', 'false')}
        {rdelim});
        {rdelim}else{ldelim}
            console.log('can not load datasetView plugin');
            $("#dataset-{$attribute.id}").hide();
        {rdelim}
    {rdelim})
</script>
{undef $current_language $current_locale $moment_language $startDateFormat $endDateFormat $textLabels $facets $columns}
{/if}
{/if}

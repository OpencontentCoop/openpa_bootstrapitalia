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
    'jsrender.js',
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
        </div>
        <div class="alert alert-warning my-2 has_pending_action_alert" style="display: none">
            <i class="fa fa-circle-o-notch fa-spin"></i> {'There are data being updated'|i18n('opendatadataset')}
        </div>
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
                    {if $view|eq('table')}
                        <i class="view_icon fa fa-list me-2"></i> <span class="opendatadataset_view_name me-2">
                        {'List'|i18n('design/admin/content/browse')}
                    {else}
                        <i class="view_icon {$icons[$view]} me-2"></i> <span class="opendatadataset_view_name me-2">
                        {$name|wash()|upfirst}
                    {/if}
                    </span>
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

    <div class="dataset-modal modal fade" style="z-index:40000">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-body pb-3">
                    <div class="clearfix">
                        <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true">&times;</button>
                    </div>
                    <div class="dataset-form clearfix"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<script id="tpl-inefficiency-table" type="text/x-jsrender">
{literal}
<div class="cmp-info-button-card">
    <div class="card p-3 p-lg-4 no-after">
        <div class="card-body p-0">
            <h3 class="medium-title mb-0">{{:row.subject}}</h3>
            <p class="card-info">{/literal}Tipologia di segnalazione{literal} <br>
                <span>{{:row.category}}</span>
            </p>
            <div class="accordion-item">
                <div class="accordion-header">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-{{:row.uuid}}"
                            aria-expanded="false" aria-controls="collapse-{{:row.uuid}}" data-focus-mouse="false">
                        <span class="d-flex align-items-center">
                            {/literal}Mostra tutto{literal}
                        </span>
                    </button>
                </div>
                <div id="collapse-{{:row.uuid}}" class="accordion-collapse pb-0 collapse" role="region">
                    <div class="accordion-body p-0">
                        <div class="cmp-info-summary bg-white border-0">
                            <div class="card">
                                <div class="card-body p-0">
                                    <div class="single-line-info border-light">
                                        <div class="text-paragraph-small">{/literal}Indirizzo{literal}</div>
                                        <div class="border-light">
                                            <p class="data-text">
                                                {{:row.address}}
                                            </p>
                                        </div>
                                    </div>
                                    <div class="single-line-info border-light">
                                        <div class="text-paragraph-small">{/literal}Dettaglio{literal}</div>
                                        <div class="border-light">
                                            <p class="data-text">
                                                {{:row.text}}
                                            </p>
                                        </div>
                                    </div>
                                    {{if row.image1}}
                                    <div class="single-line-info border-light">
                                        <div class="text-paragraph-small">{/literal}Immagini{literal}</div>
                                        <div class="border-light border-0">
                                            <div class="d-flex gap-2 mt-3">
                                                <div><img src="/image/inefficiency/{{:row._guid}}/1" class="img-fluid w-100 mb-3 mb-lg-0" loading="lazy"></div>
                                                {{if row.image2}}
                                                    <div><img src="/image/inefficiency/{{:row._guid}}/2" class="img-fluid w-100 mb-3 mb-lg-0" loading="lazy"></div>
                                                {{/if}}
                                                {{if row.image3}}
                                                    <div><img src="/image/inefficiency/{{:row._guid}}/3" class="img-fluid w-100 mb-3 mb-lg-0" loading="lazy"></div>
                                                {{/if}}
                                            </div>
                                        </div>
                                    </div>
                                    {{/if}}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
{/literal}
</script>
<script id="tpl-inefficiency-map" type="text/x-jsrender">
{literal}
<div>
    <div class="border-bottom border-light">
        <h3 class="title-xsmall border-light pt-2">{/literal}Titolo{literal}</h3>
        <p class="subtitle-small pb-2">{{:row.subject}}</p>
    </div>
    <div class="border-bottom border-light">
        <h3 class="title-xsmall border-light pt-2">{/literal}Tipologia di segnalazione{literal}</h3>
        <p class="subtitle-small pb-2">{{:row.category}}</p>
    </div>
    <div class="border-bottom border-light">
        <h3 class="title-xsmall border-light pt-2">{/literal}Indirizzo{literal}</h3>
        <p class="subtitle-small pb-2">{{:row.address}}</p>
    </div>
    <div class="border-bottom border-light">
        <h3 class="title-xsmall border-light pt-2">{/literal}Dettaglio{literal}</h3>
        <p class="subtitle-small pb-2">{{:row.text}}</p>
    </div>
    {{if row.image1}}
    <div class="border-bottom border-light">
        <h3 class="title-xsmall border-light pt-2">{/literal}Immagini{literal}</h3>
        <div class="border-light border-0">
            <div class="d-flex gap-2 mt-3">
                <div><img src="/image/inefficiency/{{:row._guid}}/1" class="img-fluid w-100 mb-3 mb-lg-0" loading="lazy"></div>
                {{if row.image2}}
                    <div><img src="/image/inefficiency/{{:row._guid}}/2" class="img-fluid w-100 mb-3 mb-lg-0" loading="lazy"></div>
                {{/if}}
                {{if row.image3}}
                    <div><img src="/image/inefficiency/{{:row._guid}}/3" class="img-fluid w-100 mb-3 mb-lg-0" loading="lazy"></div>
                {{/if}}
            </div>
        </div>
    </div>
    {{/if}}
</div>
{/literal}
</script>

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
            canEdit: false,
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
            map: {ldelim}
                customTpl: '#tpl-inefficiency-map'
            {rdelim},
            datatable: {ldelim}
                columns: JSON.parse('{$columns|json_encode()}'),
                customTpl: '#tpl-inefficiency-table',
                defaultOrder: "{cond(and(is_set($attribute.content.settings.table.order),$attribute.content.settings.table.order|eq('asc')), 'asc', 'desc')}",
                viewAsDescriptionList: {cond(and(is_set($attribute.content.settings.table.view),$attribute.content.settings.table.view|eq('description-list')), 'true', 'false')},
                template: '<table class="table display responsive no-wrap w-100"></table>'
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
            searchInput: {cond($attribute.content.settings.search_form, 'true', 'false')},
            preselectedFilters: {ldelim}status:{openpaini('InefficiencyCollector', 'DefaultStatus', array())|json_encode}{rdelim},
            filterAllowMultipleValue: ['status']
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

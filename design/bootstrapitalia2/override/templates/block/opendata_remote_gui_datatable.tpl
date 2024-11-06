{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

{def $query = $block.custom_attributes.query
	 $limit = $block.custom_attributes.limit
	 $fields = cond(and(is_set($block.custom_attributes.fields), $block.custom_attributes.fields|ne('')), $block.custom_attributes.fields|explode(','), array())
     $facets = cond(and(is_set($block.custom_attributes.facets), $block.custom_attributes.facets|ne('')), $block.custom_attributes.facets|explode(','), array())
     $facetsFields = array()
	 $remoteUrl = $block.custom_attributes.remote_url|trim('/')}

{if $fields|not()}{set $fields = array()}{/if}
{if $facets|not()}{set $facets = array()}{/if}

{foreach $facets as $index => $facet}
    {def $facets_parts = $facet|explode(':')}
    {if $facets_parts[0]|ne('')}
        {set $facetsFields = $facetsFields|append(hash(
            'field', $facets_parts[1],
            'name', $facets_parts[0],
            'limit', cond(is_set($facets_parts[2]), $facets_parts[2], 300),
            'sort', cond(is_set($facets_parts[3]), $facets_parts[3], 'alpha'),
        ))}
    {/if}
    {undef $facets_parts}
{/foreach}

{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
        {set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
    {/if}
    {undef $image}
{/if}

<div class="py-5 position-relative">
    <div class="container">
        <div id="remote-datatable-{$block.id}"
             data-remote="{$remoteUrl|wash()}"
             data-query="{$query|wash(javascript)}"
             data-facets='{$facetsFields|json_encode()}'
             data-fields='{$fields|json_encode()}'>
            {include uri='design:parts/block_name.tpl' css_class=cond($background_image, 'text-white bg-dark d-inline-block px-2 rounded', '') no_margin=true()}
            {if $facetsFields|count()}
            <div class="d-block d-lg-none d-xl-none text-center mb-2">
                <a href="#filters-{$block.id}" role="button" class="btn btn-primary btn-md text-uppercase collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="filters-{$block.id}">{'Filters'|i18n('bootstrapitalia')}</a>
            </div>
            <div class="d-lg-block d-xl-block collapse content-filters" id="filters-{$block.id}"></div>
            {/if}
            <table class="table table-striped content-data"></table>
        </div>
    </div>
</div>

{if and(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1))}
    <div class="row mt-2">
        <div class="col text-center">
            <a class="btn btn-primary" href="{$remoteUrl}">
                {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                    {$block.custom_attributes.show_all_text|wash()}
                {else}
                    {'View all'|i18n('bootstrapitalia')}
                {/if}
            </a>
        </div>
    </div>
{/if}
<script>
    moment.locale('{$moment_language}');
    {literal}
    $(document).ready(function () {
        $('#remote-datatable-{/literal}{$block.id}{literal}').each(function (){
            var container = $(this);
            var tools = $.opendataTools;
            var remoteUrl = container.data('remote');
            var searchApi = '/api/opendata/v2/content/search/';
            var datatableApi = '/api/opendata/v2/datatable/search/';
            var classApi = '/api/opendata/v2/classes/';
            if (remoteUrl === '') {
                searchApi = '/opendata/api/content/search/';
                datatableApi = '/opendata/api/datatable/search/';
                classApi = '/opendata/api/classes/';
            }
            var ajaxDatatype = remoteUrl === '' ? 'json' : 'jsonp';

            var mainQuery = container.data('query');
            var facets = JSON.parse(container.attr('data-facets'));
            var fields = JSON.parse(container.attr('data-fields'));
            if (facets.length > 0) {
                mainQuery += ' facets [' + tools.buildFacetsString(facets) + ']';
            }

            var initTable = function(columns, columnDefs, columnOrder, response){
                var datatable;
                datatable = container.find('.content-data').opendataDataTable({
                    builder:{
                        query: mainQuery
                    },
                    datatable:{
                        ajax: {
                            url: remoteUrl+datatableApi,
                            dataType: ajaxDatatype,
                        },
                        order: columnOrder,
                        columns: columns,
                        columnDefs: columnDefs,
                        language:{
                            url: "{/literal}{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}{literal}"
                        },
                    }
                }).on('xhr.dt', function ( e, settings, json, xhr ) {
                    var builder = JSON.stringify({
                        'builder': datatable.settings.builder,
                        'query': datatable.buildQuery()
                    });
                    if (facets.length > 0) {
                        $.each(json.facets, function (index, val) {
                            var facet = this;
                            tools.refreshFilterInput(facet, function (select) {
                                select.trigger("chosen:updated");
                            });
                        });
                    }
                }).data('opendataDataTable');
                datatable.loadDataTable();
                if (facets.length > 0) {
                    var form = $('<form class="form"></form>');
                    var formRow = $('<div class="form-row"></div>').appendTo(form);
                    $.each(response.facets, function (index,value) {
                        if (index > 0) {
                            tools.buildFilterInput(facets, value, datatable, function (selectContainer) {
                                var selectWrapper = $('<div class="col-md-4 col-lg-3 my-2"></div>');
                                selectWrapper.append(selectContainer);
                                formRow.append(selectWrapper)
                            });
                        }
                    });
                    container.find('.content-filters').append(form).show();
                }
            };

            var initialFacets = JSON.parse(container.attr('data-facets'));
            initialFacets.unshift({field: 'class', name: 'class', limit: 10, sort: 'alpha'})
            var initialQuery = container.data('query') + ' facets [' + tools.buildFacetsString(initialFacets) + ']';
            $.ajax({
                type: "GET",
                url: remoteUrl + searchApi + initialQuery + ' limit 1',
                dataType: ajaxDatatype,
                success: function (response, textStatus, jqXHR) {
                    if(response.error_message || response.error_code){
                        console.log(response.error_message);
                    }else{
                        var loadDefault = true;
                        if (fields.length > 0){
                            var classIdentifier = Object.keys(response.facets[0]['data'])[0];
                            if (typeof classIdentifier === 'string') {
                                $.ajax({
                                    type: "GET",
                                    url: remoteUrl + classApi + classIdentifier,
                                    dataType: ajaxDatatype,
                                    success: function (contentClass, textStatus, jqXHR) {
                                        var dynamicColumns = [];
                                        var dynamicColumnDefs = [];
                                        var orderColumns = [[0, 'asc']];
                                        var i = 0;
                                        $.each(fields, function (index,field) {
                                            var splittedField = field.split('.');
                                            if (field === '_link'){
                                                dynamicColumns.push({data: 'metadata.id', name: 'id', title: '#', orderable: false});
                                                dynamicColumnDefs.push({
                                                    render: function (data, type, row) {
                                                      let href = row?.extradata[$.opendataTools.settings('language')]?.urlAlias || remoteUrl + '/openpa/object/' + row.metadata.id;
                                                      return '<a href="' + href + '"><i class="fa fa-plus" aria-hidden="true"></i></a>';
                                                    },
                                                    orderable: false,
                                                    width: "1",
                                                    targets: [i]
                                                });
                                                if (i === 0){
                                                    orderColumns = [[1, 'asc']];
                                                }
                                                i++;
                                            }else {
                                                $.each(contentClass.fields, function () {
                                                    var contentClassField = this;
                                                    if (contentClassField.identifier === field) {
                                                        dynamicColumns.push({
                                                            data: 'data.' + tools.settings('language') + '.' + field,
                                                            name: field, title: tools.helpers.i18n(contentClassField.name),
                                                            orderable: contentClassField.isSearchable
                                                        });
                                                        dynamicColumnDefs.push({
                                                            render: function (data, type, row, meta) {
                                                                return opendataDataTableRenderField(contentClassField.dataType, contentClassField.template.type, tools.settings('language'), data, type, row, meta, false);
                                                            },
                                                            targets: [i]
                                                        });
                                                        if (i === 0 && contentClassField.template.type === 'ISO 8601 date'){
                                                            orderColumns = [[0, 'desc']];
                                                        }
                                                        i++;
                                                    }else if (splittedField.length > 1 && contentClassField.identifier === splittedField[0] && contentClassField.dataType === 'ezmatrix'){
                                                        var title = tools.helpers.i18n(contentClassField.name);
                                                        $.each(contentClassField.template.format[0][0], function (matrixIdentifier,matrixTitle){
                                                            if (matrixIdentifier === splittedField[1]){
                                                                // strip 'string (' and ')'
                                                                title = matrixTitle.substring(8).slice(0, -1);
                                                            }
                                                        });
                                                        dynamicColumns.push({
                                                            data: 'data.' + tools.settings('language') + '.' + splittedField[0],
                                                            name: splittedField[0], title: title,
                                                            orderable: false
                                                        });
                                                        dynamicColumnDefs.push({
                                                            render: function (data, type, row, meta) {
                                                                var result = [];
                                                                $.each(data, function () {
                                                                    var row = this;
                                                                    $.each(row, function (rowIndex, rowValue) {
                                                                        if (rowIndex === splittedField[1]){
                                                                            result.push(rowValue);
                                                                        }
                                                                    });
                                                                });
                                                                return result.join('<br />');
                                                            },
                                                            targets: [i]
                                                        });
                                                        i++;
                                                    }
                                                });
                                            }
                                        })
                                        if (dynamicColumns.length > 0) {
                                            initTable(dynamicColumns, dynamicColumnDefs, orderColumns, response);
                                        }
                                    },
                                    error: function (jqXHR) {
                                        let error = {
                                            error_code: jqXHR.status,
                                            error_message: jqXHR.statusText
                                        };
                                        console.log(error, jqXHR);
                                    }
                                });
                                loadDefault = false;
                            }
                        }
                        if (loadDefault) {
                            var columns = [
                                {data: 'metadata.id', name: 'id', title: '#', orderable: false},
                                {data: 'metadata.name.'+tools.settings('language'), name: 'name', title: '{/literal}{'Name'|i18n('openpa/search')}{literal}'}
                            ];
                            var columnDefs = [{
                                render: function (data, type, row) {
                                  let href = row?.extradata[$.opendataTools.settings('language')]?.urlAlias || remoteUrl + '/openpa/object/' + row.metadata.id;
                                  return '<a href="' + href + '"><i class="fa fa-plus" aria-hidden="true"></i></a>';
                                },
                                orderable: false,
                                width: "1",
                                targets: [0]
                            }];
                            initTable(columns, columnDefs, [[1,'asc']], response);
                        }
                    }
                },
                error: function (jqXHR) {
                    let error = {
                        error_code: jqXHR.status,
                        error_message: jqXHR.statusText
                    };
                    console.log(error, jqXHR);
                }
            });
        });
    });

    {/literal}
</script>
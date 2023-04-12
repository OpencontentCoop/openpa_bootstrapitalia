{def $openpa_block = object_handler($block)}
{include uri='design:parts/block_name.tpl'}
{if and(is_set($openpa_block.error), fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'editor_tools' ) ))}
    <div class="alert alert-warning message-warning warning">
        {$openpa_block.error|wash()}
    </div>
{else}
    {ezscript_require(array('dataTables.responsive.min.js', 'alboonline_block.js'))}
    {def $currentLanguage = ezini('RegionalSettings','Locale')}
    {if $block.custom_attributes.open_in_popup}
    {include uri='design:load_ocopendata_forms.tpl'}
    {/if}
    <script type="text/javascript" language="javascript" class="init">
        var trimmedPrefix = UriPrefix.replace(/~+$/g,"");
        if(trimmedPrefix === '/') trimmedPrefix = '';
        moment.locale('it');
        $.support.transition = false;
        $(document).ready(function () {ldelim}
            $('#container-{$block.id}').alboOnLine({ldelim}
                "buttonClass": 'btn-light',
                "selectedButtonClass": 'btn-dark',
                "template": '<table class="table table-sm"></table>',
                "query": "{$openpa_block.parameters.query}",
                "group_facet_query_part": "{$openpa_block.parameters.group_facet_query_part}",
                "facets_url": "{concat('/openpa/data/albo_on_line/', $block.id, '?search_facets=')|ezurl(no,full)}",
                "url": "{concat('/openpa/data/albo_on_line/', $block.id)|ezurl(no,full)}/",
                "searching": {if $openpa_block.parameters.searching}true{else}false{/if},
                "length": {$openpa_block.parameters.length},
                "openInPopup": {if $block.custom_attributes.open_in_popup}true{else}false{/if},
                "columns": [
                    {foreach $openpa_block.parameters.columns as $column}
                    {ldelim}
                        "data": "{$column.data}",
                        "name": '{$column.name}',
                        "title": '{$column.title|wash(javascript)}',
                        "searchable": {if $column.searchable}true{else}false{/if},
                        "orderable": {if $column.orderable}true{else}false{/if}
                        {rdelim}
                    {delimiter},{/delimiter}
                    {/foreach}
                ],
                "columnDefs": [
                    {foreach $openpa_block.parameters.fields as $index => $field}
                    {ldelim}
                        "render": function (data, type, row, meta) {ldelim}
                            if (data) {ldelim}
                                {if is_set($field.matrix_column)}
                                var result = [];
                                $.each(data, function () {ldelim}
                                    var row = this;
                                    $.each(row, function (index, value) {ldelim}
                                        if (index == '{$field.matrix_column}') {ldelim}
                                            result.push(value);
                                            {rdelim}
                                        {rdelim});
                                    {rdelim});
                                return result.join('<br />');
                                {else}
                                var link = {if and($block.custom_attributes.show_link, $index|eq(0))}trimmedPrefix+'/content/view/full/' + row.metadata.mainNodeId{else} false{/if};
                                if (!row.metadata.can_read && link) {ldelim}
                                    link = false;
                                    {rdelim}
                                var prefix = '';
                                var suffix = '';
                                if (link) {ldelim}
                                    prefix = '<div class="alboonline-link" data-open="'+row.metadata.id+'">';
                                    suffix = '</div>';
                                {rdelim}
                                return prefix + opendataDataTableRenderField(
                                    '{$field.dataType}',
                                    '{$field.template.type}',
                                    '{$currentLanguage}', data, type, row, meta, link
                                ) + suffix;
                                {/if}
                                {rdelim}
                            return '';
                            {rdelim},
                        "targets": [{$index}]
                        {rdelim}
                    {delimiter},{/delimiter}
                    {/foreach}
                ]
                {rdelim});
            {rdelim});
    </script>
    <div id="container-{$block.id}">

        {if count($openpa_block.parameters.state_facets)|gt(0)}
            <div class="facet-navigation">
                {foreach $openpa_block.parameters.state_facets as $index => $facet_button}
                    <a class="btn btn-sm btn-light {if $index|eq(0)} btn-dark{/if}"
                       data-field="{$facet_button.field}"
                       data-operator="{$facet_button.operator}"
                       data-value='{$facet_button.value}'
                       href="#">
                        {$facet_button.name|wash()}
                    </a>
                {/foreach}
            </div>
        {/if}

        {if count($openpa_block.parameters.group_facets)|gt(0)}
            <div class="facet-navigation group-facets" style="font-size: .875em;margin-top: 5px">
                {foreach $openpa_block.parameters.group_facets as $index => $facet_button}
                    {def $show = true()}
                    {if count($openpa_block.parameters.initial_group_facets)|gt(0)}
                        {set $show = false()}
                        {foreach $openpa_block.parameters.initial_group_facets as $initial}
                            {if $initial.name|eq($facet_button.name)}
                                {set $show = true()}
                            {/if}
                        {/foreach}
                    {/if}
                    <a class="btn btn-sm  btn-light{if $index|eq(0)} btn-dark{/if}"
                       {if $show|not()}style="display:none"{/if}
                       data-field="{$facet_button.field}"
                       data-operator="{$facet_button.operator}"
                       data-value='{$facet_button.value}'
                       data-facet_value='{$facet_button.facet_value}'
                       href="#">
                        {$facet_button.name|wash()}
                    </a>
                    {undef $show}
                {/foreach}
            </div>
        {/if}

        <div class="table-container"></div>

        <p class="text-muted my-4 text-right">
            <img style="vertical-align: middle"
                 src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAYEBAQFBAYFBQYJBgUGCQsIBgYICwwKCgsKCgwQDAwMDAwMEAwODxAPDgwTExQUExMcGxsbHCAgICAgICAgICD/2wBDAQcHBw0MDRgQEBgaFREVGiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICD/wAARCAASAGEDAREAAhEBAxEB/8QAGwAAAQUBAQAAAAAAAAAAAAAAAAEDBAUHAgb/xAA2EAABAwIDBAgEBQUAAAAAAAACAQMEBREABhITFCHRBxUWIjFBVZMyUVSUI0JW0tNSYWJxc//EABkBAQADAQEAAAAAAAAAAAAAAAABAgMEBf/EACcRAAICAQIFBQADAAAAAAAAAAABAhEDBBITITFRkRQVMkFhcYGh/9oADAMBAAIRAxEAPwDU8l5O6PzyDSqxWqYw488zd54hMjM9S+AhdSWyeCJi0YOTpEN0W0jKfRDHZivHS45BM1JG2bbzhEoJcu6Gok0+d04YusMn/RG9HT2T+iNmRFjrSo5uzR2kZGm3XdQXQdV29SIl1TiuIWGXgbkK5k7ohbCcZU2IiU00bnJY7tkVtN08eN+GHCly5deg3IrukDJuTcvZZeqdPoMJZLZtiO2AzCxmiLwQk8sa6XEsk6fQrllSsz+U3Jiwm5r+V6OMZ0BcA9kpLoP4TIEeUhFfmqY71o8Ddc7MHlmNvE6wy087likA28qCKqyV0Uvh2ibW7d/LXbErQ4X3HGmPSo8uLUAp7+V6MMtwdojaN6kQF/MRi8oin9yXELR4Gr50OLMhyZ7cV8mJGW6QDo+KbA14L4Kio7ZUXyVOGLrQYn3I48hrrmH+nqP9u5/JifbsX75I9RIOuYf6eo/27n8mHt2L98j1EibRnaXVJbsJ+hUxpsoktxHGGTBwTaYIwUSU18CT5Yw1OihDG5K7NMeZt0JvD/8AWuPKOk1TIlIWpdGmXNm7u8qKKSYjyjrEXRUxRSC46ksa8L40xz2/wyslZbLkOnON05qQ4TzMJ2RIdDiO1dk3UluKooohEqomNfUvn+1/hXhjtXyg3OrFPqDToMBADZjGVpVG2sT7ug29K923mmIx56i13EoWxioZEjTGqgm9E1InSd424CiKgLs7snx74Lsk8cWjqWq/EHjI3S3FlSskyWYrDkh1XWbNsgplbaJfujdcW0DSycyM/wATKagVdk09Y7WXZrMp6CzTZUlWnjQ2GC1Dpb0JpLUicbrj1YqKfyVXZyu+w/XKlm+sQZkF+izBjySjEyO7ufhbuGlUujaKev8AyXhiMcMcGna+/vuTKTf0NNyM0s1iRVI9DmNPvQ9zBN3cXQuyFpHOIKhfBeypidsNu1yXWyLd3RErjGaKxNbmP0eaLwx2Y5ru7neVkdOvgCImr5J4Ytj2QVWuvciVsr+z+YfSZ32zv7cacSPdeSu1h2fzD6TO+2d/bhxI915G1lrlij1mPVXXpFOlMMjBnanXWXABLxTtciRExy62cXifNGuFPcRceEdp4Q6rVGS2TMx9tseAgDhoKf6RFwAnXda+vk+6fPAB13Wvr5PunzwAdd1r6+T7p88ACV2tot0qElF/7Oc8Addoa/6lK99znhQDtDX/AFKV77nPCgHaGv8AqUr33OeFAO0Nf9Sle+5zwoB2hr/qUr33OeFAO0Nf9Sle+5zwoB17W3Pw3KhJMC4EBPOKip8lS+ANQ0D8kwB//9k="/>
            <small>Ottieni questi contenuti in <a href="{concat("exportas/custom/alboonline/", $block.id)|ezurl(no)}">formato <abbr title="Comma-separated values">CSV</abbr></a></small>
        </p>

    </div>
{/if}

{/literal}

<div id="albboonline-preview" class="modal fade" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div id="albboonline-content" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>



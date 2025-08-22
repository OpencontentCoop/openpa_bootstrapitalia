{if is_set($fields.error)}

	<div class="alert alert-warning message-warning warning">{$fields.error|wash()}</div>

{else}
<div class="position-relative">
    {def $enable_filters_bando = and($fields.class_identifier|eq('bando'), openpaini('Trasparenza', 'ShowBandoFaseSelect', 'disabled')|eq('enabled'))}

    {if $fields.title}
      <h2 class="h4">{$fields.title|wash()}</h2>
    {/if}

    {def $current_language = ezini('RegionalSettings', 'Locale')}
    {def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
    {def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

    {if count($fields.facets)|gt(0)}
      <div class="state-navigation" data-group="{$fields.group_by}">
      {foreach $fields.facets as $index => $facet_button}{*
          *}<a href="#" class="btn btn-sm mr-1{if $index|eq(0)} btn-primary{else} btn-outline-primary{/if} me-1 mb-1">{$facet_button|wash()}</a>{*
      *}{/foreach}
      </div>
    {/if}

    {if $enable_filters_bando}
      <div class="form-group my-1">
        <label class="form-label p-0 m-0 d-none" for="bando-navigation">Filtra per fase</label>
        <select id="bando-navigation" class="form-control border" data-group="">
          <option value="">Filtra per fase</option>
          <option value="pubblicazione">Pubblicazione</option>
          <option value="affidamento">Affidamento</option>
          <option value="esecutiva">Esecutiva</option>
          <option value="sponsorizzazioni">Sponsorizzazioni</option>
          <option value="somma_urgenza">Procedure di somma urgenza e di protezione civile</option>
          <option value="finanza">Finanza di progetto</option>
        </select>
      </div>
      {run-once}
      {literal}
      <script id="tpl-bando-data" type="text/x-jsrender">
        {{:~i18n(data,'oggetto')}}
        <h6 class="m-0">{{:title}}</h6>
        <ul>
        {{for fieldsToDisplay ~content=data}}
          {{if ~i18n(~content,identifier)}}
            {{for ~i18n(~content,identifier)}}
              {{if ~i18n(name)}}
                <li><a href="/openpa/object/{{:id}}">{{:~i18n(name)}}</a></li>
              {{else}}
                <li><a href="{{:url}}">{{:displayName}}</a></li>
              {{/if}}
            {{/for}}
          {{/if}}
        {{/for}}
        </ul>
      </script>
      {/literal}
      {/run-once}
    {/if}

    <script type="text/javascript" language="javascript" class="init">
      moment.locale('{$moment_language}');
      $(document).ready(function () {ldelim}
        {if $enable_filters_bando}
        $.views.helpers($.opendataTools.helpers);
        var renderBandoData = function (row, currentFase){ldelim}
          row.fieldsToDisplay = [{ldelim}identifier: currentFase{rdelim}, {ldelim}identifier: currentFase+'_relations'{rdelim}]
          row.title = $('#bando-navigation option[value="'+currentFase+'"]').text()
          return $.templates('#tpl-bando-data').render(row)
        {rdelim};
        {/if}
        var fieldsDatatable{$table_index} = $('#container-{$node.node_id}-{$table_index}').opendataDataTable({ldelim}
          "builder":{ldelim}"query": '{$fields.query|wash(javascript)}'{rdelim},
          "table":{ldelim}
            "id": 'trasparenza-{$node.node_id}-{$table_index}',
            "template": '<table class="table table-striped display responsive no-wrap richtext-wrapper" cellspacing="0" width="100%"></table>'
          {rdelim},
          "datatable":{ldelim}
            "responsive": true,
            "order": {$fields.order},
            "language":{ldelim}
                "url": "{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}"
            {rdelim},
            "ajax": {ldelim}url: "{'opendata/api/datatable/search'|ezurl(no,full)}/"{rdelim},
            "lengthMenu": [ 30, 60, 90, 120 ],
            "columns": [{foreach $fields.class_fields as $field}{$field.column}{delimiter},{/delimiter}{/foreach}],
            "columnDefs": [
              {foreach $fields.class_fields as $index => $field}
                {ldelim}
                  "render": function ( data, type, row, meta ) {ldelim}
                    if (data) {ldelim}
                      {if is_set($field.matrix_column)}
                        var result = [];
                        $.each(data, function () {ldelim}
                            var row = this;
                            $.each(row, function (index, value) {ldelim}
                              if (index === '{$field.matrix_column}') {ldelim}
                                result.push(value);
                              {rdelim}
                            {rdelim});
                        {rdelim});
                        return result.join('<br />');
                      {elseif $field.template.type|eq('multifile')}
                        var result = '<ul class="list-unstyled">'
                        if (data.length > 0) {ldelim}
                          $.each(data, function () {ldelim}
                              result += '<li><a href="' + this.url + '">' + this.filename + '</a></li>';
                          {rdelim});
                        {rdelim}
                        result += '</ul>';
                        return result;
                      {else}
                        var link = null;
                        {if or($index|eq(0), $field.showLink)}
                            {if $fields.class_identifier|eq('time_indexed_role')}
                              link = typeof row.data['{$current_language}'].person[0] === 'object' ? "{'/openpa/object/'|ezurl(no)}/"+row.data['{$current_language}'].person[0].id : '#';
                            {else}
                              link = "{'/openpa/object/'|ezurl(no)}/"+row.metadata.id;
                            {/if}
                        {/if}
                        var value =  opendataDataTableRenderField('{$field.dataType}', '{$field.template.type}', '{$current_language}', data, type, row, meta, link);
                        {if and($enable_filters_bando, $field.identifier|eq('oggetto'))}
                          var currentFase = $('#bando-navigation').val()
                          if (currentFase.length > 0){ldelim}
                              value = renderBandoData(row, currentFase)
                          {rdelim}
                        {/if}
                        return value;
                      {/if}
                    {rdelim}
                    return '';
                  {rdelim},
                  "targets": [{$index}]
                {rdelim}
                {delimiter},{/delimiter}
              {/foreach}
            ]
          {rdelim}
        {rdelim}).data('opendataDataTable');

        {if count($fields.facets)|gt(0)}
        var currentFilterName = $('.state-navigation').data('group');
        var setCurrentFilter = function(){ldelim}
            var currentFilterValue = $('.state-navigation .btn-primary').text();
            fieldsDatatable{$table_index}.settings.builder.filters[currentFilterName] = {ldelim}
              'field': currentFilterName,
              {if $fields.group_by|ends_with('year____dt]')}
              'operator': 'range',
              'value': [currentFilterValue+'-01-01T00:00:00Z',currentFilterValue+'-12-31T00:00:00Z']
              {else}
              'operator': 'in',
              'value': [currentFilterValue]
              {/if}
            {rdelim};
        {rdelim};
        setCurrentFilter();

        $('.state-navigation .btn').on('click', function(e){ldelim}
          $('.state-navigation .btn-primary')
            .addClass('btn-outline-primary')
            .removeClass('btn-primary');
          $(this)
            .removeClass('btn-outline-primary')
            .addClass('btn-primary');
          setCurrentFilter();
          fieldsDatatable{$table_index}.loadDataTable();
          e.preventDefault();
        {rdelim});
        {/if}

        {if $enable_filters_bando}
        $('#bando-navigation').val('').on('change', function(e){ldelim}
          var value = $(this).val();
          if (value.length === 0){ldelim}
            fieldsDatatable{$table_index}.settings.builder.filters['fase_bando'] = null;
          {rdelim}else{ldelim}
            fieldsDatatable{$table_index}.settings.builder.filters['fase_bando'] = {ldelim}
              'field': 'raw[extra_'+value+'_si]',
              'operator': 'range',
              'value': ['1', '*']
            {rdelim};
          {rdelim}
          fieldsDatatable{$table_index}.loadDataTable();
          e.preventDefault();
        {rdelim});
        {/if}

        fieldsDatatable{$table_index}.loadDataTable();
      {rdelim});
    </script>
    <div class="my-4">
        <div id="container-{$node.node_id}-{$table_index}" style="font-size:.9em"></div>
        <div>
            <img alt="opendata" style="vertical-align: middle"
                 src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAYEBAQFBAYFBQYJBgUGCQsIBgYICwwKCgsKCgwQDAwMDAwMEAwODxAPDgwTExQUExMcGxsbHCAgICAgICAgICD/2wBDAQcHBw0MDRgQEBgaFREVGiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICD/wAARCAASAGEDAREAAhEBAxEB/8QAGwAAAQUBAQAAAAAAAAAAAAAAAAEDBAUHAgb/xAA2EAABAwIDBAgEBQUAAAAAAAACAQMEBREABhITFCHRBxUWIjFBVZMyUVSUI0JW0tNSYWJxc//EABkBAQADAQEAAAAAAAAAAAAAAAABAgMEBf/EACcRAAICAQIFBQADAAAAAAAAAAABAhEDBBITITFRkRQVMkFhcYGh/9oADAMBAAIRAxEAPwDU8l5O6PzyDSqxWqYw488zd54hMjM9S+AhdSWyeCJi0YOTpEN0W0jKfRDHZivHS45BM1JG2bbzhEoJcu6Gok0+d04YusMn/RG9HT2T+iNmRFjrSo5uzR2kZGm3XdQXQdV29SIl1TiuIWGXgbkK5k7ohbCcZU2IiU00bnJY7tkVtN08eN+GHCly5deg3IrukDJuTcvZZeqdPoMJZLZtiO2AzCxmiLwQk8sa6XEsk6fQrllSsz+U3Jiwm5r+V6OMZ0BcA9kpLoP4TIEeUhFfmqY71o8Ddc7MHlmNvE6wy087likA28qCKqyV0Uvh2ibW7d/LXbErQ4X3HGmPSo8uLUAp7+V6MMtwdojaN6kQF/MRi8oin9yXELR4Gr50OLMhyZ7cV8mJGW6QDo+KbA14L4Kio7ZUXyVOGLrQYn3I48hrrmH+nqP9u5/JifbsX75I9RIOuYf6eo/27n8mHt2L98j1EibRnaXVJbsJ+hUxpsoktxHGGTBwTaYIwUSU18CT5Yw1OihDG5K7NMeZt0JvD/8AWuPKOk1TIlIWpdGmXNm7u8qKKSYjyjrEXRUxRSC46ksa8L40xz2/wyslZbLkOnON05qQ4TzMJ2RIdDiO1dk3UluKooohEqomNfUvn+1/hXhjtXyg3OrFPqDToMBADZjGVpVG2sT7ug29K923mmIx56i13EoWxioZEjTGqgm9E1InSd424CiKgLs7snx74Lsk8cWjqWq/EHjI3S3FlSskyWYrDkh1XWbNsgplbaJfujdcW0DSycyM/wATKagVdk09Y7WXZrMp6CzTZUlWnjQ2GC1Dpb0JpLUicbrj1YqKfyVXZyu+w/XKlm+sQZkF+izBjySjEyO7ufhbuGlUujaKev8AyXhiMcMcGna+/vuTKTf0NNyM0s1iRVI9DmNPvQ9zBN3cXQuyFpHOIKhfBeypidsNu1yXWyLd3RErjGaKxNbmP0eaLwx2Y5ru7neVkdOvgCImr5J4Ytj2QVWuvciVsr+z+YfSZ32zv7cacSPdeSu1h2fzD6TO+2d/bhxI915G1lrlij1mPVXXpFOlMMjBnanXWXABLxTtciRExy62cXifNGuFPcRceEdp4Q6rVGS2TMx9tseAgDhoKf6RFwAnXda+vk+6fPAB13Wvr5PunzwAdd1r6+T7p88ACV2tot0qElF/7Oc8Addoa/6lK99znhQDtDX/AFKV77nPCgHaGv8AqUr33OeFAO0Nf9Sle+5zwoB2hr/qUr33OeFAO0Nf9Sle+5zwoB17W3Pw3KhJMC4EBPOKip8lS+ANQ0D8kwB//9k="/>
            <a class="btn btn-outline-primary btn-sm p-1" style="padding: 0 8px !important;font-size: 11px;"
               href="{concat("exportas/custom/csv_search/", $fields.query|urlencode, "/",$node.node_id)|ezurl(no)}"><abbr
                        title="Comma-separated values">CSV</abbr></a>
            <a class="btn btn-outline-primary btn-sm p-1" style="padding: 0 8px !important;font-size: 11px;"
               href="{concat("/api/opendata/v2/content/search/",$fields.query|urlencode)}"><abbr
                        title="JavaScript Object Notation">JSON</abbr></a>
            {if $fields.class_identifier|eq('lotto')}
                <a class="btn btn-outline-primary btn-sm p-1" style="padding: 0 8px !important;font-size: 11px;"
                   href={concat("exportas/avpc/",$fields.class_identifier,"/",$node.node_id)|ezurl()}><abbr
                            title="Xtensible Markup Language">ANAC (XML)</abbr></a>
                <a class="btn btn-outline-primary btn-sm p-1" style="padding: 0 8px !important;font-size: 11px;"
                   href={concat("exportas/csvsicopat/", $fields.class_identifier,"/",$node.node_id)|ezurl()}><abbr
                            title="Comma-separated values">SICOPAT</abbr></a>
            {/if}
        </div>
    </div>
</div>
{/if}

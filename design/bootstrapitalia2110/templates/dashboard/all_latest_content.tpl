<div class="my-3 p-3 bg-white rounded shadow-sm">
    <div class="row border-bottom border-gray pb-2 mb-0">
        <div class="col col-md-6">
            <h4>
                {'All latest content'|i18n( 'design/admin/dashboard/all_latest_content' )}
            </h4>
        </div>
        {def $users = fetch( 'content', 'list', hash( parent_node_id, ezini("UserSettings", "DefaultUserPlacement"),
        load_data_map, false(),
        sort_by, array('name', true()) ) )}
        {if count($users)}
            <div class="col col-md-6">
                <select id="latest-items-user-choose" multiple data-field="owner_id"
                        data-placeholder="Filtra per autore">
                    {foreach $users as $user}
                        <option value="{$user.contentobject_id}">{$user.name|wash()}</option>
                    {/foreach}
                </select>
            </div>
        {/if}
    </div>
    <div id="latest-items" class="pt-2"></div>
</div>

{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

<script type="text/javascript">
    {literal}

    $(document).ready(function () {
      let userSelect = $('#latest-items-user-choose').val('');
      let locale = "{/literal}{$current_language}{literal}";
      $('#latest-items').opendataDataTable({
        "builder": {"query": 'subtree [1]'},
        "datatable": {
          "ajax": {
            url: "{/literal}{'opendata/api/datatable/search'|ezurl(no,full)}{literal}/"
          },
          "order": [[2, 'desc']],
          "language": {
            "url": "{/literal}{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}{literal}"
          },
          "columns": [
            {
              "data": "metadata.name.ita-IT",
              "name": 'name',
              "title": "{/literal}{'Name'|i18n( 'design/admin/dashboard/all_latest_content' )}{literal}"
            },
            {
              "data": "metadata.classDefinition.name.ita-IT",
              "name": 'raw[meta_class_name_ms]',
              "title": "{/literal}{'Type'|i18n( 'design/admin/dashboard/all_latest_content' )}{literal}"
            },
            {
              "data": "metadata.modified",
              "name": 'modified',
              "title": "{/literal}{'Modified'|i18n( 'design/admin/content/draft' )}{literal}"
            },
            {
              "data": "metadata.published",
              "name": 'published',
              "title": "{/literal}{'Published'|i18n( 'design/admin/dashboard/all_latest_content' )}{literal}"
            },
            {
              "data": "metadata.ownerName.ita-IT",
              "name": 'owner_id',
              "title": "{/literal}{'Author'|i18n( 'design/admin/dashboard/all_latest_content' )}{literal}"
            }
          ],
          "columnDefs": [
            {
              "render": function (data, type, row, meta) {
                console.log(row)
                return '<a href="' + row.extradata[locale].urlAlias + '">' +data + '</a>';
              },
              "targets": 0
            },
            {
              "render": function (data, type, row, meta) {
                var validDate = moment(data, moment.ISO_8601);
                if (validDate.isValid()) {
                  return '<span style="white-space:nowrap">' + validDate.format("D MMMM YYYY, HH:mm") + '</span>';
                } else {
                  return data;
                }
              },
              "targets": '_all'
            }
          ],
        }
      }).data('opendataDataTable').attachFilterInput(userSelect).loadDataTable();
    });
    {/literal}
</script>
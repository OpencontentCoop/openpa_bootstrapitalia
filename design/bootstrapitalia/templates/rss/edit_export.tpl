<form action={"rss/edit_export"|ezurl} method="post" name="RSSExport">

    <h1>{'Edit <%rss_export_name> [RSS Export]'|i18n( 'design/ocbootstrap/rss/edit_export',, hash( '%rss_export_name', $rss_export.title ) )|wash}</h1>

    {section show=not($valid)}
        <div class="warning">
            <h2>{'Invalid input'|i18n( 'design/ocbootstrap/rss/edit_export' )}</h2>
            <ul>
                {section var=Errors loop=$validation_errors}
                    <li>{$Errors.item}</li>
                {/section}
            </ul>
        </div>
    {/section}

    <div class="form-group mb-3">
        <label for="exportName">{'Name'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <input class="form-control" id="exportName" type="text" name="title" value="{$rss_export.title|wash}"
               title="{'Name of the RSS export. This name is used in the Administration Interface only, to distinguish the different exports from each other.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
        <p class="form-text">
            {'Name of the RSS export. This name is used in the Administration Interface only, to distinguish the different exports from each other.'|i18n('design/ocbootstrap/rss/edit_export')}
        </p>
    </div>

    <div class="form-group mb-3">
        <label for="exportDescription">{'Description'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <textarea class="form-control border" id="exportDescription" name="Description" rows="3"
                  title="{'Use the description field to write a text explaining what users can expect from the RSS export.'|i18n('design/ocbootstrap/rss/edit_export')}">{$rss_export.description|wash}</textarea>
        <p class="form-text">
            {'Use the description field to write a text explaining what users can expect from the RSS export.'|i18n('design/ocbootstrap/rss/edit_export')}
        </p>
    </div>

    <div class="form-group mb-3">
        <label for="exportUrl">{'Site URL'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <input class="form-control" type="text" id="exportUrl" name="url" value="{$rss_export.url|wash}"/>
        <p class="form-text">
            {'Use this field to enter the base URL of your site. It is used to produce the URLs in the export, composed by the Site URL (e.g. "http://www.example.com/index.php") and the path to the object (e.g. "/articles/my_article"). The Site URL depends on your web server and eZ Publish configuration.'|i18n( 'design/ocbootstrap/rss/edit_export')}<br>
            {'Leave this field emty if you want system automaticaly detect the URL of your site from the URL you access feed with'|i18n( 'design/ocbootstrap/rss/edit_export')}
        </p>
    </div>

    <input type="hidden" name="RSSImageID" value="{$rss_export.image_id}"/>

    {*
    <div class="form-group mb-3">
        <label>{'Image'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <input type="text" readonly="readonly" size="45" value="{$rss_export.image_path|wash}"/>
        <input class="button" type="submit" name="BrowseImageButton"
               value="{'Browse'|i18n( 'design/ocbootstrap/rss/edit_export' )}"
               title="{'Click this button to select an image for the RSS export. Note that images only work with RSS version 2.0'|i18n('design/ocbootstrap/rss/edit_export')}"/>
    </div>
    {section name=RemoveImage show=eq( $rss_export.image_id, 0 )|not }
        <div class="form-group mb-3">
            <input class="button" type="submit" name="RemoveImageButton"
                   value="{'Remove image'|i18n( 'design/ocbootstrap/rss/edit_export' )}"
                   title="{'Click to remove image from RSS export.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
        </div>
    {/section}
    *}

    <div class="form-group mb-3">
        <label for="RSSVersion">{'RSS version'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <select class="form-control" name="RSSVersion" id="RSSVersion"
                title="{'Use this drop-down menu to select the RSS version to use for the export. You must select RSS 2.0 in order to export the image selected above.'|i18n('design/ocbootstrap/rss/edit_export')}">
            {section name=Version loop=$rss_version_array}
            <option
                    {section name=DefaultSet show=eq( $rss_export.rss_version, 0 )}
                    {section name=Default show=eq( $Version:item, $rss_version_default )}
                        selected="selected"
                    {/section}
                    {section-else}
                        {section name=Default2 show=eq( $Version:item, $rss_export.rss_version )}
                            selected="selected"
                        {/section}
                    {/section}
                    value="{$:item}">{$:item|wash}
            </option>
            {/section}
        </select>
        {*<p class="form-text mb-0">
            {'Use this drop-down menu to select the RSS version to use for the export. You must select RSS 2.0 in order to export the image selected above.'|i18n('design/ocbootstrap/rss/edit_export')}
        </p>*}
    </div>

    <div class="form-group mb-3">
        <label for="NumberOfObjects">{'Number of objects'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <select class="form-control" name="NumberOfObjects" id="NumberOfObjects"
                title="{'Use this drop-down to select the maximum number of objects included in the RSS feed.'|i18n('design/ocbootstrap/rss/edit_export')}">
            {section name=Number loop=$number_of_objects_array}
            <option
                    {section name=DefaultSet show=eq( $rss_export.number_of_objects, 0 )}
                    {section name=Default show=eq( $Number:item, $number_of_objects_default )}
                        selected="selected"
                    {/section}
                    {section-else}
                        {section name=Default2 show=eq( $Number:item, $rss_export.number_of_objects )}
                            selected="selected"
                        {/section}
                    {/section}
                    value="{$:item}">{$:item|wash}
            </option>
            {/section}
        </select>
        <p class="form-text mb-0">
            {'Use this drop-down to select the maximum number of objects included in the RSS feed.'|i18n('design/ocbootstrap/rss/edit_export')}
        </p>
    </div>

    <div class="form-group form-check my-2">
        <input type="checkbox" id="exportActive" name="active" {section show=$rss_export.active|eq( 1 )}checked="checked"{/section}
               title="{'Use this checkbox to control if the RSS export is active or not. An inactive export will not be automatically updated.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
        <label class="form-check-label" for="exportActive">
            {'Active'|i18n( 'design/ocbootstrap/rss/edit_export' )}
            <p class="form-text mb-0">
                {'Use this checkbox to control if the RSS export is active or not. An inactive export will not be automatically updated.'|i18n('design/ocbootstrap/rss/edit_export')}
            </p>
        </label>
    </div>

    {*<div class="form-group form-check my-2">
        <input type="checkbox" name="MainNodeOnly" id="exportMainNodeOnly"
               {section show=$rss_export.main_node_only|eq( 1 )}checked="checked"{/section}
               title="{'Check if you want to only feed the object from the main node.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
        <label class="form-check-label" for="exportMainNodeOnly">
            {'Main node only'|i18n( 'design/ocbootstrap/rss/edit_export' )}
            <p class="form-text mb-0">
                {'Check if you want to only feed the object from the main node.'|i18n('design/ocbootstrap/rss/edit_export')}
            </p>
        </label>
    </div>*}
    <input type="hidden" name="MainNodeOnly" value="1">

    <div class="form-group mb-3">
        <label for="ExportAccess_URL">{'Access URL'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
        <div class="input-group">
            <div class="input-group-prepend">
                <span class="input-group-text" id="basic-addon1"><code>/rss/feed/</code></span>
            </div>
            <input required class="form-control" type="text" name="Access_URL" id="ExportAccess_URL" value="{$rss_export.access_url|wash}"
                   title="{'Use this field to set the URL where the RSS export should be available. Note that "rss/feed/" will be appended to the real URL. '|i18n('design/admin/rss/edit_export')|wash}"/>
        </div>
        <p class="form-text">
            {'Use this field to set the URL where the RSS export should be available. Note that "rss/feed/" will be appended to the real URL. '|i18n('design/admin/rss/edit_export')|wash}
        </o>
    </div>


    <input type="hidden" name="RSSExport_ID" value="{$rss_export.id}"/>
    <input type="hidden" name="Item_Count" value="{count($rss_export.item_list)}"/>

    {section name=Source loop=$rss_export.item_list}
        <div class="rounded border p-3 my-5">
            <div class="row">
                <div class="col-1 text-center position-relative">
                    <div class="my-3 bg-primary text-white d-inline-block px-3 py-1 font-weight-bold lead" style="border-radius:100%">{sum($Source:index, 1)}</div>
                    <button class="btn btn-link" type="submit" name="{concat( 'RemoveSource_', $Source:index )}" style="position: absolute;bottom: 10px;left: -4px;width: 100%;"
                            title="{'Click to remove this source from the RSS export.'|i18n('design/ocbootstrap/rss/edit_export')}"><i class="fa fa-trash fa-2x"></i></button>
                </div>
                <div class="col">
                    <input type="hidden" name="Item_ID_{$Source:index}" value="{$Source:item.id}"/>
                    <input type="hidden" name="Ignore_Values_On_Browse_{$Source:index}" id="Ignore_Values_On_Browse_{$Source:index}" value="{$Source:item.title|eq('')}"/>
                    <div class="form-group mb-4">
                        <label>{'Source path'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <input type="text" readonly="readonly" style="width:310px" value="{$Source:item.source_path|wash}"/>
                            </div>
                            <input class="button" type="submit" name="{concat( 'SourceBrowse_', $Source:index )}"
                                   value="{'Browse'|i18n( 'design/ocbootstrap/rss/edit_export' )}"
                                   title="{'Click this button to select the source node for the RSS export source. Objects of the type selected in the drop-down below published as sub items of the selected node will be included in the RSS export.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
                        </div>
                    </div>

                    <div class="form-group form-check mb-1">
                        <input type="checkbox" name="Item_Subnodes_{$Source:index}" id="Item_Subnodes_{$Source:index}"
                               {section show=$Source:item.subnodes|wash|eq( 1 )}checked="checked"{/section}
                               title="{'Activate this checkbox if objects from the subnodes of the source should also be fed.'|i18n('design/ocbootstrap/rss/edit_export')}"
                               onchange="document.getElementById('Ignore_Values_On_Browse_{$Source:index}').value=0;"/>
                        <label class="form-check-label" for="Item_Subnodes_{$Source:index}">
                            {'Subnodes'|i18n( 'design/ocbootstrap/rss/edit_export' )}
                            <p class="form-text mb-0">
                                {'Activate this checkbox if objects from the subnodes of the source should also be fed.'|i18n('design/ocbootstrap/rss/edit_export')}
                            </p>
                        </label>
                    </div>

                    <div class="form-group mb-2">
                        <label for="Item_Class_{$Source:index}">{'Class'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <select name="Item_Class_{$Source:index}" id="Item_Class_{$Source:index}" class="form-control"
                                        title="{'Use this drop-down to select the type of object that triggers the export. Click the "Set" button to load the correct attribute types for the remaining fields.'|i18n('design/ocbootstrap/rss/edit_export')|wash}"
                                        onchange="document.getElementById('Ignore_Values_On_Browse_{$Source:index}').value=0;">
                                    {section name=ContentClass loop=$rss_class_array }
                                        <option
                                                {section name=Class show=eq( $:item.id, $Source:item.class_id )}
                                                    selected="selected"
                                                {/section} value="{$:item.id}">{$:item.name|wash}</option>
                                    {/section}
                                </select>
                            </div>
                            <input class="button" type="submit" name="Update_Item_Class"
                                   value="{'Set'|i18n( 'design/ocbootstrap/rss/edit_export' )}"
                                   title="{'Click this button to load the correct values into the drop-down fields below. Use the drop-down menu on the left to select the class.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
                        </div>
                    </div>
                    {section name=Attribute show=count( $rss_export.item_list[$Source:index] )|gt( 0 )}
                    <div class="row">
                        <div class="col form-group">
                            <label for="Item_Class_Attribute_Title_{$Source:index}">{'Title'|i18n( 'design/ocbootstrap/rss/edit_export' )}:</label>
                            <select name="Item_Class_Attribute_Title_{$Source:index}" id="Item_Class_Attribute_Title_{$Source:index}" class="form-control"
                                    title="{'Use this drop-down to select the attribute that should be exported as the title of the RSS export entry.'|i18n('design/ocbootstrap/rss/edit_export')}"
                                    onchange="document.getElementById('Ignore_Values_On_Browse_{$Source:index}').value=0;">
                                {section name=ClassAttribute loop=$rss_export.item_list[$Source:index].class_attributes}
                                    <option value="{$:item.identifier}"
                                            {section name=ShowSelected show=eq( $Source:item.title, $:item.identifier )}
                                        selected="selected"
                                            {/section}>{$:item.name|wash}</option>
                                {/section}
                            </select>
                        </div>
                        <div class="col form-group">
                            <label for="Item_Class_Attribute_Description_{$Source:index}">{'Description'|i18n( 'design/ocbootstrap/rss/edit_export' )}
                                ({'optional'|i18n( 'design/ocbootstrap/rss/edit_export' )}):</label>
                            <select name="Item_Class_Attribute_Description_{$Source:index}" id="Item_Class_Attribute_Description_{$Source:index}" class="form-control"
                                    title="{'Use this drop-down to select the attribute that should be exported as the description of the RSS export entry.'|i18n('design/ocbootstrap/rss/edit_export')}"
                                    onchange="document.getElementById('Ignore_Values_On_Browse_{$Source:index}').value=0;">
                                <option value="">[{'Skip'|i18n('design/ocbootstrap/rss/edit_export')}]</option>
                                {section name=ClassAttribute loop=$rss_export.item_list[$Source:index].class_attributes}
                                    <option value="{$:item.identifier|wash}"
                                            {section name=ShowSelected show=eq( $Source:item.description, $:item.identifier )}
                                        selected="selected"
                                            {/section}>{$:item.name|wash}</option>
                                {/section}
                            </select>
                        </div>
                        <div class="col form-group">
                            <label for="Item_Class_Attribute_Category_{$Source:index}">{'Category'|i18n( 'design/ocbootstrap/rss/edit_export' )}
                                ({'optional'|i18n( 'design/ocbootstrap/rss/edit_export' )}):</label>
                            <select name="Item_Class_Attribute_Category_{$Source:index}" id="Item_Class_Attribute_Category_{$Source:index}" class="form-control"
                                    title="{'Use this drop-down to select the attribute that should be exported as the category of the RSS export entry.'|i18n('design/ocbootstrap/rss/edit_export')}"
                                    onchange="document.getElementById('Ignore_Values_On_Browse_{$Source:index}').value=0;">
                                <option value="">[{'Skip'|i18n('design/ocbootstrap/rss/edit_export')}]</option>
                                {section name=ClassAttribute loop=$rss_export.item_list[$Source:index].class_attributes}
                                    <option value="{$:item.identifier|wash}"
                                            {section name=ShowSelected show=eq( $Source:item.category, $:item.identifier )}
                                        selected="selected"
                                            {/section}>{$:item.name|wash}</option>
                                {/section}
                            </select>
                        </div>
                    </div>
                    {/section}
                </div>
            </div>
        </div>
    {/section}

    <div class="row mt-5">
        <div class="col-6">
            <button class="btn btn-info" type="submit" name="AddSourceButton"
                   title="{'Click to add a new source to the RSS export.'|i18n('design/ocbootstrap/rss/edit_export')}">
                <i class="fa fa-plus"></i> {'Add source'|i18n( 'design/ocbootstrap/rss/edit_export' )}
            </button>
        </div>
        <div class="col-6 text-right text-end">
            <input class="btn btn-success" type="submit" name="StoreButton"
                   value="{'Store'|i18n('opendata_forms')}"
                   title="{'Apply the changes and return to the RSS overview.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
            <input class="btn btn-dark" type="submit" name="RemoveButton"
                   value="{'Cancel'|i18n( 'design/ocbootstrap/rss/edit_export' )}"
                   title="{'Cancel the changes and return to the RSS overview.'|i18n('design/ocbootstrap/rss/edit_export')}"/>
        </div>
    </div>

</form>

{literal}
    <script type="text/javascript">
      window.onload = function () {
        document.getElementById('exportName').select();
        document.getElementById('exportName').focus();
      }
    </script>
{/literal}

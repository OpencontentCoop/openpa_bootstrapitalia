<input class="btn btn-sm btn-info ml-2"
       id="browse_objects_{$attribute.id}"
       type="submit"
       name="CustomActionButton[{$attribute.id}_browse_objects]"
       value="{'Select from library'|i18n('bootstrapitalia')}"
       title="{'Browse to add existing objects in this relation'|i18n( 'design/standard/content/datatype' )}" />
{ezscript_require(array('jquery.relationsbrowse.js'))}
<script>
$(document).ready(function () {ldelim}
    $('#browse_and_search_{$attribute.id}').relationsbrowse({ldelim}
        'attributeId': {$attribute.id},
        'subtree': {cond($browse_object_start_node, $browse_object_start_node, 1)},
        'addCloseButton': true,
        'allowAllBrowse': {cond(or(openpaini('RelationsBrowse', 'AllowAllBrowse', 'enabled')|eq('enabled'),openpaini('RelationsBrowse', 'AllowAllBrowseAttributes', array())|contains(concat($attribute.object.class_identifier,'/',$attribute.contentclass_attribute_identifier))), 'true', 'false')},
        'addCreateButton': false,
        'classes': {cond( and( is_set( $attribute.class_content.class_constraint_list ), $attribute.class_content.class_constraint_list|count|ne( 0 ) ), concat("['", $class_content.class_constraint_list|implode("','"), "']"), "[]")},
        'i18n':{ldelim}
            clickToClose: "{'Click to close'|i18n('opendata_forms')}",
            clickToOpenSearch: "{'Click to open search engine'|i18n('opendata_forms')}",
            search: "{'Search'|i18n('opendata_forms')}",
            clickToBrowse: "{'Click to browse contents'|i18n('opendata_forms')}",
            browse: "{'Browse'|i18n('opendata_forms')}",
            createNew: "{'Create new'|i18n('opendata_forms')}",
            create: "{'Create'|i18n('opendata_forms')}",
            allContents: "{'All contents'|i18n('opendata_forms')}",
            clickToBrowseParent: "{'Click to view parent'|i18n('opendata_forms')}",
            noContents: "{'No contents'|i18n('opendata_forms')}",
            back: "{'Back'|i18n('opendata_forms')}",
            goToPreviousPage: "{'Go to previous'|i18n('opendata_forms')}",
            goToNextPage: "{'Go to next'|i18n('opendata_forms')}",
            clickToBrowseChildren: "{'Click to view children'|i18n('opendata_forms')}",
            clickToPreview: "{'Click to preview'|i18n('opendata_forms')}",
            preview: "{'Preview'|i18n('opendata_forms')}",
            closePreview: "{'Close preview'|i18n('opendata_forms')}",
            addItem: "{'Add'|i18n('opendata_forms')}",
            selectedItems: "{'Selected items'|i18n('opendata_forms')}",
            removeFromSelection: "{'Remove from selection'|i18n('opendata_forms')}",
            addToSelection: "{'Add to selection'|i18n('opendata_forms')}",
            store: "{'Store'|i18n('opendata_forms')}",
            storeLoading: "{'Loading...'|i18n('opendata_forms')}"
        {rdelim}
    {rdelim}).on('relationsbrowse.close', function (event, opendataBrowse) {ldelim}
        $('#browse_and_search_{$attribute.id}').toggle();
    {rdelim}).hide();

    $('#browse_objects_{$attribute.id}').on('click', function (e) {ldelim}
        $('#browse_and_search_{$attribute.id}').data('plugin_relationsbrowse').init();
        $('#browse_and_search_{$attribute.id}').toggle();
        e.preventDefault();
    {rdelim});
{rdelim})
</script>
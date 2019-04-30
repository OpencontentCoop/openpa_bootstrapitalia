<input class="btn btn-sm btn-info ml-2"
       id="browse_objects_{$attribute.id}"
       type="submit"
       name="CustomActionButton[{$attribute.id}_browse_objects]"
       value="Seleziona dalla libreria"
       title="{'Browse to add existing objects in this relation'|i18n( 'design/standard/content/datatype' )}" />
{run-once}
{ezscript_require(array('jquery.relationsbrowse.js'))}
{/run-once}
<script>
$(document).ready(function () {ldelim}
    $('#browse_and_search_{$attribute.id}').relationsbrowse({ldelim}
        'attributeId': {$attribute.id},
        'subtree': {cond($browse_object_start_node, $browse_object_start_node, 1)},
        'addCloseButton': true,
        'addCreateButton': false,
        'classes': {cond( and( is_set( $attribute.class_content.class_constraint_list ), $attribute.class_content.class_constraint_list|count|ne( 0 ) ), concat("['", $class_content.class_constraint_list|implode("','"), "']"), "[]")}
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
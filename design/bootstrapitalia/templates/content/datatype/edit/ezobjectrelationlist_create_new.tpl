{if and( is_set( $attribute.class_content.class_constraint_list ), $attribute.class_content.class_constraint_list|count|ne( 0 ), $browse_object_start_node )}
    {def $classes = array()}
    {def $parent_node = fetch(content, node, hash(node_id, $browse_object_start_node))
         $can_instantiate_class_list = fetch(content, can_instantiate_class_list, hash(parent_node, $parent_node))
         $can_instantiate_classes = array()}
    {foreach $can_instantiate_class_list as $class}
        {set $can_instantiate_classes = $can_instantiate_classes|append($class.identifier)}
    {/foreach}
    {foreach $attribute.class_content.class_constraint_list as $class_identifier}
        {if $can_instantiate_classes|contains($class_identifier)}
            {def $_class = fetch( 'content', 'class', hash( 'class_id', $class_identifier) )}
            {if $_class}
                {set $classes = $classes|append($_class)}
            {/if}
            {undef $_class}
        {/if}
    {/foreach}
    {if count($classes)}
    <div class="btn-group create-relation-buttons">
        {if count($classes)|gt(1)}
        <button type="button" class="btn btn-sm btn-info ml-2 dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            {'Create new'|i18n('bootstrapitalia')}
            {display_icon('it-expand', 'svg', 'icon-expand icon icon-xs')}
        </button>
        <div class="dropdown-menu">
            <div class="link-list-wrapper">
                <ul class="link-list">
                    {foreach $classes as $class}
                    <li>
                        <a class="list-item" href="#" data-create-relation data-attribute="{$attribute.id}" data-class="{$class.identifier}" data-parent="{$browse_object_start_node}">
                            {$class.name|wash()}
                        </a>
                    </li>                    
                    {/foreach}
                </ul>
            </div>
        </div>
        {else}
            <a class="btn btn-sm btn-info ml-1" href="#" data-create-relation data-attribute="{$attribute.id}" data-class="{$classes[0].identifier}" data-parent="{$browse_object_start_node}">
                {'Create'|i18n('bootstrapitalia')} {$classes[0].name|downcase|wash()}
            </a>
        {/if}
    </div>
    {/if}
    {undef $classes $parent_node $can_instantiate_class_list $can_instantiate_classes}
{/if}

{run-once}
{literal}
<script type="text/javascript">
$(document).ready(function(){
    $('[data-create-relation]').on('click', function (e) {
        var self = $(this);
        var container = $('#create_new_'+self.data('attribute'));
        container.opendataFormCreate({
            class: self.data('class'),
            parent: self.data('parent')
        },
        {
            connector: 'essential',
            onBeforeCreate: function(){
                container.show();
                self.hide();
            },
            onSuccess: function(data){
                var priority = parseInt(container.parent().prev().find('input[name^="ContentObjectAttribute_priority"]:last-child').val()) || 0;
                priority++;
                $.ez('ezjsctemplate::relation_list_row::'+data.content.metadata.id+'::'+self.data('attribute')+'::'+priority+'::?ContentType=json', false, function(content){
                    if (content.error_text.length) {
                        alert(content.error_text);
                    }else{
                        var table = container.parents( ".ezcca-edit-datatype-ezobjectrelationlist" ).find('table').show().removeClass('hide');
                        table.find('tr.hide').before(content.content);
                        table.find('.ezobject-relation-remove-button').removeClass('hide');
                    }
                    container.hide().alpaca('destroy').html('');
                    self.show();
                });
            },
            i18n: {{/literal}
                'store': "{'Store'|i18n('opendata_forms')}",
                'cancel': "{'Cancel'|i18n('opendata_forms')}",
                'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
                'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
                'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
            {literal}},
            alpaca:{
                "options": {
                    "form": {
                        "buttons": {
                            "submit": {
                                "styles": "btn btn-sm btn-success pull-right"
                            },
                            "reset": {
                                "click": function () {
                                    container.hide().alpaca('destroy').html('');
                                    self.show();
                                },
                                'id': "reset-" + self.data('attribute') + "button",
                                "value": "{/literal}{'Cancel'|i18n('opendata_forms')}{literal}",
                                "styles": "btn btn-sm btn-dark pull-left"
                            }
                        }
                    }
                }
            }
        });
        e.preventDefault();
    })
});
</script>
{/literal}
{/run-once}
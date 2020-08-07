{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
    @var eZContentClassAttribute $attribute
*}
{if and(is_set($attribute.data_type_string), $attribute.is_information_collector)}
    <td class="text-center" colspan="3"><em>information collector</em></td>
{else}
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show]"
                       value="1" {if $handler.show|contains($attribute.identifier)}checked="checked"{/if} /> Mostra
            </label>
        </div>
    </td>
    <td>
        {if and( is_set($attribute.data_type_string), array('ezimage')|contains($attribute.data_type_string)|not())}
            <div class="checkbox">
                <label>
                    <input type="checkbox"
                           name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_label]"
                           value="1" {if $handler.show_label|contains($attribute.identifier)}checked="checked"{/if} />
                    Mostra etichetta
                </label>
            </div>
        {/if}
    </td>
    <td>
        {if and( is_set($attribute.data_type_string), array('ezobjectrelation', 'ezobjectrelationlist')|contains($attribute.data_type_string))}
            <div class="checkbox">
                <label>
                    <input type="checkbox"
                           name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_link]"
                           value="1" {if $handler.show_link|contains($attribute.identifier)}checked="checked"{/if} /> Mostra
                    link (oggetto correlato)
                </label>
            </div>
        {/if}
    </td>
{/if}
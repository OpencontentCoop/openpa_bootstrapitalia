{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
    @var eZContentClassAttribute $attribute
*}
{if and(is_set($attribute.data_type_string), $attribute.is_information_collector)}
    <td class="text-center" colspan="8"><em>information collector</em></td>
{else}
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show]"
                       value="1" {if $handler.show|contains($attribute.identifier)}checked="checked"{/if} />
                <small>Mostra</small>
            </label>
        </div>
    </td>
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_label]"
                       value="1" {if $handler.show_label|contains($attribute.identifier)}checked="checked"{/if} /> <small>Mostra
                    etichetta (in raggruppamento)</small>
            </label>
        </div>
    </td>
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_empty]"
                       value="1" {if $handler.show_empty|contains($attribute.identifier)}checked="checked"{/if} /> <small>Mostra
                    anche se non popolato</small>
            </label>
        </div>
    </td>
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][collapse_label]"
                       value="1" {if $handler.collapse_label|contains($attribute.identifier)}checked="checked"{/if} />
                <small>Collassa etichetta</small>
            </label>
        </div>
    </td>
    <td>
        {if and( is_set($attribute.data_type_string), or($attribute.data_type_string|eq('ezimage'), $attribute.identifier|eq('image')) )}
            <div class="checkbox">
                <label>
                    <input type="checkbox"
                           name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_link]"
                           value="1" {if $handler.show_link|contains($attribute.identifier)}checked="checked"{/if} />
                    <small>Mostra solo galleria</small>
                </label>
            </div>
        {elseif and( is_set($attribute.data_type_string), array('ezobjectrelation', 'ezobjectrelationlist')|contains($attribute.data_type_string))}
            <label for="{$class.identifier}-{$attribute.identifier}-show_link"><small>Visualizza come</small></label>
            <select id="{$class.identifier}-{$attribute.identifier}-show_link"
                    class="form-control-sm"
                    name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_link]">
                <option value="0"{if and($handler.show_as_accordion|contains($attribute.identifier)|not(), $handler.show_link|contains($attribute.identifier)|not())} selected="selected"{/if}>Lista</option>
                <option value="1"{if $handler.show_link|contains($attribute.identifier)} selected="selected"{/if}>Embed</option>
                <option value="2"{if $handler.show_as_accordion|contains($attribute.identifier)} selected="selected"{/if}>Accordion</option>
            </select>
        {elseif and( is_set($attribute.data_type_string), array('eztags')|contains($attribute.data_type_string))}
            <div class="checkbox">
                <label>
                    <input type="checkbox"
                           name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][show_link]"
                           value="1" {if $handler.show_link|contains($attribute.identifier)}checked="checked"{/if} />
                    <small>Mostra link</small>
                </label>
            </div>
        {/if}
    </td>
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][highlight]"
                       value="1" {if $handler.highlight|contains($attribute.identifier)}checked="checked"{/if} /> <small>Evidenzia</small>
            </label>
        </div>
    </td>
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][in_overview]"
                       value="1" {if $handler.in_overview|contains($attribute.identifier)}checked="checked"{/if} /> <small>Visualizza
                    in apertura</small>
            </label>
        </div>
    </td>
    <td>
        {if and( is_set($attribute.data_type_string), or($attribute.data_type_string|eq('ezimage'), $attribute.identifier|eq('image')) )}
            <div class="checkbox">
                <label>
                    <input type="checkbox"
                           name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][main_image]"
                           value="1" {if $handler.main_image|contains($attribute.identifier)}checked="checked"{/if} />
                    <small>Immagine in apertura</small>
                </label>
            </div>
        {/if}
    </td>
{/if}
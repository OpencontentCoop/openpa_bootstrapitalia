{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
    @var eZContentClassAttribute $attribute
*}
<td>
    {if and( is_set($attribute.data_type_string), array('eztags')|contains($attribute.data_type_string))}
    <div class="checkbox">
        <label>
            <input type="checkbox" name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][icon_label]" value="1" {if $handler.icon_label|contains($attribute.identifier)}checked="checked"{/if} /> <small>Usa come etichetta</small>
        </label>
    </div>
    {/if}
</td>
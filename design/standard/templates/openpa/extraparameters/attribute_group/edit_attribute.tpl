{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
    @var eZContentClassAttribute $attribute
*}
{foreach $handler.group_list as $identifier => $name}
<td>
<div class="checkbox">
    <label>
        <input type="checkbox" name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][{$identifier}]" value="1" {if $handler[$identifier]|contains($attribute.identifier)}checked="checked"{/if} /> {$name|wash()}
    </label>
</div>
</td>
{/foreach}
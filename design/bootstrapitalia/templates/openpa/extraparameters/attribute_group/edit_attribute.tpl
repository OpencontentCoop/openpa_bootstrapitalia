{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
    @var eZContentClassAttribute $attribute
*}
{if and(is_set($attribute.data_type_string), $attribute.is_information_collector)}
    <td class="text-center" colspan="{$handler.group_list|count()}"><em>information collector</em></td>
{else}
{foreach $handler.group_list as $identifier => $name}
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox"
                       name="extra_handler_{$handler.identifier}[class_attribute][{$class.identifier}][{$attribute.identifier}][{$identifier}]"
                       value="1"
                       {if $handler[$identifier]|contains($attribute.identifier)}checked="checked"{/if} /> {$name|wash()}
            </label>
        </div>
    </td>
{/foreach}
{/if}
{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
*}

{foreach $handler.group_list as $identifier => $name}
    <div class="checkbox">
        <label>
            <input type="checkbox" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][{$identifier}]" value="{$name|wash()}" checked="checked"/> {$name|wash()}
        </label>
    </div>
{/foreach}

<div class="form-group mt-4">
    <label for="add-{$handler.identifier}">Aggiungi gruppo</label>
    <input id="add-{$handler.identifier}" type="text" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][add_group]" value=""  />
</div>

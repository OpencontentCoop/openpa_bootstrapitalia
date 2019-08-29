{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
*}

{if count($handler.group_list)|eq(0)}
<div class="checkbox">
    <label>
        <input type="checkbox" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][generate_from_class]" value="1"/> Genera gruppi dalle categorie di attributo
    </label>
</div>
{else}
<h6>Gruppi abilitati</h6>
{foreach $handler.group_list as $identifier => $name}
    <div class="checkbox">
        <label>
            <input type="checkbox" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][{$identifier}]" value="{$name|wash()}" checked="checked"/>
            <input style="display: inline;width: 35px;border: 1px solid #ccc;padding: 0 3px;height: auto;font-weight: normal;" type="number" size="2" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][sort::{$identifier}]" value="{if is_set($handler.sort_list[$identifier])}{$handler.sort_list[$identifier]}{else}0{/if}" />
            {$name|wash()}
        </label>
    </div>
{/foreach}
{/if}

<div class="form-group mt-5">
    <label for="add-{$handler.identifier}">Aggiungi gruppo</label>
    <input id="add-{$handler.identifier}" type="text" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][add_group]" value=""  />
</div>

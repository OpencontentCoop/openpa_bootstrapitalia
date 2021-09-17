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
    <div class="row">
        <div class="col">
            <div class="checkbox">
                <label>
                    <input type="checkbox" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][{$identifier}]" value="{$name|wash()}" checked="checked"/>
                    <input style="display: inline;width: 35px;border: 1px solid #ccc;padding: 0 3px;height: auto;font-weight: normal;" type="number" size="2" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][sort::{$identifier}]" value="{if is_set($handler.sort_list[$identifier])}{$handler.sort_list[$identifier]}{else}0{/if}" />
                    {$name|wash()}
                </label>
            </div>
        </div>
        {foreach ezini('RegionalSettings', 'SiteLanguageList') as $locale}
        <div class="col">
            <img style="max-width:none" src="/share/icons/flags/{$locale}.gif" />
            <input style="border: 1px solid #ccc;padding: 0 3px;height: auto;font-weight: normal;" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][{$locale}::{$identifier}]" value="{if is_set($handler.translations[$identifier][$locale])}{$handler.translations[$identifier][$locale]}{else}{$name|wash()}{/if}" />
        </div>
        {/foreach}
    </div>
{/foreach}
{/if}

<div class="checkbox mt-3">
    <label>
        <input type="checkbox" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][hide_index]" {if $handler.hide_index}checked="checked"{/if} value="1"/> Nascondi l'indice della pagina
    </label>
</div>

<div class="form-group mt-5">
    <label for="add-{$handler.identifier}">Aggiungi gruppo</label>
    <input id="add-{$handler.identifier}" type="text" name="extra_handler_{$handler.identifier}[class][{$class.identifier}][add_group]" value=""  />
</div>

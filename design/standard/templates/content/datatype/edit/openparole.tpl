{default attribute_base='ContentObjectAttribute' html_class='full'}
    <div class="mb-3">
        <label for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
            {'Number of items per page:'|i18n('design/admin/node/view/full')}
        </label>
        <input
                id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
                class="form-control"
                type="number"
                name="{$attribute_base}_openparole_pagination_{$attribute.id}"
                value="{if is_set($attribute.content.settings.pagination)}{$attribute.content.settings.pagination|wash( xhtml )}{else}6{/if}"
        />
    </div>
{if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'advanced_editor_tools' ) )}
    <div class="mb-3">
        <label for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_override">{'Filtra per tipo'|i18n( 'openparoletype' )}:</label>
        <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_override" class="form-control" name="{$attribute_base}_openparole_filters_{$attribute.id}[]" multiple>
            {foreach api_tagtree($attribute.class_content.roletype_root_tag).children as $tag}
            <option value="{$tag.id|wash()}" {if and(is_set($attribute.content.settings.filters), $attribute.content.settings.filters|contains($tag.id))}selected="selected"{/if}>
                {$tag.keywordTranslations|implode(', ')}{if count($tag.synonyms)}, {$tag.synonyms|implode(', ')}{/if}
            </option>
            {/foreach}
        </select>
    </div>
{/if}
{/default}

<div class="mb-3">
    <p class="mb-0">Impostazioni di default:</p>
    {class_attribute_view_gui class_attribute=$attribute.contentclass_attribute}
</div>

<p>
    <a href="{'openpa/roles'|ezurl(no)}"
      target="_blank"
      rel="noopener">
      Vai a Gestione ruoli amministrativi
    </a>
</p>


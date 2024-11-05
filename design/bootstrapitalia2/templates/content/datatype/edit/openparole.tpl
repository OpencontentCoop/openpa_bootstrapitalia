{default attribute_base='ContentObjectAttribute' html_class='full'}

    {include uri='design:content/datatype/edit/openparole_editor.tpl'}

    <div class="mb-3">
        <label class="mb-2" for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
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
    {def $current_sort = cond(and(is_set($attribute.content.settings.sort), $attribute.content.settings.sort), $attribute.content.settings.sort, $attribute.contentclass_attribute.content.sort)}
    <div class="mb-3">
        <label class="mb-2" for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_sort">
            {'Ordina per'|i18n( 'openparoletype' )}
        </label>
        <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_sort"
                name="{$attribute_base}_openparole_sort_{$attribute.id}"
                class="form-control">
            <option value="1" {if $current_sort|eq(1)}selected="selected"{/if}>{'Nome persona'|i18n( 'openparoletype' )} ({'Ascending'|i18n('openpa/search')|downcase()})</option>
            <option value="2" {if $current_sort|eq(2)}selected="selected"{/if}>{'Nome struttura'|i18n( 'openparoletype' )} ({'Ascending'|i18n('openpa/search')|downcase()})</option>
            <option value="3" {if $current_sort|eq(3)}selected="selected"{/if}>{'Tipo di ruolo'|i18n( 'openparoletype' )} ({'Ascending'|i18n('openpa/search')|downcase()})</option>
            <option value="100" {if $current_sort|eq(100)}selected="selected"{/if}>{'Priority'|i18n( 'design/standard/websitetoolbar/sort' )} ({'Descending'|i18n('openpa/search')|downcase()})</option>
        </select>
    </div>

{if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'advanced_editor_tools' ) )}
        <div class="accordion">
                <div class="accordion-item">
                    <h2 class="accordion-header" id="heading-{$attribute.id}">
                        <button class="accordion-button collapsed" type="button"
                                data-bs-toggle="collapse" data-bs-target="#collapse-{$attribute.id}" aria-expanded="false" aria-controls="collapse-{$attribute.id}">
                            {'Settings'|i18n('settings/edit')}
                        </button>
                    </h2>
                    <div id="collapse-{$attribute.id}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{$attribute.id}">
                        <div class="accordion-body">
                            <div class="mb-3">
                                <label class="h6 mb-2" for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_override">{'Filtra per tipo'|i18n( 'openparoletype' )}:</label>
                                <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_override" class="form-control" name="{$attribute_base}_openparole_filters_{$attribute.id}[]" multiple>
                                    {foreach api_tagtree($attribute.class_content.roletype_root_tag).children as $tag}
                                        <option value="{$tag.id|wash()}" {if and(is_set($attribute.content.settings.filters), $attribute.content.settings.filters|contains($tag.id))}selected="selected"{/if}>
                                            {$tag.keywordTranslations|implode(', ')}{if count($tag.synonyms)}, {$tag.synonyms|implode(', ')}{/if}
                                        </option>
                                    {/foreach}
                                </select>
                            </div>
                            <div class="mb-3">
                                <h6 class="mb-2">Impostazioni di default:</h6>
                                {class_attribute_view_gui class_attribute=$attribute.contentclass_attribute}
                            </div>
                            <div class="mb-3">
                                <h6 class="mb-2">Query:</h6>
                                <pre style="white-space: break-spaces">{$attribute.content.query}</pre>
                            </div>
                        </div>
                    </div>
                </div>
        </div>
    {/if}
{/default}



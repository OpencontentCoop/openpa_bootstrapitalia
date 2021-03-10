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
{/default}

<a target="_blank" href="{'openpa/roles'|ezurl(no)}"><small>Vai a Gestione Ruoli</small></a>


{def $class_attribute_content = $class_attribute.content}

<div class="block"></div>
<div class="block">

	<div class="element">
	    <label>{'Cerca per'|i18n( 'openparoletype' )}:</label>
	    <select class="box" name="ContentClass_openparole_select_{$class_attribute.id}">
		    <option value="1" {if $class_attribute_content.select|eq(1)}selected="selected"{/if}>{'Persona'|i18n( 'openparoletype' )}</option>
		    <option value="2" {if $class_attribute_content.select|eq(2)}selected="selected"{/if}>{'Struttura'|i18n( 'openparoletype' )}</option>
	    </select>
	</div>

	<div class="element">
	    <label>{'Visualizza'|i18n( 'openparoletype' )}:</label>
	    <select class="box" name="ContentClass_openparole_view_{$class_attribute.id}">
	    	<option value="2" {if $class_attribute_content.view|eq(2)}selected="selected"{/if}>{'Lista Strutture'|i18n( 'openparoletype' )}</option>
		    <option value="1" {if $class_attribute_content.view|eq(1)}selected="selected"{/if}>{'Lista Persone'|i18n( 'openparoletype' )}</option>		    
		    <option value="4" {if $class_attribute_content.view|eq(4)}selected="selected"{/if}>{'Strutture'|i18n( 'openparoletype' )}</option>
		    <option value="3" {if $class_attribute_content.view|eq(3)}selected="selected"{/if}>{'Persone'|i18n( 'openparoletype' )}</option>		    
	    </select>
	</div>

	<div class="element">
	    <label>{'Ordina per'|i18n( 'openparoletype' )}:</label>
	    <select class="box" name="ContentClass_openparole_sort_{$class_attribute.id}">
			<option value="1" {if $class_attribute_content.sort|eq(1)}selected="selected"{/if}>{'Nome persona'|i18n( 'openparoletype' )}</option>
		    <option value="2" {if $class_attribute_content.sort|eq(2)}selected="selected"{/if}>{'Nome struttura'|i18n( 'openparoletype' )}</option>
		    <option value="3" {if $class_attribute_content.sort|eq(3)}selected="selected"{/if}>{'Tipo di ruolo'|i18n( 'openparoletype' )}</option>
			<option value="100" {if $class_attribute_content.sort|eq(100)}selected="selected"{/if}>{'Priorità'|i18n( 'openparoletype' )}</option>
	    </select>
	</div>

	<div class="element">
	    <label>{'Filtra per tipo'|i18n( 'openparoletype' )}:</label>
	    <select class="box" name="ContentClass_openparole_filter_{$class_attribute.id}[]" multiple>		    
		    {foreach api_tagtree($class_attribute_content.roletype_root_tag).children as $tag}
				{def $used = array()}
				{foreach $tag.keywordTranslations as $translation}
					{if $used|contains($translation)|not()}
						<option value="{$translation|wash()}" {if $class_attribute_content.filter|contains($translation)}selected="selected"{/if}>{$translation|wash}</option>
						{set $used = $used|append($translation)}
					{/if}
				{/foreach}
				{undef $used}
		    {/foreach}
	    </select>
	</div>

</div>
{undef $class_attribute_content}
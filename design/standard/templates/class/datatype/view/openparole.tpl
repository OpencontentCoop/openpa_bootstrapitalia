{def $class_attribute_content = $class_attribute.content}
<div class="block"></div>
<div class="block row">

	<div class="element col">
	    <h6>{'Cerca per'|i18n( 'openparoletype' )}:</h6>
	    {if $class_attribute_content.select|eq(1)}{'Persona'|i18n( 'openparoletype' )}{/if}
	    {if $class_attribute_content.select|eq(2)}{'Struttura'|i18n( 'openparoletype' )}{/if}
	</div>

	<div class="element col">
	    <h6>{'Visualizza'|i18n( 'openparoletype' )}:</h6>
    	{if $class_attribute_content.view|eq(2)}{'Lista Strutture'|i18n( 'openparoletype' )}{/if}
	    {if $class_attribute_content.view|eq(1)}{'Lista Persone'|i18n( 'openparoletype' )}{/if}
	    {if $class_attribute_content.view|eq(4)}{'Strutture'|i18n( 'openparoletype' )}{/if}
	    {if $class_attribute_content.view|eq(3)}{'Persone'|i18n( 'openparoletype' )}{/if}
	</div>

	<div class="element col">
	    <h6>{'Ordina per'|i18n( 'openparoletype' )}:</h6>
	    {if $class_attribute_content.sort|eq(1)}{'Nome persona'|i18n( 'openparoletype' )}{/if}
	    {if $class_attribute_content.sort|eq(2)}{'Nome struttura'|i18n( 'openparoletype' )}{/if}
	    {if $class_attribute_content.sort|eq(3)}{'Tipo di ruolo'|i18n( 'openparoletype' )}{/if}	    
	</div>

	<div class="element col">
	    <h6>{'Filtra per tipo'|i18n( 'openparoletype' )}:</h6>
	    {if $class_attribute_content.filter|count()}
			{$class_attribute_content.filter|implode(', ')}
		{else}
			<em>{'Not specified'|i18n('design/standard/content/datatype')}</em>
		{/if}
	</div>

</div>
{undef $class_attribute_content}
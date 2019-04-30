<a href="{$attribute.content|wash( xhtml )}" target="_blank" title="apri il link in una pagina esterna (si lascerà il sito)">
	<div class="chip chip-simple chip-primary">
		<span class="chip-label">
			{if $attribute.data_text}{$attribute.data_text|wash( xhtml )}{else}{$attribute.content|wash( xhtml )}{/if}
		</span>
	</div>
</a>


<a class="text-truncate d-inline-block mw-100" href="{$attribute.content|wash( xhtml )}" target="_blank" title="apri il link {$attribute.content|wash( xhtml )} in una pagina esterna (si lascerà il sito)">
	{display_icon('it-link', 'svg', 'icon icon-xs')}{if $attribute.data_text}{$attribute.data_text|wash( xhtml )}{else}{$attribute.content|wash( xhtml )}{/if}
</a>


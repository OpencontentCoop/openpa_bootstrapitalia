<a class="text-truncate d-inline-block mw-100 text-decoration-none" href="{$attribute.content|wash( xhtml )}" target="_blank" title="apri il link {$attribute.content|wash( xhtml )} in una pagina esterna (si lascerà il sito)">
	{display_icon('it-link', 'svg', 'icon icon-sm d-inline-block mr-1 mt-1 mb-1 ml-0 float-left')}{if $attribute.data_text}{$attribute.data_text|wash( xhtml )}{else}{$attribute.content|wash( xhtml )}{/if}
</a>


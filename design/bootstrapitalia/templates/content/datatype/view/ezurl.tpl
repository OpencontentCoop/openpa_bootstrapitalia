<p>
  <a class="text-truncate d-inline-block mw-100"
    href="{$attribute.content|wash( xhtml )}"
    target="_blank"
    rel="noopener noreferrer">
      {display_icon('it-link', 'svg', 'icon icon-sm d-inline-block mr-1 me-1 mt-1 mb-1 ml-0 ms-0 float-left')}{if $attribute.data_text}{$attribute.data_text|wash( xhtml )}{else}{$attribute.content|wash( xhtml )}{/if}
  </a>
</p>


<div id="ezwt-ezlogo">
  <a href="{openpaini('DocsSettings', 'Url', 'http://www.opencontent.it/openpa')}" title="{openpaini('DocsSettings', 'Title', 'Documentazione OpenPA')}" target="_blank">
    {if openpaini('DocsSettings', 'ImageUrl', false())}
      <img src="{openpaini('DocsSettings', 'ImageUrl', false())}" width="66" height="25" alt="{openpaini('DocsSettings', 'Title', 'Documentazione OpenPA')}" />
    {else}
      <img src="{"websitetoolbar/ezwt-logo.png"|ezimage(no)}" width="66" height="25" alt="{openpaini('DocsSettings', 'Title', 'Documentazione OpenPA')}" />
    {/if}
  </a>
</div>

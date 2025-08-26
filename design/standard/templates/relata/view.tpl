<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title></title>
  <link href="https://fonts.googleapis.com/css2?family=Titillium+Web:ital,wght@0,300;0,400;0,600;0,700;1,200;1,400;1,600&display=swap"
        rel="stylesheet">
    {include uri="design:relata/style.tpl"}
</head>
<body class="A4">
<div id="header"></div>
<div id="footer"></div>

{def $homepage = fetch('openpa', 'homepage')
$site_name = ezini('SiteSettings','SiteName')
$contacts = openpapagedata().contacts}

<p class="text-center">
    {if $homepage|has_attribute('stemma')}
      <img src="{$homepage.data_map.stemma.content.medium.url|to_base64_image_data()}" alt="" width="150px"/>
    {else}
      <img src="{$homepage.data_map.logo.content.medium.url|to_base64_image_data()}" alt=""/>
    {/if}
</p>

<div class="text-center m-top">
  <h3>{$site_name|wash()}</h3>
    {if is_set($contacts.indirizzo)}
      <p>{$contacts.indirizzo|wash()}</p>
    {/if}
  <p>
      {if is_set($contacts.telefono)}Tel.: {$contacts.telefono}{/if}
      {if is_set($contacts.fax)}{if is_set($contacts.telefono)} - {/if}Fax: {$contacts.fax}{/if}
  </p>
  <p>
      {if is_set($contacts.email)}Email: {$contacts.email}{/if}
      {if is_set($contacts.pec)}{if is_set($contacts.email)} - {/if}Pec: {$contacts.pec}{/if}
      {if is_set($contacts.web)}{foreach $contacts.web|explode_contact() as $name => $link}{if or(is_set($contacts.email),is_set($contacts.pec))} - {/if}Sito web: {$link|wash()}{break}{/foreach}{/if}
  </p>
</div>

<div class="text-center m-top">
  <h1>Relata di pubblicazione</h1>
</div>

<div class="m-top">
  <p>Si certifica che il presente atto è stato pubblicato, ai sensi dell'art. 32 della legge 18 giugno 2009 n. 69 e
    s.m.i. nell'Albo pretorio dell'Ente e che contro di esso non sono pervenuti reclami.</p>
</div>

<div class="text-center m-top">
  <h2>Dati principali atto</h2>
</div>

<table style="width: 100%">
  <tr>
    <td width="200px">N. pubblicazione</td>
    <td>{if $object|has_attribute('has_code')}{$object|attribute('has_code').content|wash()}{/if}</td>
  </tr>
  <tr>
    <td>Ente</td>
    <td>{$site_name|wash()}</td>
  </tr>
  <tr>
    <td>Prot./Repertorio</td>
    <td>
        {if $object|has_attribute('protocollo')}Prot N {$object|attribute('protocollo').content|wash()}
          {if $object|has_attribute('data_protocollazione')}del {$object|attribute('data_protocollazione').content.timestamp|l10n(shortdate)}{/if}
        {/if}
    </td>
  </tr>
  <tr>
    <td>Oggetto</td>
    <td>{if $object|has_attribute('name')}{$object|attribute('name').content|wash()}{/if}</td>
  </tr>
  <tr>
    <td>Descrizione</td>
    <td>{if $object|has_attribute('abstract')}{$object|attribute('abstract').content|wash()|nl2br}{/if}</td>
  </tr>
  <tr>
    <td>Data pubblicazione</td>
    <td>
        {if $object|has_attribute('publication_start_time')}Dal {$object|attribute('publication_start_time').content.timestamp|l10n(shortdate)}{/if}
        {if $object|has_attribute('publication_end_time')}al {$object|attribute('publication_end_time').content.timestamp|l10n(shortdate)}{/if}
    </td>
  </tr>
  <tr>
    <td>Fa parte di</td>
    <td>
      {if $object|has_attribute('document_type')}
          {foreach $object|attribute('document_type').content.tags as $tag}{$tag.keyword|wash}{delimiter}, {/delimiter}{/foreach}
      {/if}
    </td>
  </tr>
  <tr>
    <td>Allegati</td>
    <td>
      {def $attachments = array()}
      {if $object|has_attribute('file')}
          {set $attachments = $attachments|append($attribute.content.original_filename|clean_filename()|wash( xhtml ))}
      {/if}
      {if $object|has_attribute('attachments')}
        {foreach $object|attribute('attachments').content as $file}
          {if $file.display_name|ne('')}
              {set $attachments = $attachments|append(concat($file.display_name|clean_filename()|wash( xhtml ), ' (', $file.original_filename|wash(), ')'))}
          {else}
              {set $attachments = $attachments|append($file.original_filename|clean_filename()|wash( xhtml ))}
          {/if}
        {/foreach}
      {/if}
      {if $object|has_attribute('link')}
          {set $attachments = $attachments|append($object|attribute('link').content|wash( xhtml ))}
      {/if}
      {if $object|has_attribute('links')}
        {foreach $object|attribute('links').content.rows.sequential as $row}
          {set $attachments = $attachments|append($row.columns[1]|wash())}
        {/foreach}
      {/if}
      <ul style="margin:0;padding-left: 0;list-style: none;">{foreach $attachments as $attachment}<li>{$attachment}</li>{/foreach}</ul>
    </td>
  </tr>
</table>

<div class=" m-top">
  <p>{$site_name|wash()}, {currentdate()|l10n( date )}</p>
</div>

<div class="m-top" style="width:35%">
  <hr/>
</div>

<div class=" m-top">
  <p>Attestazione rilasciata automaticamente dal sistema informatico del {$site_name|wash()}, su richiesta dell'operatore,
    sulla base dei dati ivi registrati.</p>
</div>

<!--DEBUG_REPORT-->
</body>
</html>
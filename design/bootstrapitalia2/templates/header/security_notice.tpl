{* Rendered outside any {cache-block}: this must always execute fresh so it
   never gets frozen inside the header/menu cache-block (which has its own
   long expiry unrelated to this setting). *}
{def $security_alert_url = openpaini('SecurityNoticeSettings', 'ScriptUrl', '')
     $security_alert_id = openpaini('SecurityNoticeSettings', 'Id', '')
     $security_alert_layout = openpaini('SecurityNoticeSettings', 'Layout', '')}
{if $security_alert_url|ne('')}
  <script src="{$security_alert_url|wash(xhtml)}"{if $security_alert_id|ne('')} data-comune="{$security_alert_id|wash(xhtml)}"{/if}{if $security_alert_layout|ne('')} data-layout="{$security_alert_layout|wash(xhtml)}"{/if}></script>
{/if}

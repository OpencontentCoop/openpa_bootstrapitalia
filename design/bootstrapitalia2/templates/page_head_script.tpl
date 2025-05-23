{def $is_logged_in = cond(fetch('user','current_user').is_logged_in, true(), false())}
{def $scripts = array(
  'ezjsc::jquery',
  'ezjsc::jqueryio',
  'moment-with-locales.min.js',
  'jquery.opendataTools.js',
  'chosen.jquery.js'
)}
{if $is_logged_in}
  {set $scripts = $scripts|merge(array(
    'ezjsc::jqueryUI',
    'jsrender.js',
    'handlebars.min.js',
    'alpaca.js',
    'jquery.opendataform.js',
    'leaflet/leaflet.0.7.2.js',
    'leaflet/Control.Geocoder.js',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/leaflet.activearea.js',
    'leaflet/leaflet.markercluster.js',
    'jquery.sharedlink.js',
    'jquery.blueimp-gallery.min.js',
    'stacktable.js',
    'jquery.opendataDataTable.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap4.min.js'
  ))}
  {ezscript_load($scripts)}
{else}
  {* gli script caricati tramite ezscript_require sono in pagelayout -> page_footer_script.tpl *}
  {def $script_tag = ezscript($scripts)}
  {preload_script($script_tag)}
  {$script_tag}
  {undef $script_tag}
{/if}

{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', ezini('RegionalSettings', 'Locale') ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
{debug-log var=concat('Regional settings: ', ezini('RegionalSettings', 'Locale'), ' Http locale: ', $current_locale.http_locale_code, ' Moment: ', $moment_language) msg='Current language'}
{*
{if $moment_language|ne('it')}
    {set $scripts = $scripts|append(concat('datepicker/locales/', $moment_language, '.js'))}
{/if}
*}

<script type="text/javascript">
  //<![CDATA[
  var CurrentLanguage = "{ezini( 'RegionalSettings', 'Locale' )}";
  var CurrentUserIsLoggedIn = {cond($is_logged_in, 'true', 'false')};
  var CurrentUserId = {fetch('user','current_user').contentobject_id};
  var UiContext = "{$ui_context}";
  var UriPrefix = {'/'|ezurl()};
  {if and(openpacontext().is_edit|not(),openpacontext().is_browse|not())}
  var PathArray = [{if is_set( openpacontext().path_array[0].node_id )}{foreach openpacontext().path_array|reverse as $path}{$path.node_id}{delimiter},{/delimiter}{/foreach}{/if}];
  {/if}
  var ModuleResultUri = "{$module_result.uri|wash()}";
  var LanguageUrlAliasList = [{foreach $avail_translation as $siteaccess => $lang}{ldelim}locale:"{$lang.locale}",uri:"{$site.uri.original_uri|lang_selector_url($siteaccess)}"{rdelim}{delimiter},{/delimiter}{/foreach}];
  $.opendataTools.settings('endpoint',{ldelim}
    'geo': '{'/opendata/api/geo/search/'|ezurl(no)}/',
    'search': '{'/opendata/api/content/search/'|ezurl(no)}/',
    'class': '{'/opendata/api/classes/'|ezurl(no)}/',
    'tags_tree': '{'/opendata/api/tags_tree/'|ezurl(no)}/',
    'fullcalendar': '{'/opendata/api/fullcalendar/search/'|ezurl(no)}/'
  {rdelim});
  $.opendataTools.settings('language', "{ezini('RegionalSettings', 'Locale')}");
  var MomentDateFormat = "{'DD/MM/YYYY'|i18n('openpa/moment_date_format')}";
  var MomentDateTimeFormat = "{'DD/MM/YYYY HH:mm'|i18n('openpa/moment_datetime_format')}";
  moment.locale("{$moment_language}");
  {if fetch('user','current_user').is_logged_in|not()}
  {literal}
  if ('serviceWorker' in navigator) {if (!navigator.serviceWorker.controller) {navigator.serviceWorker.register('/service-worker.js', {scope: '/'}).then(function (registration) {}, function (err) {console.warn('Failed to register Service Worker:\n', err);});}}
  {/literal}
  {/if}
  {foreach built_in_app_variables() as $key => $value}window.{$key} = {if $value|eq('true')}true{else}'{$value}'{/if};{debug-log var=$value msg=$key}{/foreach}
  //]]>
</script>
{undef $scripts $current_locale $moment_language}
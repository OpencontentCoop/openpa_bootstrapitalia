{def $is_logged_in = cond(fetch('user','current_user').is_logged_in, true(), false())}
{def $scripts = array(
  'cookieconsent/cookieconsent.min.js',
  'ezjsc::jquery',
  'ezjsc::jqueryio',
  'moment-with-locales.min.js',
  'jquery.opendataTools.js',
  'chosen.jquery.js',
  'stacktable.js',
  'jquery.opendataDataTable.js',
  'jquery.dataTables.js',
  'dataTables.bootstrap4.min.js',
  'jquery.sharedlink.js',
  'jquery.blueimp-gallery.min.js',
  'ezjsc::jqueryUI'
)}
{if $is_logged_in}
  {set $scripts = $scripts|merge(array(
    'jsrender.js',
    'handlebars.min.js',
    'alpaca.js',
    'jquery.opendataform.js',
    'leaflet/leaflet.0.7.2.js',
    'leaflet/Control.Geocoder.js',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/leaflet.activearea.js',
    'leaflet/leaflet.markercluster.js'
  ))}
  {ezscript_load($scripts)}
{else}
  {ezscript($scripts)}
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
  var MomentDateFormat = "{'DD/MM/YYYY'|i18n('openpa/moment_date_format')}";
  var MomentDateTimeFormat = "{'DD/MM/YYYY HH:mm'|i18n('openpa/moment_datetime_format')}";
  moment.locale("{$moment_language}");
  //]]>
</script>
{undef $scripts $current_locale $moment_language}
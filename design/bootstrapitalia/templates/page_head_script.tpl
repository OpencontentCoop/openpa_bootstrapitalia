{def $scripts = array(
    'ezjsc::jquery',
    'ezjsc::jqueryUI',
    'ezjsc::jqueryio',
    'jquery.search-gui.js',
    'jquery.valuation.js',
    'popper.js',
    'owl.carousel.js',
    'moment-with-locales.min.js',
    'chosen.jquery.js',
    'jquery.opendataTools.js',
    'leaflet/leaflet.0.7.2.js',
    'leaflet/Control.Geocoder.js',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/leaflet.activearea.js',
    'leaflet/leaflet.markercluster.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap4.min.js',
    'jquery.opendataDataTable.js',
    'jquery.blueimp-gallery.min.js',
    'handlebars.min.js',
    'alpaca.js',
    'jquery.opendataform.js',
    'stacktable.js',
    'jsrender.js',
    'jquery.faqs.js',
    'jquery.sharedlink.js'
)}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', ezini('RegionalSettings', 'Locale') ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
{debug-log var=concat('Regional settings: ', ezini('RegionalSettings', 'Locale'), ' Http locale: ', $current_locale.http_locale_code, ' Moment: ', $moment_language) msg='Current language'}
{if $moment_language|ne('it')}
    {set $scripts = $scripts|append(concat('datepicker/locales/', $moment_language, '.js'))}
{/if}
{ezscript_load($scripts)}
{undef $scripts $current_locale $moment_language}

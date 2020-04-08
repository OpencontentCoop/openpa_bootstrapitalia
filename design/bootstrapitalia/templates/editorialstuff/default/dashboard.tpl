{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path', false() )}

{def $base_query = concat('classes [',$factory_configuration.ClassIdentifier,'] and subtree [', $factory_configuration.CreationRepositoryNode, '] sort [published=>desc]')}
{if fetch( 'user', 'has_access_to', hash( 'module', 'editorialstuff', 'function', 'full_dashboard' ) )|not}
    {set $base_query = concat($base_query, " and owner_id = ", fetch(user, current_user).contentobject_id)}
{/if}


<section class="container py-4">
    <div class="row">
        <div class="col">
            <ul class="nav nav-tabs nav-fill overflow-hidden">
                <li role="presentation" class="nav-item">
                    <a class="text-decoration-none nav-link active" style="font-size: 1.8em" data-toggle="tab"
                       href="#items">
                        {if is_set($factory_configuration.Name)}{$factory_configuration.Name|wash()}{else}{$factory_configuration.identifier|wash()}{/if}
                    </a>
                </li>
            </ul>
        </div>
    </div>

    {if $factory_configuration.CreationRepositoryNode}
        <div class="pt-4">
            <a class="btn btn-info rounded-0 text-white"
               href="{concat('editorialstuff/add/',$factory_identifier)|ezurl(no)}">
                <i class="fa fa-plus mr-2"></i> {$factory_configuration.CreationButtonText|wash()}
            </a>
        </div>
    {/if}

    <div class="tab-pane active" id="items">
        <div class="row py-4">
            <div class="col-md-9 py-2">
                {include uri='design:editorialstuff/parts/filters.tpl' use_search_text=true()}
            </div>
            <div class="col-md-3 py-2">
                <div class="btn-group">
                    <a class="py-2 chip chip-lg chip-primary no-minwith text-black dropdown-toggle text-decoration-none" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <span class="chip-label">{'State'|i18n('editorialstuff/dashboard')}:</span> <span class="chip-label ml-1 current-state-filter" data-text="{'All'|i18n('editorialstuff/dashboard')}">{'All'|i18n('editorialstuff/dashboard')}</span>
                        {display_icon('it-expand', 'svg', 'icon-expand icon icon-sm icon-primary filter-remove')}
                    </a>
                    <div class="dropdown-menu" style="min-width:250px; right: 0; left: auto">
                        <div class="link-list-wrapper">
                            <ul class="link-list state-filters">
                                {foreach $states as $state}
                                    <li>
                                        <a class="list-item dashboard-state-filter state-filter text-decoration-none"
                                           data-state_id="{$state.id|wash()}"
                                           data-state_identifier="{$state.identifier|wash()}"
                                           data-state_name="{$state.current_translation.name|wash()}"
                                           href="#">
                                            <div class="d-inline-block mr-1 rounded label-{$state.identifier|wash()}" style="width: 12px;height: 12px"></div>
                                            <small>{$state.current_translation.name|wash()}</small>
                                        </a>
                                    </li>
                                    {if is_set($state_group_identifier)|not()}
                                        {def $state_group_identifier = $state.group.identifier}
                                    {/if}
                                {/foreach}
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {def $views = array('list')}
        {if is_set($factory_configuration.Views)}
            {set $views = $factory_configuration.Views}
        {/if}

        <div class="row">
            <div class="col-1 mt-4">
                {include uri='design:editorialstuff/parts/vertical_pills.tpl' views=$views}
            </div>
            <div class="col-11">
                {include uri='design:editorialstuff/parts/views.tpl' views=$views view_style=''}
            </div>
        </div>
    </div>
</section>

{include uri='design:editorialstuff/parts/tpl-spinner.tpl'}
{include uri='design:editorialstuff/parts/tpl-empty.tpl'}
{include uri='design:editorialstuff/parts/tpl-dashboard-list.tpl'}
{include uri='design:editorialstuff/parts/dashboard-search-modal.tpl'}
{include uri='design:editorialstuff/parts/preview-modal.tpl'}
{include uri='design:editorialstuff/parts/workflow-styles.tpl'}

{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

{ezscript_require(array(
    'jquery.dashboard-search-gui.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'fullcalendar/core/main.js',
    concat('fullcalendar/core/locales/', $moment_language, '.js'),
    'fullcalendar/daygrid/main.js',
    'fullcalendar/list/main.js',
    'jsrender.js'
))}
{ezcss_require(array(
    'fullcalendar/core/main.css',
    'fullcalendar/daygrid/main.css',
    'fullcalendar/list/main.css'
))}

<script>
    $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
    $.opendataTools.settings('language', "{$current_language}");
    {if $current_language|ne('eng-GB')}
        $.opendataTools.settings('fallbackLanguage', "eng-GB");
    {/if}
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
    $.opendataTools.settings('base_query', "{$base_query}");
    $.opendataTools.settings('locale', "{$moment_language}");
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': {if $factory_configuration.HasExtraGeo}'{'/opendata/api/extrageo/search/'|ezurl(no,full)}/'{else}'{'/opendata/api/geo/search/'|ezurl(no,full)}/'{/if},
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}/',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}/',
        'tags_tree': '{'/opendata/api/tags_tree/'|ezurl(no,full)}/',
        'fullcalendar': '{'/opendata/api/calendar/search/'|ezurl(no,full)}/'
    {rdelim});
</script>


{literal}
<script>
    $(document).ready(function () {
        $('#dashboardSearchModal').dashboardSearchGui({
            'spritePath': '{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}',
            'factory': '{/literal}{$factory_identifier}{literal}',
            'stateGroup': '{/literal}{$state_group_identifier}{literal}',
        });
    });
</script>
{/literal}

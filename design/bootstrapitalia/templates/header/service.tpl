{def $header_service = openpaini('GeneralSettings','header_service', 1)
     $header_service_list = array()
     $is_area_tematica = is_area_tematica()}
{if $header_service|eq(1)}
    {if $pagedata.homepage|has_attribute('service_url')}
        {set $header_service_list = $header_service_list|append(hash(
            'url', $pagedata.homepage|attribute('service_url').content|wash(xhtml),
            'name', $pagedata.homepage|attribute('service_url').data_text|wash(xhtml)
        ))}
    {else}
        {set $header_service_list = $header_service_list|append(hash(
            'url', openpaini('InstanceSettings','UrlAmministrazioneAfferente', '#'),
            'name', openpaini('InstanceSettings','NomeAmministrazioneAfferente', 'OpenContent')
        ))}
    {/if}
{/if}
{if and($is_area_tematica, $is_area_tematica|has_attribute('logo'))}
    {set $header_service_list = $header_service_list|append(hash(
        'url', "/"|ezurl(no),
        'name', cond( $pagedata.homepage|has_attribute('site_name'), $pagedata.homepage|attribute('site_name').content|wash(), ezini('SiteSettings','SiteName'))
    ))}
{/if}

{def $header_links = array()}
{if and($is_area_tematica, $is_area_tematica|has_attribute('link'))}
    {foreach $is_area_tematica|attribute('link').content.relation_list as $relation_item}
        {def $content = fetch( content, node, hash( node_id, $relation_item.node_id ) )}
        {if $content.can_read}
            {set $header_links = $header_links|append($content)}
        {/if}
        {undef $content}
    {/foreach}
{elseif $pagedata.homepage|has_attribute('link_nell_header')}
    {foreach $pagedata.homepage|attribute('link_nell_header').content.relation_list as $relation_item}
        {def $content = fetch( content, node, hash( node_id, $relation_item.node_id ) )}
        {if $content.can_read}
            {set $header_links = $header_links|append($content)}
        {/if}
        {undef $content}
    {/foreach}
{/if}

{def $current_language = false()
     $global_avail_translation = language_switcher('/')
     $lang_selector = array()
     $uri = '/'}
{if $global_avail_translation|count|gt( 1 )}
    {foreach $global_avail_translation as $siteaccess => $lang}
        {if $siteaccess|eq( $access_type.name )}
            {set $current_language = $lang}
        {/if}
        {set $lang_selector = $lang_selector|append(hash(
            'is_current', cond($siteaccess|eq( $access_type.name ), true(), false()),
            'lang', $lang,
            'href', $uri|lang_selector_url( $siteaccess )
        ))}
    {/foreach}
{/if}

{def $hide_access = false()}
{if $pagedata.homepage|has_attribute('hide_access_menu')}
    {set $hide_access = cond($pagedata.homepage|attribute('hide_access_menu').data_int|eq(1), true(), false())}
{/if}
{def $editor_access_in_footer = false()}
{if $pagedata.homepage|has_attribute('editor_access_in_footer')}
    {set $editor_access_in_footer = cond($pagedata.homepage|attribute('editor_access_in_footer').data_int|eq(1), true(), false())}
{/if}

{def $link_area_personale = cond(is_set($pagedata.contacts.link_area_personale), $pagedata.contacts.link_area_personale, false())}
{def $link_area_personale_title = 'Access the personal area'|i18n('bootstrapitalia')}
{def $link_area_personale_parts = $link_area_personale|explode('|')}
{if count($link_area_personale_parts)|gt(1)}
    {set $link_area_personale = $link_area_personale_parts[0]}
    {set $link_area_personale_title = $link_area_personale_parts[1]}
{/if}

{if and($editor_access_in_footer, $link_area_personale|not)}
    {set $hide_access = true()}
{/if}

<div class="it-header-slim-wrapper{if current_theme_has_variation('light_slim')} theme-light{/if}">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-header-slim-wrapper-content">
                    {if $header_service_list|count()|gt(0)}
                        {foreach $header_service_list as $item}
                            <a class="d-none d-lg-block navbar-brand" href="{$item.url}">{$item.name|wash()}</a>
                        {/foreach}
                        <div class="nav-mobile">
                            <nav>
                                {if $header_links|count()}
                                <a class="d-lg-none navbar-brand"
                                   data-toggle="collapse"
                                   href="#service-menu"
                                   role="button"
                                   aria-expanded="false"
                                   aria-controls="service-menu">
                                    <span>{'Links'|i18n('openpa/footer')}</span>
                                    {display_icon('it-expand', 'svg', 'icon icon-white')}
                                </a>
                                <div class="link-list-wrapper collapse" id="service-menu">
                                    <ul class="link-list">
                                        {foreach $header_service_list as $item}
                                            <li class="list-item d-block d-md-none"><a href="{$item.url}">{$item.name|wash()}</a></li>
                                        {/foreach}
                                        {foreach $header_links as $header_link max 3}
                                            <li class="list-item text-nowrap">{node_view_gui content_node=$header_link view=text_linked}</li>
                                        {/foreach}
                                    </ul>
                                </div>
                                {else}
                                    <a class="d-lg-none navbar-brand" href="{$header_service_list[0].url}"><span>{$header_service_list[0].name|wash()}</span></a>
                                {/if}
                            </nav>
                        </div>
                    {/if}

                    <div class="header-slim-right-zone">
                        {if $lang_selector|count()}
                        <div class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle"
                               href="#"
                               data-toggle="dropdown"
                               aria-expanded="false">
                                <span>{$current_language.text|wash|upcase}</span>
                                {display_icon('it-expand', 'svg', 'icon d-none d-lg-block')}
                            </a>
                            <div class="dropdown-menu">
                                <div class="row">
                                    <div class="col-12">
                                        <div class="link-list-wrapper">
                                            <ul class="link-list">
                                                {foreach $lang_selector as $lang_selector_item}
                                                    <li>
                                                        <a href="{if $lang_selector_item.is_current}#{else}{$lang_selector_item.href}{/if}"
                                                           title="{$lang_selector_item.lang.text|wash|upcase}"
                                                           {if $lang_selector_item.is_current|not()}data-switch_locale="{$lang_selector_item.lang.locale}"{/if}
                                                           class="list-item text-nowrap">
                                                            <span lang="{fetch(content, locale, hash(locale_code, $lang_selector_item.lang.locale)).http_locale_code|explode('-')[0]}">{$lang_selector_item.lang.text|wash|upcase}</span>
                                                        </a>
                                                    </li>
                                                {/foreach}
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        {/if}

                        {if $hide_access|not()}
                        <div class="it-access-top-wrapper">
                            {if $link_area_personale}
                                {if $editor_access_in_footer|not()}
                                    <div data-login-top-button class="dropdown" data-icon="it-user" style="display: none;">
                                        <a href="#" class="btn btn-primary btn-icon btn-full dropdown-toggle" id="dropdown-user"
                                           data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="text-transform: none; font-size: 1rem">
                                            <span class="rounded-icon">
                                                {display_icon('it-user', 'svg', 'icon icon-primary notrasform')}
                                            </span>
                                            <span class="d-none d-lg-block text-nowrap">{'Access the personal area'|i18n('bootstrapitalia')}</span>
                                            {display_icon('it-expand', 'svg', 'icon-expand icon icon-white')}
                                        </a>
                                        <div class="dropdown-user dropdown-menu" aria-labelledby="dropdown-user">
                                            <div class="link-list-wrapper">
                                                <ul class="link-list">
                                                    <li>
                                                        <a class="list-item left-icon" href="{$link_area_personale}" title="{$link_area_personale_title|wash()}">
                                                            {display_icon('it-user', 'svg', 'icon icon-sm icon-primary left')}
                                                            <span class="d-none d-md-inline-block">{$link_area_personale_title|wash()}</span></a>
                                                    </li>
                                                    <li>
                                                        <a class="list-item ez-login left-icon" href="{"/user/login"|ezurl(no)}" title="{'Site editors access'|i18n('bootstrapitalia')}">
                                                            {display_icon('it-pencil', 'svg', 'icon icon-sm icon-primary left')}
                                                            <span class="d-none d-md-inline-block">{'Site editors access'|i18n('bootstrapitalia')}</span>
                                                        </a>
                                                    </li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                {else}
                                    <a data-login-top-button class="btn btn-primary btn-icon btn-full" href="{$link_area_personale}"
                                       data-icon="it-user"
                                       title="{$link_area_personale_title|wash()}">
                                         <span class="rounded-icon">{display_icon('it-user', 'svg', 'icon-primary')}</span>
                                        <span class="d-none d-lg-block text-nowrap">{$link_area_personale_title|wash()}</span>
                                    </a>
                                {/if}
                            {else}
                                <a data-login-top-button class="btn btn-primary btn-icon btn-full ez-login" href="{"/user/login"|ezurl(no)}"
                                   data-icon="it-user"
                                   title="{$link_area_personale_title|wash()}" style="display: none;">
                                     <span class="rounded-icon">{display_icon('it-user', 'svg', 'icon-primary')}</span>
                                    <span class="d-none d-lg-block text-nowrap">{$link_area_personale_title|wash()}</span>
                                </a>
                            {/if}
                        </div>
                        {else}
                            <span data-login-top-button class="d-none"></span>
                        {/if}
                        {*
                        <div class="it-access-top-wrapper{if $link_area_personale} d-flex{/if}">
                            {if is_set($link_area_personale)}
                                <a class="btn btn-primary btn-icon btn-full" href="{$link_area_personale}"
                                   data-toggle="tooltip" data-placement="bottom" title="Accesso area personale">
                                     <span class="rounded-icon">
                                         {display_icon('it-user', 'svg', 'icon icon-primary')}
                                    </span>
                                    <span class="d-none d-lg-block">Accedi all'area personale</span>
                                </a>
                                <a data-login-top-button class="btn btn-primary btn-icon btn-full ez-login rounded-0" href="{"/user/login"|ezurl(no)}"
                                   data-icon="it-pencil"
                                   data-toggle="tooltip" data-placement="bottom" title="Accesso per i redattori del sito"
                                   style="display: none;max-width: 72px;">
                                     <span class="rounded-icon">
                                         {display_icon('it-pencil', 'svg', 'icon-primary')}
                                    </span>
                                </a>
                            {else}
                                <a data-login-top-button class="btn btn-primary btn-icon btn-full ez-login" href="{"/user/login"|ezurl(no)}"
                                   data-icon="it-user"
                                   title="Esegui il login al sito" style="display: none;">
                                     <span class="rounded-icon">
                                         {display_icon('it-user', 'svg', 'icon-primary')}
                                    </span>
                                    <span class="d-none d-lg-block">Accedi all'area personale</span>
                                </a>
                            {/if}
                        </div>
                        *}
                    </div>
                </div>
            </div>
        </div>
    </div>

{literal}
<script>
    $(document).ready(function(){
        if (typeof LanguageUrlAliasList !== 'undefined') {
            $('[data-switch_locale]').each(function () {
                var self = $(this);
                var locale = self.data('switch_locale');
                $.each(LanguageUrlAliasList, function () {
                    if (this.locale === locale) {
                        self.attr('href', this.uri);
                    }
                })
            });
        }
        $('[data-toggle="tooltip"]').tooltip();
        var trimmedPrefix = UriPrefix.replace(/~+$/g,"");
        if(trimmedPrefix === '/') trimmedPrefix = '';
        var spritePath = "{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}";
        var login = $('[data-login-top-button]');
        var icon = login.data('icon');
        login.find('a.ez-login').attr('href', login.find('a.ez-login').attr('href'));
        var injectUserInfo = function(data){
            if(data.error_text || !data.content){
                login.show();
            }else{
                var dropdownWrapper = $('<div class="dropdown"></div>');
                var dropdownMenu = $('<div class="dropdown-user dropdown-menu dropdown-menu-right" aria-labelledby="dropdown-user"></div>');
                var dropdownListWrapper = $('<div class="link-list-wrapper"></div>');
                var dropdownList = $('<ul class="link-list"></ul>');

                $('<a href="#" class="btn btn-primary btn-icon btn-full dropdown-toggle" id="dropdown-user" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><span class="rounded-icon"><svg class="icon icon-primary notrasform"><use xlink:href="'+spritePath+'#'+icon+'"></use></svg></span><span class="d-none d-lg-block text-nowrap">'+data.content.name+' </span><svg class="icon-expand icon icon-white"><use xlink:href="'+spritePath+'#it-expand"></use></svg></a>')
                    .appendTo(dropdownWrapper);

                $('<li><a class="list-item" href="'+trimmedPrefix+'/user/edit/" title="{/literal}{'User profile'|i18n('bootstrapitalia')}{literal}"><span>{/literal}{'User profile'|i18n('bootstrapitalia')}{literal}</span></a></li>')
                    .appendTo(dropdownList);
                if(data.content.has_access_to_dashboard){
                    $('<li><a class="list-item text-nowrap" href="'+trimmedPrefix+'/content/dashboard/" title="{/literal}{'Dashboard'|i18n('bootstrapitalia')}{literal}"><span>{/literal}{'Dashboard'|i18n('bootstrapitalia')}{literal}</span></a></li>')
                        .appendTo(dropdownList);
                }
                $('<li><span class="divider"></span></li>')
                    .appendTo(dropdownList);
                $('<li><a class="list-item" href="'+trimmedPrefix+'/user/logout" title="{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}"><span>{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}</span></a></li>')
                    .appendTo(dropdownList);

                dropdownList.appendTo(dropdownListWrapper);
                dropdownListWrapper.appendTo(dropdownMenu);
                dropdownMenu.appendTo(dropdownWrapper);
                login.after(dropdownWrapper);
                login.remove();
            }
        };
        if(CurrentUserIsLoggedIn){
            $.ez('openpaajax::userInfo', null, function(data){
                injectUserInfo(data);
            });
        }else{
            login.show();
        }
    });
</script>
{/literal}

</div>
{undef $header_service $header_service_list $is_area_tematica $header_links $current_language $lang_selector $uri}

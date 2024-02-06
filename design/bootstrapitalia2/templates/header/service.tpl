{def $show_slim_header = cond(openpaini('GeneralSettings','HideSlimHeaderIfUseless', 'disabled')|eq('enabled'), false(), true())}
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

{def $link_area_personale = cond(is_set($pagedata.contacts.link_area_personale), $pagedata.contacts.link_area_personale, false())}
{def $link_area_personale_title = 'Access the personal area'|i18n('bootstrapitalia')}
{def $link_area_personale_parts = $link_area_personale|explode('|')}
{if count($link_area_personale_parts)|gt(1)}
    {set $link_area_personale = $link_area_personale_parts[0]}
    {set $link_area_personale_title = $link_area_personale_parts[1]}
{/if}
{if and($link_area_personale|not, fetch(user,current_user).is_logged_in|not())}
    {set $hide_access = true()}
{/if}

{if or($header_service_list|count()|gt(0), $header_links|count()|gt(0), $hide_access|not(), $lang_selector|count()|gt(0))}
    {set $show_slim_header = true()}
{/if}


<div class="it-header-slim-wrapper{if current_theme_has_variation('light_slim')} theme-light{/if}{if $show_slim_header|not()} d-none{/if}">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-header-slim-wrapper-content">
                    {if $header_service_list|count()|gt(0)}
                        {foreach $header_service_list as $item max 1}
                            <a class="{if $header_links|count()}d-none {/if}d-lg-block navbar-brand" target="_blank" href="{$item.url}"
                               aria-label="{'Go to page'|i18n('bootstrapitalia')} {$item.name|wash()}"
                               title="{'Go to page'|i18n('bootstrapitalia')} {$item.name|wash()}">{$item.name|wash()}</a>
                        {/foreach}
                        {if $header_links|count()}
                        <div class="nav-mobile">
                            <nav aria-label="{'Extra menu'|i18n('bootstrapitalia')}">
                                <a class="it-opener d-lg-none" data-bs-toggle="collapse" href="#service-menu" role="button" aria-expanded="false" aria-controls="service-menu">
                                    <span>{'Links'|i18n('openpa/footer')}</span>
                                    {display_icon('it-expand', 'svg', 'icon', 'Expand menu')}
                                </a>
                                <div class="link-list-wrapper collapse" id="service-menu">
                                    <ul class="link-list">
                                        {foreach $header_service_list as $item}
                                            <li class="list-item d-block d-md-none"><a href="{$item.url}" aria-label="{'Go to page'|i18n('bootstrapitalia')} {$item.name|wash()}">{$item.name|wash()}</a></li>
                                        {/foreach}
                                        {foreach $header_links as $header_link max openpaini('Menu','HeaderLinksLimit', 3)}
                                            <li class="list-item text-nowrap">{node_view_gui content_node=$header_link view=text_linked}</li>
                                        {/foreach}
                                    </ul>
                                </div>
                            </nav>
                        </div>
                        {/if}
                    {/if}

                    <div class="it-header-slim-right-zone" role="navigation">
                        {if $lang_selector|count()}
                        <div class="nav-item dropdown">
                            <button type="button" class="nav-link dropdown-toggle" data-bs-toggle="dropdown"
                                    aria-expanded="false" aria-controls="languages" aria-haspopup="true">
                                <span class="visually-hidden">{'Current language'|i18n('bootstrapitalia/header')}:</span>
                                <span>{$current_language.text|wash|upcase}</span>
                                {display_icon('it-expand', 'svg', 'icon', 'Expand menu')}
                            </button>
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
                                                           class="dropdown-item list-item">
                                                            <span lang="{fetch(content, locale, hash(locale_code, $lang_selector_item.lang.locale)).http_locale_code|explode('-')[0]}">
                                                                {$lang_selector_item.lang.text|wash|upcase}
                                                                {if $lang_selector_item.is_current}<span class="visually-hidden">{'selected'|i18n('bootstrapitalia/header')}</span>{/if}
                                                            </span>
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
                            {if openpaini( 'StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled' )|ne('disabled')}
                                <div id="{openpaini( 'StanzaDelCittadinoBridge', 'RootId_login', 'oc-login-box' )}"></div>
                            {else}
                                <a class="btn btn-primary btn-icon btn-full" style="visibility: hidden" href="{'accedi'|ezurl(no)}" data-element="personal-area-login" title="{$link_area_personale_title|wash()}">
                                      <span class="rounded-icon" aria-hidden="true">
                                        {display_icon('it-user', 'svg', 'icon icon-primary', $link_area_personale_title|wash())}
                                      </span>
                                    <span class="d-none d-lg-block">{$link_area_personale_title|wash()}</span>
                                </a>
                            {/if}
                        {/if}

                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

{literal}
<script id="tpl-user-access" type="text/x-jsrender">
<div class="it-user-wrapper nav-item dropdown">
    <a aria-expanded="false" class="btn btn-primary btn-icon btn-full" data-bs-toggle="dropdown" href="#" data-focus-mouse="false">
        <span class="rounded-icon">
            <img src="{{:prefix}}/bootstrapitalia/avatar/{{:id}}" class="border rounded-circle icon-white" alt="{{:name}}">
        </span>
        <span class="d-none d-lg-block">{{:name}}</span>
        <svg class="icon icon-white d-none d-lg-block">
            <use xlink:href="{{:spritePath}}#it-expand"></use>
        </svg>
    </a>
    <div class="dropdown-menu">
        <div class="row">
            <div class="col-12">
                <div class="link-list-wrapper">
                    <ul class="link-list">
                        <li><a class="dropdown-item list-item" href="{{:prefix}}/user/edit/"><span>{/literal}{'User profile'|i18n('bootstrapitalia')}{literal}</span></a></li>
                        {{if has_access_to_dashboard}}
                            <li><a class="dropdown-item list-item" href="{{:prefix}}/content/dashboard/"><span>{/literal}{'Dashboard'|i18n('bootstrapitalia')}{literal}</span></a></li>
                        {{/if}}
                        <li><span class="divider"></span></li>
                        <li>
                            <a class="list-item left-icon" href="{{:prefix}}/user/logout">
                                <svg class="icon icon-primary icon-sm left">
                                    <use xlink:href="{{:spritePath}}#it-external-link">
                                    </use>
                                </svg>
                                <span class="fw-bold">{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
</script>
<script id="tpl-user-profile" type="text/x-jsrender">
<div class="it-user-wrapper nav-item dropdown">
    <a aria-expanded="false" class="btn btn-primary btn-icon btn-full" data-bs-toggle="dropdown" href="#" data-focus-mouse="false">
        <span aria-hidden="true" class="rounded-icon d-lg-none">
            <svg class="icon icon-primary">
                <use xlink:href="{{:spritePath}}#it-user"></use>
           </svg>
        </span>
        <span class="d-none d-lg-block text-uppercase">{{:nome}} {{:cognome}}</span>
        <svg class="icon icon-white d-none d-lg-block">
            <use xlink:href="{{:spritePath}}#it-expand"></use>
        </svg>
    </a>
    <div class="dropdown-menu">
        <div class="row">
            <div class="col-12">
                <div class="link-list-wrapper">
                    {{if role == 'user'}}
                    <ul class="link-list">
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/user/profile">
                                <svg class="icon icon-sm icon-primary left ">
                                    <use xlink:href="{{:spritePath}}#it-user"></use>
                                </svg>
                                <span class="text-nowrap">{/literal}{'Profile'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/user/">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-pa"></use>
                                </svg>
                                <span>{/literal}{'Personal Area'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/pratiche/">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-files"></use>
                                </svg>
                                <span>{/literal}{'Practices'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/pratiche/allegati/">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-box"></use>
                                </svg>
                                <span>{/literal}{'Attachments'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/documenti/">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-folder"></use>
                                </svg>
                                <span>{/literal}{'Documents'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/subscriptions/">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-pencil"></use>
                                </svg>
                                <span>{/literal}{'Subscriptions'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li><span class="divider"></span></li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/logout">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-link"></use>
                                </svg>
                                <span>{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                    </ul>
                    {{else}}
                    <ul class="link-list">
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/operatori/profile">
                                <svg class="icon icon-sm icon-primary left ">
                                    <use xlink:href="{{:spritePath}}#it-user"></use>
                                </svg>
                                <span class="text-nowrap">{/literal}{'Profile'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/operatori/">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-software"></use>
                                </svg>
                                <span>Dashboard</span>
                            </a>
                        </li>
                        <li><span class="divider"></span></li>
                        <li>
                            <a class="list-item left-icon text-nowrap" href="{{:baseUrl}}/operatori/logout">
                                <svg class="icon icon-sm icon-primary left">
                                    <use xlink:href="{{:spritePath}}#it-link"></use>
                                </svg>
                                <span>{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}</span>
                            </a>
                        </li>
                    </ul>
                    {{/if}}
                </div>
            </div>
        </div>
    </div>
</div>
</script>
{/literal}
<script>
    var baseUrl = "{$link_area_personale|user_api_base_url()}";
    var tokenUrl = "{$link_area_personale|user_token_url()}";
    var profileUrl = {if openpaini( 'StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled' )|ne('disabled')}false{else}"{$link_area_personale|user_profile_url()}"{/if};
    {literal}
    $(document).ready(function () {
      let userAccessContainer = $('[data-element="personal-area-login"]');
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
      var trimmedPrefix = UriPrefix.replace(/~+$/g, "");
      if (trimmedPrefix === '/') trimmedPrefix = '';
      var injectUserInfo = function (data) {
        if (data.error_text || !data.content) {
          console.log(data.error_text);
          userAccessContainer.removeAttr('style');
        } else {
          var response = data.content;
          response.id = CurrentUserId;
          response.prefix = trimmedPrefix;
          response.spritePath = "{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}";
          var renderData = $($.templates('#tpl-user-access').render(response));
          userAccessContainer.replaceWith(renderData)
        }
      };
      var injectProfileInfo = function (data) {
        console.log(data);
        data.prefix = trimmedPrefix;
        data.spritePath = "{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}";
        data.baseUrl = baseUrl;
        var renderData = $($.templates('#tpl-user-profile').render(data));
        userAccessContainer.replaceWith(renderData)
      }
      var getProfile = function (token, cb, context) {
        function parseJwt(token) {
          var base64Url = token.split('.')[1];
          var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
          var jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
          }).join(''));
          return JSON.parse(jsonPayload);
        }
        var tokenData = parseJwt(token);
        jQuery.ajax({
          url: profileUrl + '/' + tokenData.id,
          dataType: 'json',
          headers: {
            Authorization: 'Bearer ' + token
          },
          success: function (data) {
            if ($.isFunction(cb)) {
              cb.call(context, data);
            }
          },
          error: function (){
            userAccessContainer.removeAttr('style');
          }
        });
      }
      if (CurrentUserIsLoggedIn) {
        $.ez('openpaajax::userInfo', null, function (data) {
          injectUserInfo(data);
        });
      } else if (profileUrl) {
        jQuery.ajax({
          url: tokenUrl,
          dataType: 'json',
          xhrFields: {withCredentials: true},
          success: function (data) {
            if (data.token && profileUrl) {
              getProfile(data.token, injectProfileInfo);
            }
          },
          error: function (){
            userAccessContainer.removeAttr('style');
          }
        });
      } else {
        userAccessContainer.removeAttr('style');
      }
    });
    {/literal}
</script>


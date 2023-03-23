{def $can_edit_languages = false()
     $can_manage_location = false()
     $can_create_languages = false()
     $is_container = false()
     $odf_display_classes = ezini( 'WebsiteToolbarSettings', 'ODFDisplayClasses', 'websitetoolbar.ini' )
     $odf_hide_container_classes = ezini( 'WebsiteToolbarSettings', 'HideODFContainerClasses', 'websitetoolbar.ini' )
     $website_toolbar_access = fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' ) )
     $odf_import_access = fetch( 'user', 'has_access_to', hash( 'module', 'ezodf', 'function', 'import' ) )
     $odf_export_access = fetch( 'user', 'has_access_to', hash( 'module', 'ezodf', 'function', 'export' ) )
     $content_object_language_code = ''
     $policies = fetch( 'user', 'user_role', hash( 'user_id', $current_user.contentobject_id ) )
     $available_for_current_class = true()
     $custom_templates = ezini( 'CustomTemplateSettings', 'CustomTemplateList', 'websitetoolbar.ini' )
     $include_in_view = ezini( 'CustomTemplateSettings', 'IncludeInView', 'websitetoolbar.ini' )
     $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )
     $content_object = hash(
        'can_create', false(),
        'can_edit', false(),
        'can_move', false(),
        'can_remove', false()
     )
     $current_node = hash(
        'node_id', 0,
        'url_alias', '/'
     )}
{if $current_node_id}
    {set $current_node = fetch( 'content', 'node', hash( 'node_id', $current_node_id ) )
         $content_object = $current_node.object
         $can_edit_languages = $content_object.can_edit_languages
         $can_manage_location = fetch( 'content', 'access', hash( 'access', 'manage_locations', 'contentobject', $current_node ) )
         $can_create_languages = $content_object.can_create_languages
         $is_container = $content_object.content_class.is_container}
    {def $node_hint = ': '|append( $current_node.name|wash(), ' [', $content_object.content_class.name|wash(), ']' )}

    {foreach $policies as $policy}
        {if and( eq( $policy.moduleName, 'websitetoolbar' ),eq( $policy.functionName, 'use' ),is_array( $policy.limitation ) )}
            {if $policy.limitation[0].values_as_array|contains( $content_object.content_class.id )}
                {set $available_for_current_class = true()}
            {/if}
        {elseif or( and( eq( $policy.moduleName, '*' ),eq( $policy.functionName, '*' ),eq( $policy.limitation, '*' ) ),
                    and( eq( $policy.moduleName, 'websitetoolbar' ),eq( $policy.functionName, '*' ),eq( $policy.limitation, '*' ) ),
                    and( eq( $policy.moduleName, 'websitetoolbar' ),eq( $policy.functionName, 'use' ),eq( $policy.limitation, '*' ) ) )}
            {set $available_for_current_class = true()}
        {/if}
    {/foreach}
{/if}


{if and( $website_toolbar_access, $available_for_current_class )}

<form method="post" action="{"content/action"|ezurl(no)}">
    <nav class="toolbar" id="ezwt">
        <ul class="d-flex flex-nowrap border-bottom">

            {if and( $content_object.can_create, $is_container )}
                {def $can_create_class_list = $content_object.can_create_class_list}
                {if $can_create_class_list|count()}
                <li>
                    <div class="input-group">
                        <select name="ClassID" id="ezwt-create" class="custom-select" data-placeholder="{"Create here"||i18n('design/admin/node/view/full')}">
                            {if count($can_create_class_list)|gt(1)}<option></option>{/if}
                            {foreach $can_create_class_list as $class}
                                <option value="{$class.id}" data-class="{$class.id|class_identifier_by_id()}">{$class.name|wash}</option>
                            {/foreach}
                        </select>
                        <div class="input-group-append">
                            <button class="btn btn-create" type="submit" name="NewButton" title="{'Create here'|i18n('design/standard/parts/website_toolbar')}">
                                <i aria-hidden="true" class="fa fa-plus-circle"></i>
                                <span class="toolbar-label">{'Create'|i18n( 'bootstrapitalia')}</span>
                            </button>
                        </div>
                    </div>
                </li>
                <li class="toolbar-divider" aria-hidden="true"></li>
                {/if}
                <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
            {/if}

            {if $content_object.can_edit}
                <input type="hidden" name="ContentObjectLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
                <li>
                    <button class="btn" type="submit" name="EditButton" title="{'Edit'|i18n( 'design/standard/parts/website_toolbar')}{$node_hint}">
                        <i aria-hidden="true" class="fa fa-pencil"></i>
                        <span class="toolbar-label">{'Edit'|i18n( 'design/standard/parts/website_toolbar')}</span>
                    </button>
                </li>
            {elseif and(
                $content_object.state_identifier_array|contains('opencity_lock/locked'),
                fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'opencity_locked_editor' ) )
            )}
                <li>
                    <button class="btn" type="button"
                            data-class="{$content_object.class_identifier}"
                            data-object="{$content_object.id}"
                            name="LockEditButton" title="{'Edit'|i18n( 'design/standard/parts/website_toolbar')}{$node_hint}">
                        <i aria-hidden="true" class="fa fa-pencil"></i>
                        <span class="toolbar-label">{'Edit'|i18n( 'design/standard/parts/website_toolbar')}</span>
                    </button>
                </li>
            {/if}

            {if and(
                $content_object.can_move,
                not( $top_menu_node_ids|contains( $current_node.node_id ) )
            )}
                <li>
                    <button class="btn" type="submit" name="MoveNodeButton" title="{'Move'|i18n('design/standard/parts/website_toolbar')}{$node_hint}">
                        <i aria-hidden="true" class="fa fa-arrows"></i>
                        <span class="toolbar-label">{'Move'|i18n('design/standard/parts/website_toolbar')}</span>
                    </button>
                </li>
            {/if}

            {if $content_object.can_remove}
                <li>
                    <button class="btn" type="submit" name="ActionRemove" title="{'Remove'|i18n('design/standard/parts/website_toolbar')}{$node_hint}">
                        <i aria-hidden="true" class="fa fa-trash"></i>
                        <span class="toolbar-label">{'Remove'|i18n('design/standard/parts/website_toolbar')}</span>
                    </button>
                </li>
            {/if}

            {if $can_manage_location}
                {if and(
                    $can_manage_location,
                    ne( $current_node.node_id, ezini( 'NodeSettings', 'RootNode','content.ini' ) ),
                    ne( $current_node.node_id, ezini( 'NodeSettings', 'MediaRootNode', 'content.ini' ) ),
                    ne( $current_node.node_id, ezini( 'NodeSettings', 'UserRootNode', 'content.ini' ) ),
                    not( $top_menu_node_ids|contains( $current_node.node_id ) ),
                    not( array('topic')|contains( $current_node.class_identifier ) ),
                    $current_node.depth|gt(3)
                )}
                    <li>
                        <button class="btn" type="submit" name="AddAssignmentButton" title="{'Add locations'|i18n( 'design/standard/parts/website_toolbar' )}">
                            <i aria-hidden="true" class="fa fa-map-marker"></i>
                            <span class="toolbar-label">{'Add locations'|i18n( 'design/standard/parts/website_toolbar' )}</span>
                        </button>
                    </li>
                {/if}
            {/if}

            {if $is_container}
            <li>
                <a href="{concat( "websitetoolbar/sort/", $current_node.node_id )|ezurl(no)}" title="{'Sorting'|i18n( 'design/standard/parts/website_toolbar' )}">
                    <i aria-hidden="true" class="fa fa-sort-alpha-asc"></i>
                    <span class="toolbar-label">{'Sorting'|i18n( 'design/standard/parts/website_toolbar' )}</span>
                </a>
            </li>
            {/if}

            {if and($current_node.node_id|gt(0), fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'bookmark' ) ))}
            <li>
                <button class="btn" type="submit" name="ActionAddToBookmarks" title="{'Add the current item to your bookmarks.'|i18n( 'design/admin/pagelayout' )}">
                    <i aria-hidden="true" class="fa fa-bookmark{if is_bookmark($current_node.node_id)} text-light{/if}"></i>
                    <span class="toolbar-label">{'Bookmarks'|i18n( 'design/admin/content/browse' )}</span>
                </button>
            </li>
            {/if}

            {if is_set($content_object.id)}
            <li class="toolbar-divider" aria-hidden="true"></li>
            {/if}

            {* Custom templates inclusion *}
            <li>
                <div class="dropdown">
                    <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownOther" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i aria-hidden="true" class="fa fa-ellipsis-h"></i>
                        <span class="toolbar-label">{'Other'|i18n( 'bootstrapitalia' )}</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownOther">
                        <div class="link-list-wrapper">
                            <ul class="link-list">
                                {if is_set($content_object.id)}
                                    {include uri='design:parts/websitetoolbar/openpa_copy_object.tpl'}
                                    {include uri='design:parts/websitetoolbar/versions.tpl'}
                                    {include uri='design:parts/websitetoolbar/object_states.tpl'}
                                    {include uri='design:parts/websitetoolbar/reindex.tpl'}
                                    {include uri='design:parts/websitetoolbar/classtools.tpl'}
                                    {include uri='design:parts/websitetoolbar/ckan_push.tpl'}
                                    {include uri='design:parts/websitetoolbar/ezmultiupload.tpl'}
                                    {*include uri='design:parts/websitetoolbar/ezflip.tpl'*}
                                    {*include uri='design:parts/websitetoolbar/ngpush.tpl'*}
                                    {include uri='design:parts/websitetoolbar/refreshorgnigramma.tpl'}
                                    <li><span class="divider"></span></li>
                                {/if}

                                {include uri='design:parts/websitetoolbar/openpa_menu.tpl'}

                                {if is_set($content_object.id)}
                                    <li><span class="divider"></span></li>
                                    {def $onto_links = array()}
                                    {if ezmodule('onto')}
                                        {set $onto_links = easyontology_links($content_object.class_identifier, $content_object.id)}
                                    {/if}

                                    {if count($onto_links)}
                                        <li>
                                            <div class="list-item left-icon">
                                                <i aria-hidden="true" class="fa fa-code"></i> Linked Data
                                                {foreach $onto_links as $slug => $link}
                                                    <a href="{$link}" target="_blank" rel="noopener noreferrer"  title="{$slug|wash()}" class="badge badge-dark bg-dark text-white d-inline px-1">{$slug|wash()}</a>
                                                {/foreach}
                                            </div>
                                        </li>
                                    {else}
                                        <li>
                                            <a class="list-item left-icon" href="{concat('opendata/api/data/read/',$content_object.id)|ezurl(no)}" title="Visualizza in JSON">
                                                <i aria-hidden="true" class="fa fa-code"></i> Visualizza in JSON
                                            </a>
                                        </li>
                                    {/if}
                                    {undef $onto_links}
                                {/if}

                            </ul>
                        </div>
                    </div>
                </div>
            </li>

            {if is_set($content_object.id)}
            <li class="toolbar-divider" aria-hidden="true"></li>
            <li>
                <a class="btn" href="#" id="ezwt-help" data-bs-toggle="modal" data-target="#editor_tools" data-bs-target="#editor_tools">
                    <i aria-hidden="true" class="fa fa-info-circle"></i>
                    <span class="toolbar-label">Info</span>
                </a>
            </li>
            {/if}

            {if or(
                ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' ),
                openpaini( 'WebsiteToolbar', 'ShowMediaRoot', 'enabled' )|eq('enabled'),
                openpaini( 'WebsiteToolbar', 'ShowUsersRoot', 'enabled' )|eq('enabled'),
                openpaini( 'WebsiteToolbar', 'ShowEditorRoles', 'disabled' )|eq('enabled'),
                and(fetch( 'user', 'has_access_to', hash( 'module', 'newsletter', 'function', 'index' ) ), ezmodule('newsletter','subscribe')),
                fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'roles' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'valuation', 'function', 'dashboard' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'list' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'edit' ) )
            )}
            <li class="toolbar-divider" aria-hidden="true"></li>
            <li>
                <div class="dropdown">
                    <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownToolbar" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i aria-hidden="true" class="fa fa-sliders"></i>
                        <span class="toolbar-label">{'Manage'|i18n( 'bootstrapitalia' )}</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownToolbar">
                        <div class="link-list-wrapper">
                            <ul class="link-list">
                                {if ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' )}{* has_access_to_limitation('user', 'login', hash('SiteAccess', '<!-- SiteAccessName -->')) *}
                                    <li>
                                        <a class="list-item left-icon" href="{ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' )|explode('user/login')[0]}{$current_node.url_alias}" rel="noopener noreferrer" target="_blank" title="{'Go to admin interface.'|i18n( 'design/standard/parts/website_toolbar' )}">
                                            <i aria-hidden="true" class="fa fa-wrench"></i>
                                            Backend
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'draft' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{"content/draft"|ezurl(no)}" title="{"My drafts"|i18n("design/ocbootstrap/user/edit")}">
                                            <i aria-hidden="true" class="fa fa-pencil-square"></i>
                                            {"My drafts"|i18n("design/ocbootstrap/user/edit")}
                                        </a>
                                    </li>
                                {/if}
                                {if openpaini( 'WebsiteToolbar', 'ShowMediaRoot', 'enabled' )|eq('enabled')}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('content/view/full/',ezini('NodeSettings', 'MediaRootNode', 'content.ini'))|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-image"></i>
                                            Libreria Media
                                        </a>
                                    </li>
                                {/if}
                                {if openpaini( 'WebsiteToolbar', 'ShowUsersRoot', 'enabled' )|eq('enabled')}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('content/view/full/',ezini('NodeSettings', 'UserRootNode', 'content.ini'))|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-users"></i>
                                            Account utenti
                                        </a>
                                    </li>
                                {/if}
                                {include uri='design:parts/websitetoolbar/cjw_newsletter.tpl'}
                                {include uri='design:parts/websitetoolbar/ezsurvey.tpl'}
                                <li>
                                    <a class="list-item left-icon" href="{'opendata/console/1'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-code"></i>
                                        Console api
                                    </a>
                                </li>
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'roles' ) )}
                                <li>
                                    <a class="list-item left-icon" href="{'openpa/roles'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-user-o"></i>
                                        Gestione ruoli amministrativi
                                    </a>
                                </li>
                                {/if}
                                {if and( openpaini( 'WebsiteToolbar', 'ShowEditorRoles', 'disabled' )|eq('enabled'), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'permissions' ) ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/permissions'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-user-secret"></i>
                                            Gestione accessi redazione
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'theme' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/theme'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-television"></i>
                                            Gestione tema
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'seo' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'openpa/seo'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-google"></i>
                                            Gestione S.E.O.
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'recaptcha' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'openpa/recaptcha'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-key"></i>
                                            Gestione chiavi recaptcha
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'rss', 'function', 'edit' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'rss/list'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-rss-square"></i>
                                            Esportazioni RSS
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'trash' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'content/trash'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-trash"></i>
                                            Cestino
                                        </a>
                                    </li>
                                {/if}
                                {if and(openpaini('GeneralSettings','Valuation', 1), fetch( 'user', 'has_access_to', hash( 'module', 'valuation', 'function', 'dashboard' ) ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'valuation/dashboard'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-dashboard"></i>
                                            {'User feedbacks'|i18n("bootstrapitalia/valuation")}
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'list' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'webhook/list'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-external-link-square"></i>
                                            Webhooks
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'opencity_locked_editor' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/info'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-phone-square"></i>
                                            Gestione informazioni generali
                                        </a>
                                    </li>
                                {/if}
                            </ul>
                        </div>
                    </div>
                </div>
            </li>
            {/if}

            {if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}
            <li>
                <a class="btn position-relative" href="#" id="announce-news">
                    <span class="badge badge-warning bg-warning position-absolute pulsate" style="display: none;top: 0;right: 0;"></span>
                    <i aria-hidden="true" class="fa fa-bell"></i>
                    <span class="toolbar-label">{'News'|i18n( 'bootstrapitalia' )}</span>
                </a>
            </li>
            {/if}

            {if is_set($content_object.id)}
                <input type="hidden" name="HasMainAssignment" value="1" />
                <input type="hidden" name="ContentObjectID" value="{$content_object.id}" />
                <input type="hidden" name="NodeID" value="{$current_node.node_id}" />
                <input type="hidden" name="ContentNodeID" value="{$current_node.node_id}" />
                {* If a translation exists in the siteaccess' sitelanguagelist use default_language, otherwise let user select language to base translation on. *}
                {def $avail_languages = $content_object.available_languages
                   $default_language = $content_object.default_language}
                {if and( $avail_languages|count|ge( 1 ), $avail_languages|contains( $default_language ) )}
                {set $content_object_language_code = $default_language}
                {else}
                {set $content_object_language_code = ''}
                {/if}
                <input type="hidden" name="ContentObjectLanguageCode" value="{$content_object_language_code}" />
            {/if}

        </ul>
    </nav>
</form>

{/if}

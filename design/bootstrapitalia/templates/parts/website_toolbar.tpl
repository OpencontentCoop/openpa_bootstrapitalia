{def $current_node = fetch( 'content', 'node', hash( 'node_id', $current_node_id ) )
     $content_object = $current_node.object
     $can_edit_languages = $content_object.can_edit_languages
     $can_manage_location = fetch( 'content', 'access', hash( 'access', 'manage_locations', 'contentobject', $current_node ) )
     $can_create_languages = $content_object.can_create_languages
     $is_container = $content_object.content_class.is_container
     $odf_display_classes = ezini( 'WebsiteToolbarSettings', 'ODFDisplayClasses', 'websitetoolbar.ini' )
     $odf_hide_container_classes = ezini( 'WebsiteToolbarSettings', 'HideODFContainerClasses', 'websitetoolbar.ini' )
     $website_toolbar_access = fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' ) )
     $odf_import_access = fetch( 'user', 'has_access_to', hash( 'module', 'ezodf', 'function', 'import' ) )
     $odf_export_access = fetch( 'user', 'has_access_to', hash( 'module', 'ezodf', 'function', 'export' ) )
     $content_object_language_code = ''
     $policies = fetch( 'user', 'user_role', hash( 'user_id', $current_user.contentobject_id ) )
     $available_for_current_class = false()
     $custom_templates = ezini( 'CustomTemplateSettings', 'CustomTemplateList', 'websitetoolbar.ini' )
     $include_in_view = ezini( 'CustomTemplateSettings', 'IncludeInView', 'websitetoolbar.ini' )
     $node_hint = ': '|append( $current_node.name|wash(), ' [', $content_object.content_class.name|wash(), ']' ) }

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

{if and( $website_toolbar_access, $available_for_current_class )}

<form method="post" action="{"content/action"|ezurl(no)}">
    <nav class="toolbar" id="ezwt">
        <ul class="d-flex flex-nowrap">

            {if and( $content_object.can_create, $is_container )}
                {def $can_create_class_list = $content_object.can_create_class_list}
                {if $can_create_class_list|count()}
                <li>
                    <div class="input-group">
                        <select name="ClassID" id="ezwt-create" class="custom-select" data-placeholder="{"Create here"||i18n('design/admin/node/view/full')}">
                            <option></option>
                            {foreach $can_create_class_list as $class}
                                <option value="{$class.id}" data-class="{$class.id|class_identifier_by_id()}">{$class.name|wash}</option>
                            {/foreach}
                        </select>
                        <div class="input-group-append">
                            <button class="btn btn-create" type="submit" name="NewButton" title="{'Create here'|i18n('design/standard/parts/website_toolbar')}">
                                <i class="fa fa-plus-circle"></i>
                                <span class="toolbar-label">Crea</span>
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
                        <i class="fa fa-pencil"></i>
                        <span class="toolbar-label">Modifica</span>
                    </button>
                </li>
            {/if}

            {if $content_object.can_move}
                <li>
                    <button class="btn" type="submit" name="MoveNodeButton" title="{'Move'|i18n('design/standard/parts/website_toolbar')}{$node_hint}">
                        <i class="fa fa-arrows"></i>
                        <span class="toolbar-label">Sposta</span>
                    </button>
                </li>
            {/if}

            {if $content_object.can_remove}
                <li>
                    <button class="btn" type="submit" name="ActionRemove" title="{'Remove'|i18n('design/standard/parts/website_toolbar')}{$node_hint}">
                        <i class="fa fa-trash"></i>
                        <span class="toolbar-label">Elimina</span>
                    </button>
                </li>
            {/if}

            {if $can_manage_location}
                {if and( $can_manage_location, ne( $current_node.node_id, ezini( 'NodeSettings', 'RootNode','content.ini' ) ), ne( $current_node.node_id, ezini( 'NodeSettings', 'MediaRootNode', 'content.ini' ) ), ne( $current_node.node_id, ezini( 'NodeSettings', 'UserRootNode', 'content.ini' ) ) )}
                    <li>
                        <button class="btn" type="submit" name="AddAssignmentButton" title="{'Add locations'|i18n( 'design/standard/parts/website_toolbar' )}">
                            <i class="fa fa-map-marker"></i>
                            <span class="toolbar-label">Colloca</span>
                        </button>
                    </li>
                {/if}
            {/if}

            {if $is_container}
            <li>
                <a href="{concat( "websitetoolbar/sort/", $current_node.node_id )|ezurl(no)}" title="{'Sorting'|i18n( 'design/standard/parts/website_toolbar' )}">
                    <i class="fa fa-sort-alpha-asc"></i>
                    <span class="toolbar-label">Ordina</span>
                </a>
            </li>
            {/if}

            <li class="toolbar-divider" aria-hidden="true"></li>

            {* Custom templates inclusion *}
            <li>
                <div class="dropdown">
                    <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownToolbar" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-ellipsis-h"></i>
                        <span class="toolbar-label">Altro</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownToolbar">
                        <div class="link-list-wrapper">
                            <ul class="link-list">
                                {include uri='design:parts/websitetoolbar/openpa_copy_object.tpl'}
                                {include uri='design:parts/websitetoolbar/versions.tpl'}
                                {include uri='design:parts/websitetoolbar/object_states.tpl'}
                                {include uri='design:parts/websitetoolbar/reindex.tpl'}
                                {include uri='design:parts/websitetoolbar/classtools.tpl'}
                                {include uri='design:parts/websitetoolbar/refreshorgnigramma.tpl'}
                                {include uri='design:parts/websitetoolbar/ckan_push.tpl'}
                                {*include uri='design:parts/websitetoolbar/ezflip.tpl'*}
                                {*include uri='design:parts/websitetoolbar/ngpush.tpl'*}
                                {include uri='design:parts/websitetoolbar/ezmultiupload.tpl'}
                                <li><span class="divider"></span></li>
                                {include uri='design:parts/websitetoolbar/openpa_menu.tpl'}
                                <li><span class="divider"></span></li>

                                {def $onto_links = array()}
                                {if ezmodule('onto')}
                                    {set $onto_links = easyontology_links($content_object.class_identifier, $content_object.id)}
                                {/if}

                                {if count($onto_links)}
                                    <li>
                                        <div class="list-item left-icon">
                                            <i class="fa fa-code"></i> Linked Data
                                            {foreach $onto_links as $slug => $link}
                                                <a href="{$link}" target="_blank" title="{$slug|wash()}" class="badge badge-dark text-white d-inline px-1">{$slug|wash()}</a>
                                            {/foreach}
                                        </div>
                                    </li>
                                {else}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('opendata/api/data/read/',$content_object.id)|ezurl(no)}" title="Visualizza in JSON">
                                            <i class="fa fa-code"></i> Visualizza in JSON
                                        </a>
                                    </li>
                                {/if}
                                {undef $onto_links}

                            </ul>
                        </div>
                    </div>
                </div>
            </li>

            <li class="toolbar-divider" aria-hidden="true"></li>

            <li>
                <a class="btn" href="#" id="ezwt-help" data-toggle="modal" data-target="#editor_tools">
                    <i class="fa fa-info-circle"></i>
                    <span class="toolbar-label">Info</span>
                </a>
            </li>

            {if or(
                ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' ),
                openpaini( 'WebsiteToolbar', 'ShowMediaRoot', 'enabled' )|eq('enabled'),
                openpaini( 'WebsiteToolbar', 'ShowUsersRoot', 'enabled' )|eq('enabled'),
                and(fetch( 'user', 'has_access_to', hash( 'module', 'newsletter', 'function', 'index' ) ), ezmodule('newsletter','subscribe')),
                fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'roles' ) )
            )}
            <li class="toolbar-divider" aria-hidden="true"></li>
            <li>
                <div class="dropdown">
                    <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownToolbar" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-link"></i>
                        <span class="toolbar-label">Amministra</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownToolbar">
                        <div class="link-list-wrapper">
                            <ul class="link-list">
                                {if ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' )}{* has_access_to_limitation('user', 'login', hash('SiteAccess', '<!-- SiteAccessName -->')) *}
                                    <li>
                                        <a class="list-item left-icon" href="{ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' )|explode('user/login')[0]}{$current_node.url_alias}" target="_blank" title="{'Go to admin interface.'|i18n( 'design/standard/parts/website_toolbar' )}">
                                            <i class="fa fa-wrench"></i>
                                            Backend
                                        </a>
                                    </li>
                                {/if}
                                {if openpaini( 'WebsiteToolbar', 'ShowMediaRoot', 'enabled' )|eq('enabled')}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('content/view/full/',ezini('NodeSettings', 'MediaRootNode', 'content.ini'))|ezurl(no)}">
                                            <i class="fa fa-image"></i>
                                            Libreria Media
                                        </a>
                                    </li>
                                {/if}
                                {if openpaini( 'WebsiteToolbar', 'ShowUsersRoot', 'enabled' )|eq('enabled')}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('content/view/full/',ezini('NodeSettings', 'UserRootNode', 'content.ini'))|ezurl(no)}">
                                            <i class="fa fa-users"></i>
                                            Account utenti
                                        </a>
                                    </li>
                                {/if}
                                {include uri='design:parts/websitetoolbar/cjw_newsletter.tpl'}
                                <li>
                                    <a class="list-item left-icon" href="{'opendata/console/1'|ezurl(no)}">
                                        <i class="fa fa-code"></i>
                                        Console api
                                    </a>
                                </li>
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'roles' ) )}
                                <li>
                                    <a class="list-item left-icon" href="{'openpa/roles'|ezurl(no)}">
                                        <i class="fa fa-user-o"></i>
                                        Gestione ruoli
                                    </a>
                                </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'theme' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/theme'|ezurl(no)}">
                                            <i class="fa fa-television"></i>
                                            Gestione tema
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'seo' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'openpa/seo'|ezurl(no)}">
                                            <i class="fa fa-google"></i>
                                            Gestione S.E.O.
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'recaptcha' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'openpa/recaptcha'|ezurl(no)}">
                                            <i class="fa fa-key"></i>
                                            Gestione chiavi recaptcha
                                        </a>
                                    </li>
                                {/if}
                            </ul>
                        </div>
                    </div>
                </div>
            </li>
            {/if}

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

        </ul>
    </nav>
</form>

{/if}

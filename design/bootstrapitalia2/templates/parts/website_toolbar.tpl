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
        'can_remove', false(),
        'can_translate', false(),
        'class_identifier', 'null-class'
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
    {if and($content_object.remote_id|eq('faq_system'), openpaini('ViewSettings', 'FaqTreeView', 'disabled')|eq('disabled'))}
        {set $is_container = false()}
    {/if}
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

{def $current_user_needs_approval = current_user_needs_approval($content_object.class_identifier)}

<style>
{literal}
/* i pulsanti della toolbar (Modifica, Sposta, Elimina...) non sono link: stesso hover degli altri elementi */
#ezwt > ul > li > .btn:not(.btn-dropdown):hover,
#ezwt > ul > li > .btn:not(.btn-dropdown):focus-visible,
#ezwt .btn-create:not(:disabled):not(.disabled):hover,
#ezwt .btn-create:not(:disabled):not(.disabled):focus-visible,
#ezwt > ul > li > a:not(.disabled):hover,
#ezwt > ul > li > a:not(.disabled):focus-visible {
  color: var(--bs-primary);
  text-decoration: underline;
}
/* distanza tra la select di creazione e il pulsante Crea */
#ezwt .input-group .btn-create {
  margin-left: 12px;
}
/* transizione leggera sul colore all'hover */
#ezwt > ul > li > .btn,
#ezwt > ul > li > a,
#ezwt .btn-create,
#ezwt .dropdown-menu .link-list a.list-item,
#ezwt .dropdown-menu .link-list a.list-item .toolbar-item-label {
  transition: color .15s ease;
}
@media (prefers-reduced-motion: reduce) {
  #ezwt * { transition: none !important; }
}
/* voci dei dropdown */
#ezwt .dropdown-menu .link-list a.list-item:not(.disabled):hover,
#ezwt .dropdown-menu .link-list a.list-item:not(.disabled):focus-visible {
  color: var(--bs-primary);
  text-decoration: none;
}
/* bootstrap-italia colora e spazia ogni span nei link-list: qui il testo deve ereditare dal link */
#ezwt .dropdown-menu .link-list a.list-item .toolbar-item-label {
  color: inherit;
  display: inline;
  margin-right: 0;
  line-height: inherit;
}
/* sottolineatura solo sul testo della voce, non su icona e spazi */
#ezwt .dropdown-menu .link-list a.list-item:not(.disabled):hover .toolbar-item-label,
#ezwt .dropdown-menu .link-list a.list-item:not(.disabled):focus-visible .toolbar-item-label {
  text-decoration: underline;
  text-underline-offset: 3px;
}
{/literal}
</style>
<form method="post" action="{"content/action"|ezurl(no)}">
    <nav class="toolbar" id="ezwt">
        <ul class="d-flex flex-nowrap border-bottom">

            {if and( $content_object.can_create, $is_container )}
                {def $can_create_class_list = can_create_class_list_in_current_language($content_object)}
                {if $can_create_class_list|count()}
                <li class="position-relative">
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
                {def $has_child_pending_approval = has_child_pending_approval($content_object.main_node_id, ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini'))}
                {if $has_child_pending_approval}
                    <li>
                        <a href="{concat('/bootstrapitalia/approval/(assignment)/', $content_object.main_node_id)|ezurl(no)}">
                            <span class="font-weight-bold">{$has_child_pending_approval}</span>
                            <span class="toolbar-label" style="max-width: 70px;">{'Pending approval'|i18n('bootstrapitalia/moderation')}</span>
                        </a>
                    </li>
                {/if}
                {undef $has_child_pending_approval}
                <li class="toolbar-divider" aria-hidden="true"></li>
                {/if}
                <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
            {/if}

            {if can_edit_in_current_language($content_object)}
                {def $has_pending_approval = has_pending_approval($content_object.id, ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini'), $current_user_needs_approval)}
                {if $has_pending_approval}
                    <li>
                        <a href="{concat( "bootstrapitalia/approval/edit/", $content_object.id )|ezurl(no)}" title="{'Edit'|i18n( 'design/standard/parts/website_toolbar')}{$node_hint}">
                            <i aria-hidden="true" class="fa fa-pencil" style="font-size: 26px;"></i>
                            <span class="toolbar-label">{'Edit'|i18n( 'design/standard/parts/website_toolbar')}</span>
                        </a>
                    </li>
                {else}
                    <input type="hidden" name="ContentObjectLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
                    <li class="position-relative">
                        <button class="btn" type="submit" name="EditButton" title="{'Edit'|i18n( 'design/standard/parts/website_toolbar')}{$node_hint}">
                            <i aria-hidden="true" class="fa fa-pencil"></i>
                            <span class="toolbar-label">{'Edit'|i18n( 'design/standard/parts/website_toolbar')}</span>
                        </button>
                    </li>
                {/if}
            {elseif and(
                is_set($content_object.state_identifier_array),
                $content_object.state_identifier_array|contains('opencity_lock/locked'),
                current_user_can_lock_edit($content_object)
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

            {if and($content_object.can_translate, ezini('ExtensionSettings','ActiveAccessExtensions')|contains('octranslate'), fetch( 'user', 'has_access_to', hash( 'module', 'translate', 'function', 'content' ) ))}
                {include uri='design:parts/websitetoolbar/translate.tpl' content_object=$content_object}
            {/if}

            {if and($can_manage_location, not(current_user_needs_approval($content_object.class_identifier)))}
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

            {if and(is_set($content_object.id), not(current_user_needs_approval($content_object.class_identifier)))}
                {include uri='design:parts/websitetoolbar/privacy.tpl'}
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
                                {if and($is_container, not(current_user_needs_approval()))}
                                    <li>
                                        <a class="list-item left-icon" href="{concat( "websitetoolbar/sort/", $current_node.node_id )|ezurl(no)}" title="{'Sorting'|i18n( 'design/standard/parts/website_toolbar' )}">
                                            <i aria-hidden="true" class="fa fa-fw fa-sort-alpha-asc"></i>
                                            <span class="toolbar-item-label">{'Sorting'|i18n( 'design/standard/parts/website_toolbar' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if and(
                                    $content_object.can_move,
                                    not(openpaini('WebsiteToolbar', 'HideMoveButton', array('restricted_document', 'restricted_area'))|contains($content_object.class_identifier)),
                                    not($current_user_needs_approval),
                                    not( $top_menu_node_ids|contains( $current_node.node_id ) )
                                )}
                                        <li>
                                            <a class="list-item left-icon" href="#" title="{'Move'|i18n('design/standard/parts/website_toolbar')}{$node_hint}"
                                               onclick="var f = $(this).closest('form'); $('<input>', {ldelim}type: 'hidden', name: 'MoveNodeButton', value: '1'{rdelim}).appendTo(f); f.get(0).submit(); return false;">
                                                <i aria-hidden="true" class="fa fa-fw fa-arrows"></i>
                                                <span class="toolbar-item-label">{'Move'|i18n('design/standard/parts/website_toolbar')}</span>
                                            </a>
                                        </li>
                                {/if}
                                {if and($content_object.can_remove, not(current_user_needs_approval($content_object.class_identifier)))}
                                        <li>
                                            <a class="list-item left-icon" href="#" title="{'Remove'|i18n('design/standard/parts/website_toolbar')}{$node_hint}"
                                               onclick="var f = $(this).closest('form'); $('<input>', {ldelim}type: 'hidden', name: 'ActionRemove', value: '1'{rdelim}).appendTo(f); f.get(0).submit(); return false;">
                                                <i aria-hidden="true" class="fa fa-fw fa-trash"></i>
                                                <span class="toolbar-item-label">{'Remove'|i18n('design/standard/parts/website_toolbar')}</span>
                                            </a>
                                        </li>
                                {/if}
                                {if is_set($content_object.id)}
                                    {include uri='design:parts/websitetoolbar/openpa_copy_object.tpl'}
                                    {include uri='design:parts/websitetoolbar/versions.tpl'}
                                    {*include uri='design:parts/websitetoolbar/object_states.tpl'*}
                                    {include uri='design:parts/websitetoolbar/reindex.tpl'}
                                    {include uri='design:parts/websitetoolbar/classtools.tpl'}
                                    {include uri='design:parts/websitetoolbar/urlalias.tpl'}
                                    {include uri='design:parts/websitetoolbar/ckan_push.tpl'}
                                    {*include uri='design:parts/websitetoolbar/ezmultiupload.tpl'*}
                                    {*include uri='design:parts/websitetoolbar/ezflip.tpl'*}
                                    {*include uri='design:parts/websitetoolbar/ngpush.tpl'*}
                                    {include uri='design:parts/websitetoolbar/refreshorgnigramma.tpl'}
                                    {if and($current_node.node_id|gt(0), fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'bookmark' ) ))}
                                        {def $bookmark_id = bookmark_id($current_node.node_id)}
                                        <li>
                                        {if $bookmark_id}
                                            <a class="list-item left-icon" href="#"
                                               onclick="var f = $(this).closest('form'); f.attr('action', '{'content/bookmark'|ezurl(no)}'); $.each({ldelim}RemoveButton: '1', 'DeleteIDArray[]': '{$bookmark_id}', NeedRedirectBack: '1', RedirectURI: '{concat('/', $current_node.url_alias)|ezurl(no)}'{rdelim}, function (k, v) {ldelim} $('<input>', {ldelim}type: 'hidden', name: k, value: v{rdelim}).appendTo(f); {rdelim}); f.get(0).submit(); return false;">
                                                <i aria-hidden="true" class="fa fa-fw fa-bookmark"></i>
                                                <span class="toolbar-item-label">Rimuovi dai preferiti</span>
                                            </a>
                                        {else}
                                            <a class="list-item left-icon" href="#"
                                               onclick="var f = $(this).closest('form'); $('<input>', {ldelim}type: 'hidden', name: 'ActionAddToBookmarks', value: '1'{rdelim}).appendTo(f); f.get(0).submit(); return false;">
                                                <i aria-hidden="true" class="fa fa-fw fa-bookmark-o"></i>
                                                <span class="toolbar-item-label">Aggiungi ai preferiti</span>
                                            </a>
                                        {/if}
                                        </li>
                                        {undef $bookmark_id}
                                    {/if}
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
                                                <i aria-hidden="true" class="fa fa-fw fa-code"></i> Linked Data
                                                {foreach $onto_links as $slug => $link}
                                                    <a href="{$link}" target="_blank" rel="noopener noreferrer"  title="{$slug|wash()}" class="badge badge-dark bg-dark text-white d-inline px-1">{$slug|wash()}</a>
                                                {/foreach}
                                            </div>
                                        </li>
                                    {else}
                                        <li>
                                            <a class="list-item left-icon" href="{concat('opendata/api/data/read/',$content_object.id)|ezurl(no)}" title="{'View in json'|i18n( 'bootstrapitalia' )}">
                                                <i aria-hidden="true" class="fa fa-fw fa-code"></i> <span class="toolbar-item-label">{'View in json'|i18n( 'bootstrapitalia' )}</span>
                                            </a>
                                        </li>
                                    {/if}
                                    {undef $onto_links}

                                    {if and($content_object.class_identifier|eq('place'), openagenda_can_push_place())}
                                        <li><span class="divider"></span></li>
                                        <li>
                                            <a class="list-item left-icon" href="{concat('bootstrapitalia/bridge/push-openagenda-place/',$content_object.id)|ezurl(no)}" title="{'Push to openagenda'|i18n( 'bootstrapitalia' )}">
                                                <i aria-hidden="true" class="fa fa-fw fa-external-link-square"></i> <span class="toolbar-item-label">{'Push place on OpenAgenda'|i18n( 'bootstrapitalia' )}</span>
                                            </a>
                                        </li>
                                    {/if}

                                    {if and($content_object.class_identifier|eq('document'), fetch( 'user', 'has_access_to', hash( 'module', 'relata', 'function', 'view' ) ))}
                                        {def $can_view_relata = false()
                                             $albo_pretorio_tag_remote_id = '984c6235761dac258fe8c245541095fa'} {* Documenti Albo Pretorio *}
                                        {if $content_object|has_attribute('document_type')}
                                            {foreach $content_object|attribute('document_type').content.tags as $tag}
                                                {if $tag.remote_id|eq($albo_pretorio_tag_remote_id)}
                                                    {set $can_view_relata = true()}
                                                    {break}
                                                {/if}
                                                {foreach $tag.path as $parent_tag}
                                                {if $parent_tag.remote_id|eq($albo_pretorio_tag_remote_id)}
                                                    {set $can_view_relata = true()}
                                                    {break}
                                                {/if}
                                                {/foreach}
                                            {/foreach}
                                        {/if}
                                        {if $can_view_relata}
                                        <li><span class="divider"></span></li>
                                        <li>
                                            <a class="list-item left-icon" href="{concat('relata/view/',$content_object.id)|ezurl(no)}" title="Relate di pubblicazione">
                                                <i aria-hidden="true" class="fa fa-fw fa-file-pdf-o"></i> <span class="toolbar-item-label">Relata di pubblicazione</span>
                                            </a>
                                        </li>
                                        {/if}
                                        {undef $can_view_relata}
                                    {/if}
                                {/if}

                            </ul>
                        </div>
                    </div>
                </div>
            </li>


            {if is_set($content_object.id)}
                <li class="toolbar-divider" aria-hidden="true"></li>
            {/if}

            {if is_approval_enabled()}
                {def $unread_message_count = approval_unread_message_count()}
                {def $pending_approval_count = cond(not(current_user_needs_approval()), pending_approval_count(), 0)}
                <li class="position-relative">
                    {if or($pending_approval_count|gt(0), $unread_message_count)}
                        <span id="approval-count" class="badge badge-warning bg-warning position-absolute pulsate" style="top: 0;right: 0;">
                            {$pending_approval_count|sum($unread_message_count)}
                        </span>
                        <div class="dropdown">
                            <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownApproval" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i aria-hidden="true" class="fa fa-check-circle-o"></i>
                                <span class="toolbar-label">{'Approval'|i18n( 'bootstrapitalia/moderation' )}</span>
                            </button>
                            <div class="dropdown-menu" aria-labelledby="dropdownApproval">
                                <div class="link-list-wrapper">
                                    <ul class="link-list">
                                        <li id="approval-placeholder">
                                            <a style="min-width:300px" class="list-item text-center" href="#">
                                                <i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-fw"></i>
                                            </a>
                                        </li>
                                        <li id="approval-items"></li>
                                        <li><span class="divider"></span></li>
                                        <li>
                                            <a class="list-item left-icon" href="{'bootstrapitalia/approval'|ezurl(no)}" title="{'Approval'|i18n( 'bootstrapitalia/moderation' )}">
                                                <i aria-hidden="true" class="fa fa-fw fa-check-circle-o"></i> <span class="toolbar-item-label">{'Go to the moderation dashboard'|i18n( 'bootstrapitalia/moderation' )}</span>
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    {else}
                        <a href="{'bootstrapitalia/approval'|ezurl(no)}" title="{'Approval'|i18n( 'bootstrapitalia/moderation' )}">
                            <i aria-hidden="true" class="fa fa-check-circle-o"></i>
                            <span class="toolbar-label">{'Approval'|i18n( 'bootstrapitalia/moderation' )}</span>
                        </a>
                    {/if}
                </li>
                <li class="toolbar-divider" aria-hidden="true"></li>
                {undef $unread_message_count $pending_approval_count}
            {/if}

            {if and(fetch( 'user', 'has_access_to', hash( 'module', 'newsletter', 'function', 'index' ) ), ezmodule('newsletter','subscribe'), fetch( 'content', 'class', hash( 'class_id', 'cjw_newsletter_system' ) ))}
                {include uri='design:parts/websitetoolbar/newsletter.tpl' content_object=$content_object current_node=$current_node}
            {/if}

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
                fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'roles' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'valuation', 'function', 'dashboard' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'list' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'edit' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'opencity_info_editor' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'migration', 'function', 'dasboard' ) ),
                fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'service_tools' ) )
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
                                {* has_access_to_limitation('user', 'login', hash('SiteAccess', '<!-- SiteAccessName -->')) *}
                                {*if ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' )}
                                    <li>
                                        <a class="list-item left-icon" href="{ezini( 'SiteSettings', 'AdditionalLoginFormActionURL' )|explode('user/login')[0]}{$current_node.url_alias}" rel="noopener noreferrer" target="_blank" title="{'Go to admin interface.'|i18n( 'design/standard/parts/website_toolbar' )}">
                                            <i aria-hidden="true" class="fa fa-fw fa-wrench"></i>
                                            <span class="toolbar-item-label">Backend</span>
                                        </a>
                                    </li>
                                {/if*}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'draft' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{"content/draft"|ezurl(no)}" title="{"My drafts"|i18n("design/ocbootstrap/user/edit")}">
                                            <i aria-hidden="true" class="fa fa-fw fa-pencil-square"></i>
                                            <span class="toolbar-item-label">{"My drafts"|i18n("design/ocbootstrap/user/edit")}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if openpaini( 'WebsiteToolbar', 'ShowMediaRoot', 'enabled' )|eq('enabled')}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('content/view/full/',ezini('NodeSettings', 'MediaRootNode', 'content.ini'))|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-image"></i>
                                            <span class="toolbar-item-label">{'Media library'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if openpaini( 'WebsiteToolbar', 'ShowUsersRoot', 'enabled' )|eq('enabled')}
                                    <li>
                                        <a class="list-item left-icon" href="{concat('content/view/full/',ezini('NodeSettings', 'UserRootNode', 'content.ini'))|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-users"></i>
                                            <span class="toolbar-item-label">{'Users'|i18n( 'design/admin/setup/session' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {include uri='design:parts/websitetoolbar/ezsurvey.tpl'}
                                <li>
                                    <a class="list-item left-icon" href="{'opendata/console/1'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-fw fa-code"></i>
                                        <span class="toolbar-item-label">{'API console'|i18n( 'bootstrapitalia' )}</span>
                                    </a>
                                </li>
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'roles' ) )}
                                <li>
                                    <a class="list-item left-icon" href="{'openpa/roles'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-fw fa-user-o"></i>
                                        <span class="toolbar-item-label">{'Administrative roles'|i18n( 'bootstrapitalia' )}</span>
                                    </a>
                                </li>
                                {/if}
                                {if and( openpaini( 'WebsiteToolbar', 'ShowEditorRoles', 'disabled' )|eq('enabled'), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'permissions' ) ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/permissions'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-user-secret"></i>
                                            <span class="toolbar-item-label">{'Access Management'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'theme' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/theme'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-television"></i>
                                            <span class="toolbar-item-label">{'Theme management'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'seo' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'openpa/seo'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-google"></i>
                                            <span class="toolbar-item-label">{'S.E.O.'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'recaptcha' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'openpa/recaptcha'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-key"></i>
                                            <span class="toolbar-item-label">{'Recapetcha key management'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'rss', 'function', 'edit' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'rss/list'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-rss-square"></i>
                                            <span class="toolbar-item-label">{'RSS exports'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'trash' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'content/trash'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-trash"></i>
                                            <span class="toolbar-item-label">{'Trash'|i18n( 'design/standard/content/trash' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if and(openpaini('GeneralSettings','Valuation', 1), fetch( 'user', 'has_access_to', hash( 'module', 'valuation', 'function', 'dashboard' ) ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'valuation/dashboard'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-dashboard"></i>
                                            <span class="toolbar-item-label">{'User feedbacks'|i18n("bootstrapitalia/valuation")}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'list' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'webhook/list'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-external-link-square"></i>
                                            <span class="toolbar-item-label">{'Webhooks'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'urltranslator' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'content/urltranslator'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-link"></i>
                                            <span class="toolbar-item-label">{'URL translator'|i18n( 'design/admin/parts/setup/menu' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'opencity_info_editor' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/info'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-phone-square"></i>
                                            <span class="toolbar-item-label">{'General information management'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'migration', 'function', 'dashboard' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'migration/dashboard'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-cloud-upload"></i>
                                            <span class="toolbar-item-label">{'Migration assistant'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'service_tools' ) )}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/service_tools'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-share-alt"></i>
                                            <span class="toolbar-item-label">{'Public service sync tool'|i18n( 'bootstrapitalia' )}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if and(custom_booking_is_enabled(), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'booking_config' ) ))}
                                    <li>
                                        <a class="list-item left-icon" href="{'bootstrapitalia/booking_config'|ezurl(no)}">
                                            <i aria-hidden="true" class="fa fa-fw fa-share-alt"></i>
                                            <span class="toolbar-item-label">Configurazione calendari{*'Configurazione calendari'|i18n( 'bootstrapitalia' )*}</span>
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

            {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'permissions' ) )}
            <li class="toolbar-divider" aria-hidden="true"></li>
            <li>
                <a class="btn btn-text" href="https://opencityitalia.it/it/iscriviti/" target="_blank" rel="noopener">
                  <i aria-hidden="true" class="fa fa-newspaper-o"></i>  
                  <span class="toolbar-label">{'Newsletter signup'|i18n( 'bootstrapitalia' )}</span>
                </a>
            </li>
            {/if}

            {if openpaini( 'StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled' )|ne('disabled')}
            {* con il loginbox attivo il pannello utente del CMS vive nella toolbar e non nell'header *}
            <li class="toolbar-divider" aria-hidden="true"></li>
            <li>
                <div class="dropdown">
                    <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownUser" data-toggle="dropdown" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i aria-hidden="true" class="fa fa-user-circle-o"></i>
                        <span class="toolbar-label">{$current_user.contentobject.name|wash()}</span>
                    </button>
                    <div class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownUser">
                        <div class="link-list-wrapper">
                            <ul class="link-list">
                                <li>
                                    <a class="list-item left-icon" href="{'user/edit'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-fw fa-user-o"></i>
                                        <span class="toolbar-item-label">{'User profile'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                                {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'dashboard' ) )}
                                <li>
                                    <a class="list-item left-icon" href="{'content/dashboard'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-fw fa-dashboard"></i>
                                        <span class="toolbar-item-label">{'Dashboard'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                                {/if}
                                <li><span class="divider"></span></li>
                                <li>
                                    <a class="list-item left-icon" href="{'user/logout'|ezurl(no)}">
                                        <i aria-hidden="true" class="fa fa-fw fa-sign-out"></i>
                                        <span class="fw-bold toolbar-item-label">{'Logout'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
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

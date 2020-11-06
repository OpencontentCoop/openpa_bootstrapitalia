<div class="row mb-3">

    <div class="col-md-3 text-right text-primary">Ultima modifica di:</div>
    <div class="col-md-9">
        {if is_set($node.creator.main_node)}
            <a href={$node.creator.main_node.url_alias|ezurl}>{$node.creator.name}</a>
            il {$node.object.modified|l10n(shortdatetime)}
        {else}
            ?
        {/if}
    </div>

    <div class="col-md-3 text-right text-primary">Creato da:</div>
    <div class="col-md-9">
        {if and( $node.object.owner, $node.object.owner.main_node )}
            <a href={$node.object.owner.main_node.url_alias|ezurl}>{$node.object.owner.name}</a>
            il {$node.object.published|l10n(shortdatetime)}
        {else}
            ?
        {/if}
    </div>

    <div class="col-md-3 text-right text-primary">Nodo:</div>
    <div class="col-md-9">
        {if $openpa.content_icon.context_icon}
            {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon icon-sm')}
        {/if}
        {$node.node_id}
    </div>

    <div class="col-md-3 text-right text-primary">Oggetto</div>
    <div class="col-md-9">
        {if $openpa.content_icon.object_icon}
            {display_icon($openpa.content_icon.object_icon.icon_text, 'svg', 'icon icon-sm')}
        {/if}
        {$node.contentobject_id} ({$node.object.remote_id})
    </div>

    <div class="col-md-3 text-right text-primary">Collocazioni:</div>
    <div class="col-md-9">
        <ul class="list-unstyled">
            {foreach $node.object.assigned_nodes as $item}
                <li>
                    <a href={$item.url_alias|ezurl()}>
                        <small>{$item.path_with_names} {if $item.node_id|eq($node.object.main_node_id)}(principale){/if}</small>
                    </a>
                </li>
            {/foreach}
        </ul>
    </div>

    <div class="col-md-3 text-right text-primary">Sezione:</div>
    <div class="col-md-9">
        {def $sections = $node.object.allowed_assign_section_list}
        {if and($node.depth|gt(3), count($sections)|gt(1))}
            <form name="changesection" id="changesection" method="post" action={concat( 'content/edit/', $node.object.id )|ezurl}>
                <input type="hidden" name="RedirectRelativeURI" value="{$node.url_alias|wash}" />
                <input type="hidden" name="ChangeSectionOnly" value="1" />
                <label for="SelectedSectionId" class="sr-only">{'Choose section'|i18n( 'design/admin/node/view/full' )}:</label>
                <div class="input-group input-group-sm w-75">
                    <select class="custom-select custom-select-sm border" id="SelectedSectionId" name="SelectedSectionId" aria-label="{'Choose section'|i18n( 'design/admin/node/view/full' )}">
                        {foreach $sections as $section}
                            {if eq( $section.id, $node.object.section_id )}
                                <option value="{$section.id}" selected="selected">{$section.name|wash}</option>
                            {else}
                                <option value="{$section.id}">{$section.name|wash}</option>
                            {/if}
                        {/foreach}
                    </select>
                    <div class="input-group-append">
                        <button class="btn btn-xs btn-secondary" name="SectionEditButton" type="submit">{'Set'|i18n( 'design/standard/websitetoolbar/sort' )}</button>
                    </div>
                </div>
            </form>
        {else}
            {fetch( 'section', 'object', hash( 'section_id', $node.object.section_id )).name|wash}
        {/if}
        {undef $sections}
    </div>

    <div class="col-md-3 text-right text-primary">Tipo:</div>
    <div class="col-md-9">
        <a target="_blank"
           href="{concat('classtools/classes/', $node.class_identifier)|ezurl(no)}">
            {if $openpa.content_icon.class_icon}
                {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon icon-sm')}
            {/if}
            {$node.class_name} ({$node.class_identifier} {$node.object.contentclass_id})
        </a>
    </div>

    {if $openpa.content_virtual.folder}
        <div class="col-md-3 text-right text-primary">Folder virtuale:</div>
        <div class="col-md-9">
            {$openpa.content_virtual.folder.classes|implode(', ')}
            ({foreach $openpa.content_virtual.folder.subtree as $node_id}<a
            href="{concat( 'content/view/full/', $node_id)|ezurl(no)}">{$node_id}</a>{delimiter}, {/delimiter}{/foreach}
            )
        </div>
    {/if}

    {if and( is_set( $openpa.content_albotelematico ), $openpa.content_albotelematico.is_container )}
        <div class="col-md-3 text-right text-primary">Albo telematico:</div>
        <div class="col-md-9">Pagina configurata come contenitore di documenti Albo telematico
            <small>(vengono visualizzati i contenuti figli della collocazione principale)</small>
        </div>
    {/if}

    {if $openpa.content_virtual.calendar}
        <div class="col-md-3 text-right text-primary">Calendario virtuale:</div>
        <div class="col-md-9">
            ({foreach $openpa.content_virtual.calendar.subtree as $node_id}<a
            href="{concat( 'content/view/full/', $node_id)|ezurl(no)}">{$node_id}</a>{delimiter}, {/delimiter}{/foreach}
            )
        </div>
    {/if}

    {if and( is_set( $node.data_map.data_iniziopubblicazione ), $node.data_map.data_iniziopubblicazione.has_content, $node.data_map.data_iniziopubblicazione.content.timestamp|gt(0) )}
        <div class="col-md-3 text-right text-primary">{$node.data_map.data_iniziopubblicazione.contentclass_attribute_name}</div>
        <div class="col-md-9">{attribute_view_gui attribute=$node.data_map.data_iniziopubblicazione}</div>
    {/if}

    {if and( is_set( $node.data_map.data_finepubblicazione ), $node.data_map.data_finepubblicazione.has_content, $node.data_map.data_finepubblicazione.content.timestamp|gt(0) )}
        <div class="col-md-3 text-right text-primary">{$node.data_map.data_finepubblicazione.contentclass_attribute_name}</div>
        <div class="col-md-9">{attribute_view_gui attribute=$node.data_map.data_finepubblicazione}</div>
    {/if}

    {if and( is_set( $node.data_map.data_archiviazione ), $node.data_map.data_archiviazione.has_content, $node.data_map.data_archiviazione.content.timestamp|gt(0) )}
        <div class="col-md-3 text-right text-primary">{$node.data_map.data_archiviazione.contentclass_attribute_name}</div>
        <div class="col-md-9">{attribute_view_gui attribute=$node.data_map.data_archiviazione}</div>
    {/if}

    {def $states = $node.object.allowed_assign_state_list}
    {if $states|count}
        <div class="col-md-3 text-right text-primary">Stati:</div>
        <div class="col-md-9">

            {foreach $states as $allowed_assign_state_info}{foreach $allowed_assign_state_info.states as $state}{if $node.object.state_id_array|contains($state.id)}{$allowed_assign_state_info.group.current_translation.name|wash()}/{$state.current_translation.name|wash}{/if}{/foreach}{delimiter}, {/delimiter}{/foreach}
        </div>
    {/if}

    {if $node.object.can_translate}
        <div class="col-md-3 text-right text-primary">Traduzioni:</div>
        <div class="col-md-9">
            <ul class="list-inline">
                {foreach $node.object.languages as $language}
                    {if $node.object.available_languages|contains($language.locale)}
                        <li>
                            <a class="mr-3" href="{concat( $node.url_alias, '/(language)/', $language.locale )|ezurl(no)}">
                                {if $language.locale|eq($node.object.current_language)}<strong>{/if}
                                    <small>{$language.name|wash()}</small>
                                {if $language.locale|eq($node.object.current_language)}</strong>{/if}
                            </a>
                            <a href="{concat('content/edit/', $node.object.id, '/f/', $language.locale)|ezurl(no)}">
                                <i class="fa fa-pencil"></i>
                            </a>
                        </li>
                    {/if}
                {/foreach}
                <li>
                    {def $can_create_languages = $node.object.can_create_languages
                         $languages = fetch( 'content', 'prioritized_languages' )}
                    <form method="post" action={"content/action"|ezurl}>
                        <input type="hidden" name="HasMainAssignment" value="1"/>
                        <input type="hidden" name="ContentObjectID" value="{$node.object.id}"/>
                        <input type="hidden" name="NodeID" value="{$node.node_id}"/>
                        <input type="hidden" name="ContentNodeID" value="{$node.node_id}"/>
                        <input type="hidden" name="ContentObjectLanguageCode" value=""/>
                        <input type="submit" name="EditButton" class="btn btn-xs btn-secondary" value="Modifica/inserisci traduzione"/>
                    </form>
                </li>
            </ul>
        </div>
    {/if}

    {*if $openpa.content_globalinfo.has_content}
        <div class="col-md-3 text-right text-primary">Global info</div>
        <div class="col-md-9">
            {if $openpa.content_globalinfo.object.parent_node_id|ne( $node.node_id )}
                <small>
                    Ereditato da <a
                            href={$openpa.content_globalinfo.object.parent.url_alias|ezurl()}>{$openpa.content_globalinfo.object.parent.name|wash()}</a>
                </small>
                {if fetch( 'content', 'access', hash( 'access', 'create', 'contentclass_id', 'global_layout', 'contentobject', $node ) )}
                    <form method="post" action="{"content/action"|ezurl(no)}" class="form inline"
                          style="display:inline">
                        <input type="hidden" name="HasMainAssignment" value="1"/>
                        <input type="hidden" name="ContentObjectID" value="{$node.object.id}"/>
                        <input type="hidden" name="NodeID" value="{$node.node_id}"/>
                        <input type="hidden" name="ContentNodeID" value="{$node.node_id}"/>
                        <input type="hidden" name="ContentLanguageCode" value="ita-IT"/>
                        <input type="hidden" name="ContentObjectLanguageCode" value="ita-IT"/>
                        <input type="hidden" value="global_layout" name="ClassIdentifier"/>
                        <input type="submit" class="btn btn-xs btn-default" value="Crea un box dedicato"
                               name="NewButton"/>
                        <input type="hidden" name="RedirectIfDiscarded" value="{$node.url_alias}"/>
                        <input type="hidden" name="RedirectURIAfterPublish" value="{$node.url_alias}"/>
                    </form>
                {/if}
            {/if}
            <form action="{"/content/action"|ezurl(no)}" method="post" class="form inline" style="display:inline">
                {if $openpa.content_globalinfo.object.object.can_edit}
                    <input type="submit" name="EditButton" value="Modifica box" class="btn btn-xs btn-default"
                           title="Modifica {$openpa.content_globalinfo.object.name|wash()}"/>
                    <input type="hidden" name="ContentObjectLanguageCode"
                           value="{$openpa.content_globalinfo.object.object.current_language}"/>
                {/if}
                {if $openpa.content_globalinfo.object.object.can_remove}
                    <input type="submit" class="btn btn-xs btn-default" name="ActionRemove" value="Elimina box"
                           alt="Elimina {$openpa.content_globalinfo.object.name|wash()}"
                           title="Elimina {$openpa.content_globalinfo.object.name|wash()}"/>
                {/if}
                <input type="hidden" name="ContentObjectID" value="{$openpa.content_globalinfo.object.object.id}"/>
                <input type="hidden" name="NodeID" value="{$openpa.content_globalinfo.object.node_id}"/>
                <input type="hidden" name="ContentNodeID" value="{$openpa.content_globalinfo.object.node_id}"/>
                <input type="hidden" name="RedirectIfDiscarded" value="{$node.url_alias}"/>
                <input type="hidden" name="RedirectURIAfterPublish" value="{$node.url_alias}"/>
            </form>
        </div>
    {elseif and( $openpa.content_globalinfo.has_content|not(), $node.can_create)}
        <div class="col-md-3 text-right text-primary">Global info</div>
        <div class="col-md-9">
            <form method="post" action="{"content/action"|ezurl(no)}" class="form inline" style="display:inline">
                <input type="hidden" name="HasMainAssignment" value="1"/>
                <input type="hidden" name="ContentObjectID" value="{$node.object.id}"/>
                <input type="hidden" name="NodeID" value="{$node.node_id}"/>
                <input type="hidden" name="ContentNodeID" value="{$node.node_id}"/>
                <input type="hidden" name="ContentLanguageCode" value="ita-IT"/>
                <input type="hidden" name="ContentObjectLanguageCode" value="ita-IT"/>
                <input type="hidden" value="global_layout" name="ClassIdentifier"/>
                <input type="submit" class="btn btn-xs btn-secondary" value="Crea un box dedicato" name="NewButton"/>
            </form>
        </div>
    {/if*}

    {* NEWSLETTER *}
    {if ezmodule('newsletter','subscribe')}
        {def $newsletter_edition_hash = newsletter_edition_hash()}
        {if and( $node|can_add_to_newsletter(true()), $newsletter_edition_hash|count()|gt(0) )}
            <div class="col-md-3 text-right text-primary">Newsletter</div>
            <div class="col-md-9">
            <form action={concat("/openpa/addlocationto/",$node.contentobject_id)|ezurl} method="post">

                <label for="add_to_newsletter">Aggiungi alla prossima newsletter:</label>
                <div class="input-group">
                    <select name="SelectedNodeIDArray[]" id="add_to_newsletter" class="form-control custom-select">
                        {foreach $newsletter_edition_hash as $edition_id => $edition_name}
                            <option value="{$edition_id}">{$edition_name|wash()}</option>
                        {/foreach}
                    </select>
                    <div class="input-group-append">
                        <input class="btn btn-xs btn-secondary" type="submit" name="AddLocation" value="Aggiungi"/>
                    </div>
                </div>
            </form>
            </div>
        {/if}        
        {undef $newsletter_edition_hash}
    {/if}


</div>


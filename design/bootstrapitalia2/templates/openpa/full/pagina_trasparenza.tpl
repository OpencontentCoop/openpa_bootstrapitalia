{ezpagedata_set( 'has_container', true() )}

{if openpaini('Trasparenza', 'ForceMainNode', 'disabled')|eq('enabled')}
    {set $node = $node.object.main_node}
{/if}

{def $trasparenza = $openpa.content_trasparenza
     $root_node = $openpa.control_menu.side_menu.root_node
     $tree_menu = tree_menu( hash( 'root_node_id', $root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $summary_items = array()
     $table_view = class_extra_parameters($node.class_identifier, 'table_view')
     $editor_identifiers = array( 
        'denominazione_degli_obblighi',
        'guida_alla_compilazione',
        'messaggio_di_consiglio',
        'decorrenza_di_pubblicazione',
        'aggiornamento',
        'termine_pubblicazione' )
     $editor_group_has_content = false()
     $user_identifiers = array( 
        'applicabilita',
        'riferimenti_normativi',
        'contenuto_obbligo' )
     $user_group_has_content = false()}        

{foreach $table_view.show as $attribute_identifier}
    {if or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty)}
        {set $summary_items = $summary_items|append(
            hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', true(), 'wrap', false() )
        )}
    {/if}
{/foreach}
{foreach $node.data_map as $identifier => $attribute}
    {if and( $editor_identifiers|contains( $identifier ), $attribute.has_content )}
        {set $editor_group_has_content = true()}
        {break}
    {/if}
{/foreach}
{foreach $node.data_map as $identifier => $attribute}
    {if and( $user_identifiers|contains( $identifier ), $attribute.has_content )}
        {set $user_group_has_content = true()}
        {break}
    {/if}
{/foreach}

{def $menu_type = openpaini('SideMenu', 'AmministrazioneTrasparenteTipoMenu', 'default')}
{if and($root_node|has_attribute('show_browsable_menu'), $root_node|attribute('show_browsable_menu').data_int|eq(1))}
    {set $menu_type = 'browsable'}
{/if}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            {include uri='design:openpa/full/parts/amministrazione_trasparente/intro.tpl' node=$root_node}
            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

<section class="container">
    <div class="row border-top row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="d-block d-lg-none d-xl-none text-center mb-2">
                <a href="#toogle-sidemenu" role="button" class="btn btn-primary btn-md collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="toogle-sidemenu"><i class="fa fa-bars" aria-hidden="true"></i> {$tree_menu.item.name|wash()}</a>
            </div>
            <div class="d-lg-block d-xl-block collapse" id="toogle-sidemenu">
                <div class="link-list-wrapper menu-link-list pt-2">
                    <ul class="link-list">
                        {*<li><h3><a class="text-dark" href="{$root_node.url_alias|ezurl(no)}">{$root_node.name|wash()}</a></h3></li>*}
                        {foreach $tree_menu.children as $menu_item}
                            {include name=side_menu
                                     uri=cond($menu_type|eq('browsable'), 'design:openpa/full/parts/browsable_side_menu_item.tpl', 'design:openpa/full/parts/side_menu_item.tpl')
                                     menu_item=$menu_item
                                     current_node=$node
                                     max_recursion=3
                                     recursion=1}
                        {/foreach}
                    </ul>
                </div>
            </div>
        </aside>
        <section class="col-lg-8 p-4">
            <h2 class="h4 mb-4">{$node.data_map.titolo.content|wash()}</h2>

            {if $node|has_attribute('abstract')}
                {attribute_view_gui attribute=$node|attribute('abstract')}
            {/if}

            {if $trasparenza.show_alert}                    
                <div class="alert alert-warning">
                    Sezione in allestimento
                </div>
            {/if}
            
            {* Guida al cittadino *}
            {if and($user_group_has_content, openpaini('Trasparenza', 'MostraGuidaAlCittadino', 'enabled')|eq('enabled'))}
            <section class="callout w-100 mw-100 note">
                <h3 class="callout-title">{display_icon('it-help-circle', 'svg', 'icon')}{'Citizen\'s Guide'|i18n('bootstrapitalia')}</h3>
                {foreach $node.data_map as $identifier => $attribute}
                    {if and( $user_identifiers|contains( $identifier ), $attribute.has_content, $attribute.data_text|ne('') )}        
                        <h4 class="h6">{$attribute.contentclass_attribute_name}</h4>
                        <div class="richtext-wrapper lora neutral-1-color-a7 mb-3">{attribute_view_gui attribute=$attribute}</div>
                    {/if}
                {/foreach}
            </section>            
            {/if} 

            {* Guida al redattore *}
            {if and( $editor_group_has_content, $node.can_create )}            
            <section class="callout w-100 mw-100 danger">
                <h3 class="callout-title">{display_icon('it-help-circle', 'svg', 'icon')}{'Editor\'s Guide'|i18n('bootstrapitalia')}</h3>
                {foreach $node.data_map as $identifier => $attribute}
                  {if and( $editor_identifiers|contains( $identifier ), $attribute.has_content, $attribute.data_text|ne('') )}        
                    <h4 class="h6">{$attribute.contentclass_attribute_name}</h4>
                    <div class="richtext-wrapper lora neutral-1-color-a7 mb-3">{attribute_view_gui attribute=$attribute}</div>
                  {/if}
                {/foreach}
                {if $trasparenza.has_table_fields}                
                    <h4 class="h6">Regole rappresentazione impostate</h4>
                    <div class="richtext-wrapper lora neutral-1-color-a7 mb-3">
                    {foreach $trasparenza.table_fields as $table_index => $fields}
                        <p>
                            <a target="_blank"
                              rel="noopener"
                              href="{concat('/opendata/console/1?query=',$fields.query|urlencode())|ezurl(no)}">
                                <code style="word-break: break-all;">{$fields.raw|wash()}</code>
                            </a>
                        </p>
                        {if and(
                            openpaini('Trasparenza', concat('ShowCsvImportWidget_', $fields.class_identifier), 'disabled')|eq('enabled'),
                            $fields.parent_node_id|eq($node.node_id)
                        )}
                        <div class="font-sans-serif">
                            <h4 class="h6">Caricamento massivo</h4>
                            {include uri="design:parts/csv_import_widget.tpl"
                                example=openpaini('Trasparenza', concat('CsvImportWidgetExample_', $fields.class_identifier), false())
                                parent_node_id=$fields.parent_node_id
                                class_identifier=$fields.class_identifier}
                        </div>
                        {/if}
                    {/foreach}
                    </div>
                {/if}
            </section>            
            {/if}  

            {* Nota: visualizzazione e modifica/creazione di una sola nota *}
            {if $trasparenza.has_nota_trasparenza}
                <section class="callout w-100 mw-100 danger">
                    <div class="callout-title">
                        {display_icon('it-help-circle', 'svg', 'icon')}{'Note'|i18n('bootstrapitalia')}
                        {include uri="design:parts/toolbar/node_edit.tpl" current_node=$trasparenza.nota_trasparenza}
                        {include uri="design:parts/toolbar/node_trash.tpl" current_node=$trasparenza.nota_trasparenza}
                    </div>
                    <div class="richtext-wrapper lora neutral-1-color-a7 mb-3">
                        <div class="fst-italic">{attribute_view_gui attribute=$trasparenza.nota_trasparenza.data_map.testo_nota}</div>
                        {if $trasparenza.nota_trasparenza|has_attribute('file')}
                            <span>{attribute_view_gui attribute=$trasparenza.nota_trasparenza|attribute('file')}</span>
                        {/if}                        
                    </div>
                </section>
            {elseif $node.object.can_create}
                <section class="callout w-100 mw-100 danger p-4">
                    <h3 class="callout-title">{display_icon('it-help-circle', 'svg', 'icon')}{'Note'|i18n('bootstrapitalia')}</h3>
                    <form method="post" action="{'content/action'|ezurl(no)}" style="display:inline">
                        <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
                        <input type="hidden" name="HasMainAssignment" value="1" />
                        <input type="hidden" name="ClassIdentifier" value="nota_trasparenza" />
                        <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}" />
                        <input type="hidden" name="NodeID" value="{$node.node_id}" />
                        <input type="hidden" name="ContentNodeID" value="{$node.node_id}" />
                        <button class="btn btn-link p-0" type="submit" name="NewButton"><em>{'Add note'|i18n('bootstrapitalia')}</em></button>
                    </form>
                </section>
            {/if}

            {* Rappresentazione grafica (esclusa dal conteggio figli) *}
            {if and(is_set($trasparenza.remote_id_map[$node.object.remote_id]), 'rappresentazione_grafica'|eq($trasparenza.remote_id_map[$node.object.remote_id]))} 
                {include uri='design:openpa/full/parts/amministrazione_trasparente/grafico_enti_partecipati.tpl'}
            {/if}

            {* Figli di classe pagina_trasaparenza *}
            {if $trasparenza.count_children_trasparenza|gt(0)}
                {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                         show_icon=true() view=banner
                         nodes = fetch('content', 'list', $trasparenza.children_trasparenza_fetch_parameters)
                         nodes_count = $trasparenza.count_children_trasparenza}

                {if or($trasparenza.count_children_extra|gt(0), $trasparenza.has_table_fields, $trasparenza.has_blocks)}<hr />{/if}
            {/if}

            {* layout a blocchi *}
            {if $trasparenza.has_blocks}
                {attribute_view_gui attribute=$trasparenza.blocks_attribute}
            {/if}

            {* figli in base a sintassi convenzionale sul campo fields *}
            {if $trasparenza.has_table_fields}
                {foreach $trasparenza.table_fields as $table_index => $fields}
                    {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table_fields.tpl'
                             fields = $fields
                             table_index = $table_index}
                {/foreach}
            {/if}

            {* lista dei figli *}
            {if $trasparenza.count_children_extra}
                {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                         show_icon=true() view=card
                         nodes=fetch('content', 'list', $trasparenza.children_extra_fetch_parameters)
                         nodes_count=$trasparenza.count_children_extra}
            {/if}

            <div class="mt-5">
                {include uri=$openpa['content_show_published'].template}
                {include uri=$openpa['content_show_modified'].template}
            </div>
        </section>
    </div>
</section>

{undef $root_node $tree_menu $table_view $summary_items $editor_group_has_content $editor_identifiers}
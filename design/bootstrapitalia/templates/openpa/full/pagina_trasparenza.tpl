{ezpagedata_set( 'has_container', true() )}

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

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$root_node.name|wash()}</h1>

            {attribute_view_gui attribute=$root_node|attribute('intro') image_class=reference alignment=center}

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
        <aside class="col-lg-4 col-md-4">
            <div class="link-list-wrapper menu-link-list pt-2">
                <ul class="link-list">
                    {*<li><h3><a class="text-dark" href="{$root_node.url_alias|ezurl(no)}">{$root_node.name|wash()}</a></h3></li>*}
                    {foreach $tree_menu.children as $menu_item}
                        {include name=side_menu
                                 uri='design:openpa/full/parts/side_menu_item.tpl'
                                 menu_item=$menu_item
                                 current_node=$node
                                 max_recursion=3
                                 recursion=1}
                    {/foreach}
                </ul>
            </div>
        </aside>
        <section class="col-lg-8 col-md-8 p-4">
            
            <h4 class="mb-4">{$node.data_map.titolo.content|wash()}</h4>

            {if $trasparenza.show_alert}                    
                <div class="alert alert-warning">
                    Sezione in allestimento
                </div>
            {/if}
            
            {* Guida al cittadino *}
            {if $user_group_has_content}            
            <div class="callout w-100 mw-100 note">
                <div class="callout-title">{display_icon('it-help-circle', 'svg', 'icon')}Guida per il cittadino</div>
                {foreach $node.data_map as $identifier => $attribute}
                    {if and( $user_identifiers|contains( $identifier ), $attribute.has_content, $attribute.data_text|ne('') )}        
                        <h6>{$attribute.contentclass_attribute_name}</h6>
                        <div class="text-serif small neutral-1-color-a7 mb-3">{attribute_view_gui attribute=$attribute}</div>                    
                    {/if}
                {/foreach}
            </div>            
            {/if} 

            {* Guida al redattore *}
            {if and( $editor_group_has_content, $node.can_create )}            
            <div class="callout w-100 mw-100 danger">
                <div class="callout-title">{display_icon('it-help-circle', 'svg', 'icon')}Guida per il redattore</div>
                {foreach $node.data_map as $identifier => $attribute}
                    {if and( $editor_identifiers|contains( $identifier ), $attribute.has_content, $attribute.data_text|ne('') )}        
                        <h6>{$attribute.contentclass_attribute_name}</h6>
                        <div class="text-serif small neutral-1-color-a7 mb-3">{attribute_view_gui attribute=$attribute}</div>
                    {/if}
                {/foreach}
                {if $trasparenza.has_table_fields}                
                    <h6>Regole rappresentazione impostate</h6>
                    <div class="text-serif small neutral-1-color-a7 mb-3">
                    {foreach $trasparenza.table_fields as $table_index => $fields}
                        <code>{$fields.query|wash()}</code>
                    {/foreach}
                    </div>
                {/if}
            </div>            
            {/if}  

            {* Nota: visualizzazione e modifica/creazione di una sola nota *}
            {if $trasparenza.has_nota_trasparenza}
                <div class="callout w-100 mw-100 danger">
                    <div class="callout-title">
                        {display_icon('it-help-circle', 'svg', 'icon')}Nota
                        {include uri="design:parts/toolbar/node_edit.tpl" current_node=$trasparenza.nota_trasparenza}
                        {include uri="design:parts/toolbar/node_trash.tpl" current_node=$trasparenza.nota_trasparenza}
                    </div>
                    <div class="text-serif small neutral-1-color-a7 mb-3">
                        <em>{attribute_view_gui attribute=$trasparenza.nota_trasparenza.data_map.testo_nota}</em>
                        {if $trasparenza.nota_trasparenza|has_attribute('file')}
                            <span>{attribute_view_gui attribute=$trasparenza.nota_trasparenza|attribute('file')}</span>
                        {/if}                        
                    </div>
                </div>
            {elseif $node.object.can_create}
                <div class="callout w-100 mw-100 danger p-4">
                    <div class="callout-title">{display_icon('it-help-circle', 'svg', 'icon')}Nota</div>
                    <form method="post" action="{'content/action'|ezurl(no)}" style="display:inline">
                        <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
                        <input type="hidden" name="HasMainAssignment" value="1" />
                        <input type="hidden" name="ClassIdentifier" value="nota_trasparenza" />
                        <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}" />
                        <input type="hidden" name="NodeID" value="{$node.node_id}" />
                        <input type="hidden" name="ContentNodeID" value="{$node.node_id}" />
                        <button class="btn btn-link p-0" type="submit" name="NewButton"><em>Aggiungi nota trasparenza</em></button>
                    </form>
                </div>
            {/if}

            {* Rappresentazione grafica (esclusa dal conteggio figli) *}
            {if and(is_set($trasparenza.remote_id_map[$node.object.remote_id]), 'rappresentazione_grafica'|eq($trasparenza.remote_id_map[$node.object.remote_id]))} 
                {include uri='design:openpa/full/parts/amministrazione_trasparente/grafico_enti_partecipati.tpl'}
            {/if}

            {* Figli di classe pagina_trasaparenza *}
                {if $trasparenza.count_children_trasparenza|gt(0)}
                    
                    {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                             nodes = fetch( 'content', 'list', $trasparenza.children_trasparenza_fetch_parameters )
                             nodes_count = $trasparenza.count_children_trasparenza}

                    {if or($trasparenza.count_children|gt(0), $trasparenza.has_table_fields, $trasparenza.has_blocks)}<hr />{/if}

                {/if}

                {* Altri figli nelle varie visualizzazioni *}
                {if or($trasparenza.count_children|gt(0), $trasparenza.has_table_fields, $trasparenza.has_blocks)}

                    {* layout a blocchi *}
                    {if $trasparenza.has_blocks}

                        {attribute_view_gui attribute=$trasparenza.blocks_attribute}

                        {if $trasparenza.count_children_folder|gt(0)}

                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                     nodes = fetch( 'content', 'list', $trasparenza.children_folder_fetch_parameters )
                                     nodes_count = $trasparenza.count_children_folder}
                        {/if}


                    {* figli in base a sintassi convenzionale sul campo fields *}
                    {elseif $trasparenza.has_table_fields}

                        {foreach $trasparenza.table_fields as $table_index => $fields}
                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table_fields.tpl'
                                     nodes_count = $trasparenza.count_children
                                     fields = $fields
                                     table_index = $table_index}
                        {/foreach}

                        {if $trasparenza.count_children_folder|gt(0)}

                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                     nodes = fetch( 'content', 'list', $trasparenza.children_folder_fetch_parameters )
                                     nodes_count = $trasparenza.count_children_folder}
                        {/if}


                    {* lista dei figli *}
                    {else}

                        {def $figli = fetch( 'content', 'list', $trasparenza.children_fetch_parameters )}

                        {switch match=$trasparenza.remote_id_map[$node.object.remote_id]}

                            {case match=consulenti_e_collaboratori}                            
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='consulenza'}
                            {/case}

                            {case match=incarichi_amministrativi_di_vertice}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='dipendente'}
                            {/case}

                            {case match=dirigenti}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='dipendente'}
                            {/case}

                            {case match=tassi_di_assenza}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='tasso_assenza'}
                            {/case}

                            {case match=incarichi_conferiti}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                nodes=$figli
                                nodes_count=$trasparenza.count_children
                                class='incarico'}
                            {/case}

                            {case match=atti_di_concessione}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class=array( 'sovvenzione_contributo', 'determinazione', 'deliberazione' )}
                            {/case}

                            {* default *}
                            {case}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children}
                            {/case}
                        {/switch}

                    {/if}
                {/if}

                {if $trasparenza.count_children_extra|gt(0)}
                    {*if $node.object.can_create}
                        {editor_warning('Vengono visualizzazi qui i contenuti presenti che non corrispondono alle classi di contenuto consigliate in "Guida per il redattore"')}
                    {/if*}  
                    
                    {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                             nodes = fetch( 'content', 'list', $trasparenza.children_extra_fetch_parameters )
                             nodes_count = $trasparenza.count_children_extra
                             title=false()
                             class=array()
                             hide_date=true()}    
                    
                {/if}

        </section>
    </div>
</section>

{undef $root_node $tree_menu $table_view $summary_items $editor_group_has_content $editor_identifiers}
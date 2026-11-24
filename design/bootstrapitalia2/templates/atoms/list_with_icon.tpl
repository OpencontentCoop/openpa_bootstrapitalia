{set_defaults(hash(
    'show_link', true()
))}
<ul class="link-list">
    {foreach $items as $child}
        {* Contenuto privacy.private ma comunque visibile (can_read vero
           solo per chi ha il permesso, es. redattore/admin - un anonimo non
           arriva nemmeno a questo branch): opacita' ridotta per segnalarlo
           come nascosto ai cittadini, senza nasconderlo del tutto a chi lo
           gestisce - richiesto da Marco per le pagine "Provvedimenti..."
           ritirate con redirect (hideContentWithRedirect()), ma generico per
           qualunque nodo privato in questo elenco. *}
        {def $is_hidden_to_visitors = $child.object.state_identifier_array|contains('privacy/private')}
        <li{if $is_hidden_to_visitors} class="opacity-50"{/if}>
            {if and(object_handler($child).content_link.is_node_link|not(), $child.can_edit)}
                <a class="float-right" href="{$child.url_alias|ezurl(no)}"><i aria-hidden="true" class="fa fa-wrench"></i></a>
            {/if}
            {if and($show_link,$child.can_read)}
            {node_view_gui content_node=$child
                                   view=text_linked
                                   show_icon=true()}
            {else}
               {$child.name|wash()}
            {/if}
        </li>
    {/foreach}
</ul>
{unset_defaults(array('show_link'))}
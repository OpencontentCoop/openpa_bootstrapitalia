{def $contacts = $pagedata.contacts}
<div class="link-list-wrapper">
    <ul class="footer-list link-list clearfix">
        {if is_set($contacts.indirizzo)}
            <li>
                <a class="list-item" href="http://maps.google.com/maps?q={$contacts.indirizzo|urlencode}">
                    {display_icon('it-pa', 'svg', 'icon icon-sm icon-white')}
                    {$contacts.indirizzo}
                </a>
            </li>
        {/if}

        {if is_set($contacts.telefono)}
            <li>
                {def $tel = strReplace($contacts.telefono,array(" ",""))}
                <a class="list-item" href="tel:{$tel}">
                    {display_icon('it-telephone', 'svg', 'icon icon-sm icon-white')}
                    {$contacts.telefono}
                </a>
            </li>
        {/if}
        {if is_set($contacts.fax)}
            <li>
                {def $fax = strReplace($contacts.fax,array(" ",""))}
                <a class="list-item" href="tel:{$fax}">
                    {display_icon('it-file', 'svg', 'icon icon-sm icon-white')}
                    {$contacts.fax}
                </a>
            </li>
        {/if}
        {if is_set($contacts.email)}
            <li>
                <a class="list-item" href="mailto:{$contacts.email}">
                    {display_icon('it-mail', 'svg', 'icon icon-sm icon-white')}
                    {$contacts.email}
                </a>
            </li>
        {/if}
        {if is_set($contacts.pec)}
            <li>
                <a class="list-item" href="mailto:{$contacts.pec}">
                    {display_icon('it-mail', 'svg', 'icon icon-sm icon-warning')}
                    {$contacts.pec}
                </a>
            </li>
        {/if}
        {if is_set($contacts.web)}
            <li>
                <a class="list-item" href="{$contacts.web}">
                    {display_icon('it-link', 'svg', 'icon icon-sm icon-white')}
                    {def $pnkParts = $contacts.web|explode('//')}{if is_set( $pnkParts[1] )}{$pnkParts[1]}{/if}
                </a>
            </li>
        {/if}
        {if is_set($contacts.partita_iva)}
            <li>
                <a class="list-item" href="#">
                    {display_icon('it-card', 'svg', 'icon icon-sm icon-white')}
                    P.IVA {$contacts.partita_iva}
                </a>
            </li>
        {/if}
        {if is_set($contacts.codice_fiscale)}
            <li>
                <a class="list-item" href="#">
                    {display_icon('it-card', 'svg', 'icon icon-sm icon-white')}
                    C.F. {$contacts.codice_fiscale}
                </a>
            </li>
        {/if}
        {if is_set($contacts.codice_sdi)}
            <li>
                <a class="list-item" href="#">
                    {display_icon('it-card', 'svg', 'icon icon-sm icon-white')}
                    SDI {$contacts.codice_sdi}
                </a>
            </li>
        {/if}
    </ul>
</div>
{undef $contacts}
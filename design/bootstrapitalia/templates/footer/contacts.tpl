{def $contacts = $pagedata.contacts}
<div class="link-list-wrapper">
    <ul class="footer-list link-list clearfix">
        {if is_set($contacts.indirizzo)}
            <li>
                <a class="list-item" href="http://maps.google.com/maps?q={$contacts.indirizzo|urlencode}">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-pa"></use></svg>
                    {$contacts.indirizzo}
                </a>
            </li>
        {/if}

        {if is_set($contacts.telefono)}
            <li>
                {def $tel = strReplace($contacts.telefono,array(" ",""))}
                <a class="list-item" href="tel:{$tel}">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-telephone"></use></svg>
                    {$contacts.telefono}
                </a>
            </li>
        {/if}
        {if is_set($contacts.fax)}
            <li>
                {def $fax = strReplace($contacts.fax,array(" ",""))}
                <a class="list-item" href="tel:{$fax}">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-file"></use></svg>
                    {$contacts.fax}
                </a>
            </li>
        {/if}
        {if is_set($contacts.email)}
            <li>
                <a class="list-item" href="mailto:{$contacts.email}">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-mail"></use></svg>
                    {$contacts.email}
                </a>
            </li>
        {/if}
        {if is_set($contacts.pec)}
            <li>
                <a class="list-item" href="mailto:{$contacts.pec}">
                    <svg class="icon icon-sm icon-warning"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-mail"></use></svg>
                    {$contacts.pec}
                </a>
            </li>
        {/if}
        {if is_set($contacts.web)}
            <li>
                <a class="list-item" href="{$contacts.web}">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-link"></use></svg>
                    {def $pnkParts = $contacts.web|explode('//')}{if is_set( $pnkParts[1] )}{$pnkParts[1]}{/if}
                </a>
            </li>
        {/if}
        {if is_set($contacts.partita_iva)}
            <li>
                <a class="list-item" href="#">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-card"></use></svg>
                    P.IVA {$contacts.partita_iva}
                </a>
            </li>
        {/if}
        {if is_set($contacts.codice_fiscale)}
            <li>
                <a class="list-item" href="#">
                    <svg class="icon icon-sm icon-white"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-card"></use></svg>
                    C.F. {$contacts.codice_fiscale}
                </a>
            </li>
        {/if}
    </ul>
</div>
{undef $contacts}
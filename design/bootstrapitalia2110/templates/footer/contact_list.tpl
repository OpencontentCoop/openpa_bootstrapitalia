<ul class="contact-list p-0 footer-info">
    {if is_set($pagedata.contacts.indirizzo)}
        <li style="display: flex;align-items: center;">
            {display_icon('it-pa', 'svg', 'icon icon-sm icon-white', 'Address')}
            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.indirizzo|wash()}</small>
        </li>
    {/if}
    {if is_set($pagedata.contacts.telefono)}
        <li>
            {def $tel = strReplace($pagedata.contacts.telefono,array(" ",""))}
            <a style="display: flex;align-items: center;" class="text-decoration-none" href="tel:{$tel}">
                {display_icon('it-telephone', 'svg', 'icon icon-sm icon-white', 'Phone')}
                <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.telefono}</small>
            </a>
        </li>
    {/if}
    {if is_set($pagedata.contacts.fax)}
        <li>
            {def $fax = strReplace($pagedata.contacts.fax,array(" ",""))}
            <a style="display: flex;align-items: center;" class="text-decoration-none" href="tel:{$fax}">
                {display_icon('it-file', 'svg', 'icon icon-sm icon-white', 'Fax')}
                <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.fax}</small>
            </a>
        </li>
    {/if}
    {if is_set($pagedata.contacts.email)}
        <li>
            <a style="display: flex;align-items: center;" class="text-decoration-none" href="mailto:{$pagedata.contacts.email}">
                {display_icon('it-mail', 'svg', 'icon icon-sm icon-white', 'Email')}
                <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.email}</small>
            </a>
        </li>
    {/if}
    {if is_set($pagedata.contacts.pec)}
        <li>
            <a style="display: flex;align-items: center;" class="text-decoration-none" href="mailto:{$pagedata.contacts.pec}">
                {display_icon('it-mail', 'svg', 'icon icon-sm icon-warning', 'PEC')}
                <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.pec}</small>
            </a>
        </li>
    {/if}
    {if is_set($pagedata.contacts.web)}
        {def $webs = $pagedata.contacts.web|explode_contact()}
        {foreach $webs as $name => $link}
            <li>
                <a style="display: flex;align-items: center;" class="text-decoration-none" href="{$link|wash()}">
                    {display_icon('it-link', 'svg', 'icon icon-sm icon-white', 'Website')}
                    <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$name|wash()}</small>
                </a>
            </li>
        {/foreach}
        {undef $webs}
    {/if}
    {if is_set($pagedata.contacts.partita_iva)}
        <li style="display: flex;align-items: center;">
            {display_icon('it-card', 'svg', 'icon icon-sm icon-white', 'P.IVA')}
            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">P.IVA {$pagedata.contacts.partita_iva}</small>
        </li>
    {/if}
    {if is_set($pagedata.contacts.codice_fiscale)}
        <li style="display: flex;align-items: center;">
            {display_icon('it-card', 'svg', 'icon icon-sm icon-white', 'Codice fiscale')}
            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">C.F. {$pagedata.contacts.codice_fiscale}</small>
        </li>
    {/if}
    {if is_set($pagedata.contacts.codice_sdi)}
        <li>
            {display_icon('it-card', 'svg', 'icon icon-sm icon-white', 'SDI')}
            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">SDI {$pagedata.contacts.codice_sdi}</small>
        </li>
    {/if}
</ul>
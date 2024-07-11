{if openpaini('ViewSettings', 'MainChannelHelpLink', 'disabled')|eq('enabled')}
    <a class="text-muted d-block py-2 text-decoration-none"
       href="{openpaini('ViewSettings', 'MainChannelHelpLink_href', '#')|wash()}">
        {display_icon('it-info-circle', 'svg', 'icon icon-xs')}
        <small>{openpaini('ViewSettings', 'MainChannelHelpLink_text', '#')|wash()}</small>
    </a>
{/if}
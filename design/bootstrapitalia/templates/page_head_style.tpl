{def $css = array(
    'default.css'
)}
{if ezini('DebugSettings', 'DebugOutput')|eq('enabled')}
    {set $css = $css|append('debug.css')}
{/if}
{ezcss_load($css)}
{undef $css}
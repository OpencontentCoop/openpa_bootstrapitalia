{def $css = array(concat($theme,'.css'))}

{if ezini('DebugSettings', 'DebugOutput')|eq('enabled')}
    {set $css = $css|append('debug.css')}
{/if}
{ezcss_load($css)}
{undef $css}
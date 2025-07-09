{def $global_avail_translation = language_switcher('/')
     $alternates = array()
     $main_locale = ezini('RegionalSettings','Locale')
}
{if $global_avail_translation|count|gt( 1 )}
    {foreach $global_avail_translation as $siteaccess => $lang}
        {set $alternates = $alternates|append(hash(
            'is_main', cond( eq($lang.locale|wash, $main_locale|wash), true(), false()),
            'locale', $lang.locale,
            'href', $module_result.uri|lang_selector_url( $siteaccess ),
            'siteaccess', $siteaccess
        ))}
    {/foreach}
{/if}

{if $alternates|count|gt(0)}
    {foreach $alternates as $alternate}
        <link rel="alternate" hreflang="{http_locale_code($alternate.siteaccess)|wash}" href="{$alternate.href|wash}" />
        {if $alternate.is_main}
            <link rel="alternate" hreflang="x-default" href="{$alternate.href|wash}" />
        {/if}

    {/foreach}
{/if}

{undef $global_avail_translation $alternates $main_locale}
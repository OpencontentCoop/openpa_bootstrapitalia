{def $global_avail_translation = language_switcher('/')
     $languages = array()
     $uri = '/'
     $main_locale = ezini('RegionalSettings','Locale')
}

{if $global_avail_translation|count|gt( 1 )}
    {foreach $global_avail_translation as $siteaccess => $lang}
        {set $languages = $languages|append(hash(
            'is_main', cond( eq($lang.locale|wash, $main_locale|wash), true(), false()),
            'lang', $lang,
            'href', $uri|lang_selector_url( $siteaccess )
        ))}
    {/foreach}
{/if}

{if $languages|count|gt(0)}
    {foreach $languages as $language}
        <link rel="alternate"
              hreflang="{$language.lang.locale|wash|explode('-')[1]|downcase}"
              href="{$language.href|wash}" />

        {if $language.is_main}
            <link rel="alternate"
                  hreflang="x-default"
                  href="{$language.href|wash}" />
        {/if}
    {/foreach}
{/if}
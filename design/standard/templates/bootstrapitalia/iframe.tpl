{if $provider}
    <div style="height: 100%; width: 100%; display: flex; align-items: center;font-family: 'Titillium Web', Geneva,Tahoma,sans-serif;">
        <div style="text-align: center;background: #111;opacity: .7;color: #fff;width: 100%;">
            {if openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced')}
                <p>
                    {'The embedding of multimedia content is not enabled by respecting your cookie preferences.'|i18n('bootstrapitalia/cookieconsent')}<br />
                </p>
            {/if}
            <p>
                <a style="color: #fff;"
                   target="_blank"
                   rel="noopener noreferrer"
                   href="{$url|wash()}">
                    {'Watch this content on %provider'|i18n('bootstrapitalia/cookieconsent',,hash('%provider', $provider|wash()))}
                </a>
            </p>
        </div>
    </div>
{/if}

{set_defaults(hash('css', '', 'split_at', -1))}
{def $socials = hash(
    'facebook', 'Facebook',
    'twitter', 'Twitter',
    'linkedin', 'Linkedin',
    'instagram', 'Instagram',
    'youtube', 'YouTube',
    'whatsapp', 'Whatsapp',
    'telegram', 'Telegram',
    'tiktok', 'TikTok',
)}
{def $has_socials = false()}
{foreach $socials as $social => $name}
    {if is_set($pagedata.contacts[$social])}
        {set $has_socials = true()}
        {break}
    {/if}
{/foreach}
{if and($has_socials|not(), openpaini('GeneralSettings','ShowRssInSocialList', 'disabled')|eq('enabled'))}
    {set $has_socials = true()}
{/if}
{if $has_socials}
<div class="it-socials {$css}">
    <span>{'Follow us'|i18n('openpa/footer')}</span>
    <ul>
        {def $social_count = 0}
        {foreach $socials as $social => $name}
        {if is_set($pagedata.contacts[$social])}
        {if $split_at|eq($social_count)}</ul><ul>{/if}
        {set $social_count = $social_count|inc()}
        <li>
            <a href="{$pagedata.contacts.[$social]}" aria-label="{$name|wash()}" target="_blank" rel="noopener noreferrer" title="{$name|wash()}">
                {if $social|eq('tiktok')}
                    <svg class="icon icon-sm align-top" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 48 48">
                        <g fill="none" fill-rule="evenodd">
                            <path fill="#00F2EA" d="M20.023 18.111v-1.703a13.17 13.17 0 0 0-1.784-.13c-7.3 0-13.239 5.94-13.239 13.24 0 4.478 2.238 8.442 5.652 10.839a13.187 13.187 0 0 1-3.555-9.014c0-7.196 5.77-13.064 12.926-13.232"/>
                            <path fill="#00F2EA" d="M20.335 37.389c3.257 0 5.914-2.591 6.035-5.82l.011-28.825h5.266a9.999 9.999 0 0 1-.17-1.825h-7.192l-.012 28.826c-.12 3.228-2.778 5.818-6.034 5.818a6.006 6.006 0 0 1-2.805-.694 6.037 6.037 0 0 0 4.901 2.52M41.484 12.528v-1.602a9.943 9.943 0 0 1-5.449-1.62 10.011 10.011 0 0 0 5.45 3.222"/>
                            <path fill="#FF004F" d="M36.035 9.305a9.962 9.962 0 0 1-2.461-6.56h-1.927a10.025 10.025 0 0 0 4.388 6.56M18.239 23.471a6.053 6.053 0 0 0-6.046 6.046 6.05 6.05 0 0 0 3.24 5.352 6.007 6.007 0 0 1-1.144-3.526 6.053 6.053 0 0 1 6.046-6.047c.623 0 1.22.103 1.784.28v-7.343a13.17 13.17 0 0 0-1.784-.13c-.105 0-.208.006-.312.008v5.64a5.944 5.944 0 0 0-1.784-.28"/>
                            <path fill="#FF004F" d="M41.484 12.528v5.59c-3.73 0-7.185-1.193-10.007-3.218v14.617c0 7.3-5.938 13.239-13.238 13.239-2.821 0-5.437-.89-7.587-2.4a13.201 13.201 0 0 0 9.683 4.225c7.3 0 13.239-5.939 13.239-13.238V16.726a17.107 17.107 0 0 0 10.007 3.218V12.75c-.72 0-1.42-.078-2.097-.223"/>
                            <path fill="#FFF" d="M31.477 29.517V14.9a17.103 17.103 0 0 0 10.007 3.218v-5.59a10.011 10.011 0 0 1-5.449-3.223 10.025 10.025 0 0 1-4.388-6.56h-5.266L26.37 31.57c-.121 3.228-2.778 5.819-6.035 5.819a6.038 6.038 0 0 1-4.901-2.52 6.05 6.05 0 0 1-3.241-5.352 6.053 6.053 0 0 1 6.046-6.046c.622 0 1.219.102 1.784.28v-5.64c-7.156.168-12.926 6.036-12.926 13.232 0 3.48 1.352 6.648 3.555 9.014a13.16 13.16 0 0 0 7.587 2.399c7.3 0 13.238-5.939 13.238-13.239"/>
                        </g>
                    </svg>
                {else}
                    {display_icon(concat('it-', $social), 'svg', 'icon icon-sm align-top', $name|wash())}
                {/if}
                <span class="visually-hidden">{$name|wash()}</span>
            </a>
        </li>
        {/if}
        {/foreach}
        {if openpaini('GeneralSettings','ShowRssInSocialList', 'disabled')|eq('enabled')}
            <li>
                <a href="{'/feed/list'}"
                  target="_blank"
                  rel="noopener noreferrer">
                    {display_icon('it-rss', 'svg', 'icon icon-sm align-top', 'RSS')}
                    <span class="visually-hidden">RSS</span>
                </a>
            </li>
        {/if}
    </ul>
</div>
{/if}
{unset_defaults(array('css', 'split_at'))}

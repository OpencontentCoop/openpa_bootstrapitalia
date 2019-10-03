{if or(is_set($pagedata.contacts.facebook), is_set($pagedata.contacts.twitter), is_set($pagedata.contacts.linkedin), is_set($pagedata.contacts.instagram), is_set($pagedata.contacts.youtube))}
<div class="it-socials d-none d-md-flex">
    <span>{'Follow us'|i18n('openpa/footer')}</span>
    <ul>
        {if is_set($pagedata.contacts.facebook)}
        <li>
            <a href="{$pagedata.contacts.facebook}" aria-label="Facebook" target="_blank">
                {display_icon('it-facebook', 'svg', 'icon')}
            </a>
        </li>
        {/if}

        {if is_set($pagedata.contacts.twitter)}
            <li>
                <a href="{$pagedata.contacts.twitter}" aria-label="Twitter" target="_blank">
                    {display_icon('it-twitter', 'svg', 'icon')}
                </a>
            </li>
        {/if}

        {if is_set($pagedata.contacts.linkedin)}
            <li>
                <a href="{$pagedata.contacts.linkedin}" aria-label="Linkedin" target="_blank">
                    {display_icon('it-linkedin', 'svg', 'icon')}
                </a>
            </li>
        {/if}

        {if is_set($pagedata.contacts.instagram)}
            <li>
                <a href="{$pagedata.contacts.instagram}" aria-label="Instagram" target="_blank">
                    {display_icon('it-instagram', 'svg', 'icon')}
                </a>
            </li>
        {/if}

        {if is_set($pagedata.contacts.youtube)}
            <li>
                <a href="{$pagedata.contacts.youtube}" aria-label="YouTube" target="_blank">
                    {display_icon('it-youtube', 'svg', 'icon')}
                </a>
            </li>
        {/if}

    </ul>
</div>
{/if}
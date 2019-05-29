<ul class="list-inline text-left social">
    {if is_set($pagedata.contacts.facebook)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.facebook}" aria-label="Facebook" target="_blank">
                {display_icon('it-facebook', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.twitter)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.twitter}" aria-label="Twitter" target="_blank">
                {display_icon('it-twitter', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.linkedin)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.linkedin}" aria-label="Linkedin" target="_blank">
                {display_icon('it-linkedin', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.instagram)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.instagram}" aria-label="Instagram" target="_blank">
                {display_icon('it-instagram', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.youtube)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.youtube}" aria-label="YouTube" target="_blank">
                {display_icon('it-youtube', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}
</ul>
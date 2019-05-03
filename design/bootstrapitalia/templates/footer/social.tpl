<ul class="list-inline text-left social">
    {if is_set($pagedata.contacts.facebook)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.facebook}" aria-label="Facebook" target="_blank">
                <svg class="icon icon-sm icon-white align-top"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-facebook" ></use></svg>
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.twitter)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.twitter}" aria-label="Twitter" target="_blank">
                <svg class="icon icon-sm icon-white align-top"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-twitter" ></use></svg>
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.linkedin)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.linkedin}" aria-label="Linkedin" target="_blank">
                <svg class="icon icon-sm icon-white align-top"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-linkedin" ></use></svg>
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.instagram)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.instagram}" aria-label="Instagram" target="_blank">
                <svg class="icon icon-sm icon-white align-top"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-instagram" ></use></svg>
            </a>
        </li>
    {/if}

    {if is_set($pagedata.contacts.youtube)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$pagedata.contacts.youtube}" aria-label="YouTube" target="_blank">
                <svg class="icon icon-sm icon-white align-top"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-youtube" ></use></svg>
            </a>
        </li>
    {/if}
</ul>
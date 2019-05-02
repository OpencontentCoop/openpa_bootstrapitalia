{if or(is_set($pagedata.contacts.facebook), is_set($pagedata.contacts.twitter), is_set($pagedata.contacts.linkedin), is_set($pagedata.contacts.instagram), is_set($pagedata.contacts.youtube))}
<div class="it-socials d-none d-md-flex">
    <span>Seguici su</span>
    <ul>
        {if is_set($pagedata.contacts.facebook)}
        <li>
            <a href="{$pagedata.contacts.facebook}" aria-label="Facebook" target="_blank">
                <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-facebook" ></use></svg>
            </a>
        </li>
        {/if}

        {if is_set($pagedata.contacts.twitter)}
            <li>
                <a href="{$pagedata.contacts.twitter}" aria-label="Twitter" target="_blank">
                    <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-twitter" ></use></svg>
                </a>
            </li>
        {/if}

        {if is_set($pagedata.contacts.linkedin)}
            <li>
                <a href="{$pagedata.contacts.linkedin}" aria-label="Linkedin" target="_blank">
                    <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-linkedin" ></use></svg>
                </a>
            </li>
        {/if}

        {if is_set($pagedata.contacts.instagram)}
            <li>
                <a href="{$pagedata.contacts.instagram}" aria-label="Instagram" target="_blank">
                    <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-instagram" ></use></svg>
                </a>
            </li>
        {/if}

        {if is_set($pagedata.contacts.youtube)}
            <li>
                <a href="{$pagedata.contacts.youtube}" aria-label="YouTube" target="_blank">
                    <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-youtube" ></use></svg>
                </a>
            </li>
        {/if}

    </ul>
</div>
{/if}
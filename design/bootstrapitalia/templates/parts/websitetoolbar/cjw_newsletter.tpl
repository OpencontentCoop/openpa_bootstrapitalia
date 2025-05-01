    {* icon for websitetoolbar to access newsletter index *}
{if and(fetch( 'user', 'has_access_to', hash( 'module', 'newsletter', 'function', 'index' ) ), ezmodule('newsletter','subscribe'))}
    <li>
        <a class="list-item left-icon" href="{'newsletter/index'|ezurl(no)}" title="{'Newsletter dashboard'|i18n( 'cjw_newsletter/index' )}">
            <i aria-hidden="true" class="fa fa-paper-plane"></i>
            Newsletter dashboard
        </a>
    </li>
{/if}
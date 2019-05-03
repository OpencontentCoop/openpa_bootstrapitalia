{* icon for websitetoolbar to access newsletter index *}
{def $cjw_newsletter_access = fetch( 'user', 'has_access_to', hash( 'module', 'newsletter', 'function', 'index' ) )}
{if $cjw_newsletter_access}
    <li>
        <a class="list-item left-icon" href="{'newsletter/index'|ezurl(no)}" title="{'Newsletter dashboard'|i18n( 'cjw_newsletter/index' )}">
            <i class="fa fa-paper-plane"></i>
            Newsletter dashboard
        </a>
    </li>
{/if}
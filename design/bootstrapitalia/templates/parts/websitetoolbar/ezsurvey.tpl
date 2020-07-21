{* icon for websitetoolbar to access survey index *}
{if and(fetch( 'user', 'has_access_to', hash( 'module', 'survey', 'function', 'administration' ) ), ezmodule('survey','list'))}
    <li>
        <a class="list-item left-icon" href="{'survey/list'|ezurl(no)}" title="{"Survey list"|i18n('survey')}">
            <i class="fa fa-list-alt"></i>
            {"Survey list"|i18n('survey')}
        </a>
    </li>
{/if}
<form action={concat($module.functions.edit.uri,"/",$userID)|ezurl} method="post" name="Edit">
    <h1>{"User profile"|i18n("design/ocbootstrap/user/edit")}</h1>
    <input type="hidden" name="ContentObjectLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />

    <div class="row mb-5">
        <div class="col col-md-6">
            <dl class="row">
                <dt class="col-sm-3">{"Username"|i18n("design/ocbootstrap/user/edit")}</dt>
                <dd class="col-sm-9">{$userAccount.login|wash}</dd>
                <dt class="col-sm-3">{"Email"|i18n("design/ocbootstrap/user/edit")}</dt>
                <dd class="col-sm-9">{$userAccount.email|wash(email)}</dd>
                <dt class="col-sm-3">{"Name"|i18n("design/ocbootstrap/user/edit")}</dt>
                <dd class="col-sm-9">{$userAccount.contentobject.name|wash}</dd>
            </dl>

            <input class="btn btn-warning" type="submit" name="EditButton"
                   value="{'Edit profile'|i18n('design/ocbootstrap/user/edit')}"/>
            {if ezmodule( 'userpaex' )}
                <a class="btn btn-info"
                   href="{concat("userpaex/password/",$userID)|ezurl(no)}">{'Change password'|i18n('design/ocbootstrap/user/edit')}</a>
            {else}
                <input class="btn btn-info" type="submit" name="ChangePasswordButton"
                       value="{'Change password'|i18n('design/ocbootstrap/user/edit')}"/>
            {/if}
        </div>
    </div>
</form>

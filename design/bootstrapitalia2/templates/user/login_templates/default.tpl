<h1 class='text-center title pb-3'>
    {if ezini_hasvariable(concat('LoginTemplate_', $login_module_setting), 'Title', 'app.ini')}
        {ezini(concat('LoginTemplate_', $login_module_setting), 'Title', 'app.ini')|wash()}
    {else}
        {"Login"|i18n("design/ocbootstrap/user/login")}
    {/if}
</h1>

{if ezini_hasvariable(concat('LoginTemplate_', $login_module_setting), 'Text', 'app.ini')}
    <p class="text-center" style="margin-bottom: 20px">{ezini(concat('LoginTemplate_', $login_module_setting), 'Text', 'app.ini')|wash()}</p>
{/if}

{if $User:warning.bad_login}
    <div class="alert alert-danger text-start py-3">
        <p><strong>{"Could not login"|i18n("design/ocbootstrap/user/login")}</strong></p>
        <p>{"A valid username and password is required to login."|i18n("design/ocbootstrap/user/login")}</p>
    </div>
{/if}

{if $site_access.allowed|not}
    <div class="alert alert-danger text-start py-3">
        <p><strong>{"Access not allowed"|i18n("design/ocbootstrap/user/login")}</strong></p>
        <p>{"You are not allowed to access %1."|i18n("design/ocbootstrap/user/login",,array($site_access.name))}</p>
    </div>
{/if}

<form style="max-width: 400px;margin: 0 auto;" class="validate-form border px-4 pt-5 pb-4 rounded bg-white" method="post" action='{"/user/login/"|ezurl(no)}' name="loginform">
    <div class='form-group'>
        <div class='controls with-icon-over-input'>
            <input type="text" autofocus="" autocomplete="off" name="Login"
                   placeholder="{"Username"|i18n("design/ocbootstrap/user/login",'User name')}" class="form-control"
                   data-rule-required="true" value="{$User:login|wash}">
            <i class='icon-user text-muted'></i>
        </div>
    </div>
    <div class='form-group'>
        <div class='controls with-icon-over-input'>
            <input type="password" autocomplete="off" name="Password"
                   placeholder="{"Password"|i18n("design/ocbootstrap/user/login")}" class="form-control"
                   data-rule-required="true">
            <i class='icon-lock text-muted'></i>
        </div>
    </div>
    <button class='btn btn-lg btn-primary center-block'
            name="LoginButton">
        {if ezini_hasvariable(concat('LoginTemplate_', $login_module_setting), 'ButtonText', 'app.ini')}
            {ezini(concat('LoginTemplate_', $login_module_setting), 'ButtonText', 'app.ini')|wash()}
        {else}
            {'Login'|i18n('design/ocbootstrap/user/login','Button')}
        {/if}
    </button>

    {if and( is_set( $User:post_data ), is_array( $User:post_data ) )}
        {foreach $User:post_data as $key => $postData}
            <input name="Last_{$key|wash}" value="{$postData|wash}" type="hidden"/>
            <br/>
        {/foreach}
    {/if}
    <input type="hidden" name="RedirectURI" value="{$User:redirect_uri|wash}"/>

</form>
<div class='text-center mt-3'>
    <a class="text-decoration-none" href={'/user/forgotpassword'|ezurl}>{'Forgot your password?'|i18n( 'design/ocbootstrap/user/login' )}</a>
</div>
<div class='text-center mt-3'>
    <a class="text-decoration-none" href="https://{ezini('SiteSettings', 'SiteURL')}">
        ← {'Return to site'|i18n( 'design/ocbootstrap/collectedinfo/form' )}
    </a>
</div>

{ezscript_require(array("password-score/password.js"))}
{literal}
<script type="text/javascript">
    $(document).ready(function() {
        $('[name="Password"]').password({
            strengthMeter:false,
            message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}",
        });
    });
</script>
{/literal}
<div style="background: #eee;padding: 20px;">
{if $link}
    <p>
        {"If the email address is registered in the system, a message will be sent to you with a link that you must click to confirm that you are the right user."|i18n('bootstrapitalia/forgotpassword')}
    </p>
{else}
    {if $wrong_email}
        {*<div class="warning">
           <h2>{"There is no registered user with that email address."|i18n('design/standard/user/forgotpassword')}</h2>
        </div>*}
        <p>
            {"If the email address is registered in the system, a message will be sent to you with a link that you must click to confirm that you are the right user."|i18n('bootstrapitalia/forgotpassword')}
        </p>
    {else}
        {if $generated}
            <p>
                {"Password was successfully generated and sent to: %1"|i18n('design/standard/user/forgotpassword',,array($email))}
            </p>
        {else}
            {if $wrong_key}
                <div class="warning">
                    <h2>{"The key is invalid or has been used. "|i18n('design/standard/user/forgotpassword')}</h2>
                </div>
            {else}
                <form method="post" name="forgotpassword" action={"/user/forgotpassword/"|ezurl}>
                    <div class="maincontentheader">
                        <h1>{"Have you forgotten your password?"|i18n('design/standard/user/forgotpassword')}</h1>
                    </div>

                    <p>
                        {"If you have forgotten your password we can generate a new one for you. All you need to do is to enter your email address and we will create a new password for you."|i18n('design/standard/user/forgotpassword')}
                    </p>

                    <div class="block">
                        <label for="email">{"Email"|i18n('design/standard/user/forgotpassword')}:</label>
                        <div class="labelbreak"></div>
                        <input class="halfbox" type="text" name="UserEmail" size="40" value="{$wrong_email|wash}"/>
                    </div>

                    <div class="buttonblock">
                        <input class="button" type="submit" name="GenerateButton"
                               value="{'Generate new password'|i18n('design/standard/user/forgotpassword')}"/>
                    </div>
                </form>
            {/if}
        {/if}
    {/if}
{/if}
</div>
<div class="row mb-5">
    <div class="col-md-6 offset-md-3">
        {if $link}
            <div class="alert alert-success">
                {"If the email address is registered in the system, a message will be sent to you with a link that you must click to confirm that you are the right user."|i18n('bootstrapitalia/forgotpassword')}
            </div>
        {else}
            {if $wrong_email}
                {*<div class="alert alert-danger">
                    {"There is no registered user with that email address."|i18n('design/ocbootstrap/user/forgotpassword')}
                </div>*}
                <div class="alert alert-success">
                    {"If the email address is registered in the system, a message will be sent to you with a link that you must click to confirm that you are the right user."|i18n('bootstrapitalia/forgotpassword')}
                </div>
            {else}
                {if $generated}
                    <div class="alert alert-success">
                        {"Password was successfully generated and sent to: %1"|i18n('design/ocbootstrap/user/forgotpassword',,array($email))}
                    </div>
                    <a class="btn btn-success float-right" href={"/"|ezurl(no)}>OK</a>
                {else}
                    {if $wrong_key}
                        <div class="alert alert-danger">
                            {"The key is invalid or has been used. "|i18n('design/ocbootstrap/user/forgotpassword')}
                        </div>
                        <a class="btn btn-danger float-right" href={"/"|ezurl(no)}>Indietro</a>
                    {else}
                        <form method="post" name="forgotpassword" action={"/user/forgotpassword/"|ezurl}>

                            <h1 class="long">{"Have you forgotten your password?"|i18n('design/ocbootstrap/user/forgotpassword')}</h1>
                            <p>{"If you have forgotten your password, enter your email address and we will create a new password and send it to you."|i18n('design/ocbootstrap/user/forgotpassword')}</p>

                            <div class="input-group mb-3">

                                <input autocomplete="off"
                                       placeholder="{"Email"|i18n('design/ocbootstrap/user/forgotpassword')}"
                                       class="form-control" type="text" name="UserEmail" size="40"
                                       value="{$wrong_email|wash}"/>

                                <div class="input-group-append">
                                    <input class="btn btn-primary btn-block" type="submit" name="GenerateButton"
                                           value="{'Generate new password'|i18n('design/ocbootstrap/user/forgotpassword')}"/>
                                </div>

                            </div>

                        </form>
                    {/if}
                {/if}
            {/if}
        {/if}
    </div>
</div>


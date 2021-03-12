<div class="row">
    <div class="col-12">
        <h3>{'User settings for <%user_name>'|i18n( 'design/admin/user/setting',, hash( '%user_name', $user.contentobject.name ) )|wash}</h3>

        <form name="Setting" method="post" action={concat( $module.functions.setting.uri, '/', $userID )|ezurl}>

            {if or( $max_failed_login_attempts, $failed_login_attempts )}
                <div class="alert alert-{if and( ne( $max_failed_login_attempts, 0), gt( $failed_login_attempts, $max_failed_login_attempts ) )}warning{else}success{/if}">

                    {if and( ne( $max_failed_login_attempts, 0), gt( $failed_login_attempts, $max_failed_login_attempts ) )}
                        <h5>{'Account has been locked because the maximum number of failed login attempts was exceeded.'|i18n( 'design/admin/user/setting' )|wash}</h5>
                    {/if}

                    {if or( $max_failed_login_attempts, $failed_login_attempts )}
                        <ul class="list-unstyled mb-0">
                            <li>{'Maximum number of failed login attempts'|i18n( 'design/admin/user/setting' )}: {$max_failed_login_attempts}</li>
                            <li>
                                {'Number of failed login attempts for this user'|i18n( 'design/admin/user/setting' )}: {$failed_login_attempts}
                                {if $failed_login_attempts}
                                    <button class="btn btn-warning btn-xs" type="submit" name="ResetFailedLoginButton">{'Reset'|i18n( 'design/admin/user/setting' )}</button>
                                {/if}
                            </li>
                        </ul>
                    {/if}
                </div>
            {/if}

            <div class="form-group form-check">
                <input type="checkbox" name="is_enabled" {if $userSetting.is_enabled}checked="checked"{/if}
                       class="form-check-input"
                       title="{'Use this checkbox to enable or disable the user account.'|i18n( 'design/admin/user/setting' )}"/>
                <label class="form-check-label">
                    {'Enable user account'|i18n( 'design/admin/user/setting' )}:
                </label>
            </div>

            <div class="clearfix">
                <button class="btn btn-lg btn-primary float-right" type="submit"
                        name="UpdateSettingButton">{'OK'|i18n( 'design/admin/user/setting' )}</button>
                <button class="btn btn-lg btn-dark float-left" type="submit"
                        name="CancelSettingButton">{'Cancel'|i18n( 'design/admin/user/setting' )}</button>
            </div>

        </form>
    </div>
</div>
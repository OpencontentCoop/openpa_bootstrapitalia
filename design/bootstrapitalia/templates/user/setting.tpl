<div class="row">
    <div class="col-12">
        {if fetch(user, has_access_to, hash( 'module', 'switch', 'function', 'user' ) )}
            <p class="pull-right pull-end">
                <a class="btn btn-outline-primary"
                   href="{concat('/switch/user/', $user.login)|ezurl(no)}">Impersona utente</a></p>
        {/if}
        <h3>
            {'User settings for <%user_name>'|i18n( 'design/admin/user/setting',, hash( '%user_name', $user.contentobject.name ) )|wash}
        </h3>
    </div>
</div>
<div class="row">
    <div class="col-12">
        <form name="Setting" method="post" action={concat( $module.functions.setting.uri, '/', $userID )|ezurl}>

            {if or( $max_failed_login_attempts, $failed_login_attempts )}
                <div class="alert alert-{if and( ne( $max_failed_login_attempts, 0), gt( $failed_login_attempts, $max_failed_login_attempts ) )}warning{else}success{/if}">

                    {if and( ne( $max_failed_login_attempts, 0), gt( $failed_login_attempts, $max_failed_login_attempts ) )}
                        <h5>{'Account has been locked because the maximum number of failed login attempts was exceeded.'|i18n( 'design/admin/user/setting' )|wash}</h5>
                    {/if}

                    {if or( $max_failed_login_attempts, $failed_login_attempts )}
                        <ul class="list-unstyled mb-0">
                            <li>{'Maximum number of failed login attempts'|i18n( 'design/admin/user/setting' )}
                                : {$max_failed_login_attempts}</li>
                            <li>
                                {'Number of failed login attempts for this user'|i18n( 'design/admin/user/setting' )}
                                : {$failed_login_attempts}
                                {if $failed_login_attempts}
                                    <button class="btn btn-warning btn-xs" type="submit"
                                            name="ResetFailedLoginButton">{'Reset'|i18n( 'design/admin/user/setting' )}</button>
                                {/if}
                            </li>
                        </ul>
                    {/if}
                </div>
            {/if}

            <div class="form-group form-check">
                <input type="checkbox" name="is_enabled" {if $userSetting.is_enabled}checked="checked"{/if}
                       id="user-toogle"
                       class="form-check-input"
                       title="{'Use this checkbox to enable or disable the user account.'|i18n( 'design/admin/user/setting' )}"/>
                <label class="form-check-label" for="user-toogle">
                    {'Enable user account'|i18n( 'design/admin/user/setting' )}
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

{def $history_count = fetch('bootstrapitalia', 'user_history_count', hash('user',$userID ))
     $limit = 15
     $offset = cond(ezhttp_hasvariable( 'offset', 'get' ), ezhttp( 'offset', 'get' ), 0)}
{if $offset|lt(0)}
    {set $offset = 0}
{/if}
{if $history_count|gt(0)}
    {def $history = fetch('bootstrapitalia', 'user_history', hash('user', $userID, 'limit', $limit, 'offset', $offset ))}
<hr class="my-5">
<div class="mb-4">
    <h3>{'Last actions'|i18n( 'cjw_newsletter/index' )}</h3>
    <table class="table table-striped" cellspacing="0">
        <thead>
        <tr>
            <th>{'Name'|i18n( 'design/admin/class/classlist' )}</th>
            <th>{'Class'|i18n( 'design/standard/ezoe' )}</th>
            <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
            <th>{'Status'|i18n( 'design/ocbootstrap/content/history' )}</th>
            <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
            <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
        </tr>
        </thead>
        <tbody>
        {foreach $history as $version}
            <tr>
                <td><a href="{concat( '/content/versionview/', $version.contentobject_id, '/', $version.version, '/', $version.initial_language.locale )|ezurl(no)}" target="_blank">{$version.name} <i class="fa fa-external-link"></i> </a></td>
                <td style="white-space:nowrap">{$version.contentobject.class_name|wash()}</td>
                <td class="text-center">{$version.version}</td>
                <td>{$version.status|choose( 'Draft'|i18n( 'design/ocbootstrap/content/history' ), 'Published'|i18n( 'design/ocbootstrap/content/history' ), 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Archived'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ), 'Untouched draft'|i18n( 'design/ocbootstrap/content/history' ) )}</td>
                <td style="white-space:nowrap">{$version.created|l10n( shortdatetime )}</td>
                <td style="white-space:nowrap">{$version.modified|l10n( shortdatetime )}</td>
            </tr>
        {/foreach}
        </tbody>
        {if $history_count|gt($limit)}
            <tfoot>
                <tr>
                    <td colspan="6">
                        <div class="d-flex justify-content-between">
                        {if $offset|gt(0)}
                            <a href="{concat( $module.functions.setting.uri, '/', $userID, '?offset=', sub($offset, $limit) )|ezurl(no)}"><i class="fa fa-arrow-left"></i></a>
                        {else}
                            <i class="fa fa-arrow-left text-light"></i>
                        {/if}

                            <span>{'Found %count results'|i18n('openpa/search',,hash('%count', $history_count))}</span>

                        {if sum($limit, $offset)|lt($history_count)}
                            <a href="{concat( $module.functions.setting.uri, '/', $userID, '?offset=', sum($limit, $offset) )|ezurl(no)}"><i class="fa fa-arrow-right"></i></a>
                        {else}
                            <i class="fa fa-arrow-right text-light"></i>
                        {/if}
                        </div>
                    </td>
                </tr>
            </tfoot>
        {/if}
    </table>
</div>
{/if}
{ezscript_require(array(
  "password-score/password-score.js",
  "password-score/password-score-options.js",
  "password-score/bootstrap-strength-meter.js",
  "password-score/password.js"
))}
{ezcss_require(array('password-score/password.css'))}

<form action="{concat($module.functions.password.uri,"/",$userID)|ezurl(no)}" method="post" name="Password">
    <div class="row mb-3">

    <div class="col-md-8 offset-md-2">

        <h1>{"Change password for user"|i18n("mbpaex/userpaex")}</h1>
        
        {if $message}
            {if or($oldPasswordNotValid,$newPasswordNotMatch,$newPasswordNotValidate,$newPasswordMustDiffer)}
                {if $oldPasswordNotValid}
                    <div class="alert alert-warning">
                        {'Please retype your old password.'|i18n('mbpaex/userpaex')}
                    </div>
                {/if}
                {if $newPasswordNotMatch}
                    <div class="alert alert-warning">
                        {"Password didn't match, please retype your new password."|i18n('mbpaex/userpaex')}
                    </div>
                {/if}
                {if $newPasswordNotValidate}
                    <div class="alert alert-warning">
                    {if and(is_set($newPasswordValidationMessage), $newPasswordValidationMessage|ne(''))}
                        {$newPasswordValidationMessage}
                    {else}
                        {"Password didn't validate, please retype your new password."|i18n('mbpaex/userpaex')}
                    {/if}
                    </div>
                {/if}
                {if $newPasswordMustDiffer}
                    <div class="alert alert-warning">
                        {"New password must be different from the old one. Please choose another password."|i18n('mbpaex/userpaex')}
                    </div>
                {/if}                    
            {else}
                <div class="feedback">
                    {'Password successfully updated.'|i18n('mbpaex/userpaex')}
                </div>
            {/if}
        {/if}
    

        {if $oldPasswordNotValid}*{/if}
        <label>{"Old password"|i18n("mbpaex/userpaex")}</label>
        <input type="password" class="form-control" name="oldPassword" size="11" value="{$oldPassword}" />


      <div class="row mt-3">
          <div class="col-md-6">
              {if or($newPasswordNotMatch,$newPasswordNotValidate)}*{/if}
              <label>{"New password"|i18n("mbpaex/userpaex")}</label>
              <input id="pwd-input" type="password" class="form-control" name="newPassword" size="11" value="{$newPassword}" />
              {include uri='design:parts/password_meter.tpl'}
          </div>
          <div class="col-md-6">
              {if or($newPasswordNotMatch,$newPasswordNotValidate)}*{/if}
              <label>{"Retype password"|i18n("mbpaex/userpaex")}</label>
              <input type="password" class="form-control" name="confirmPassword" size="11" value="{$confirmPassword}" />

          </div>
      </div>


      <div class="clearfix mt-3">
          <input class="btn btn-dark float-left" type="submit" name="CancelButton" value="{'Cancel'|i18n('mbpaex/userpaex')}" />
          <input class="btn btn-primary float-right" type="submit" name="OKButton" value="{'OK'|i18n('mbpaex/userpaex')}" />
      </div>

    </div>

    </div>

</form>

{literal}
<script type="text/javascript">
    $(document).ready(function() {
        $('#pwd-input').password({
            minLength:{/literal}{ezini('UserSettings', 'MinPasswordLength')}{literal},
            message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}",
            hierarchy: {
                '0': ['text-danger', "{/literal}{'Evaluation of complexity: bad'|i18n('ocbootstrap')}{literal}"],
                '10': ['text-danger', "{/literal}{'Evaluation of complexity: very weak'|i18n('ocbootstrap')}{literal}"],
                '20': ['text-warning', "{/literal}{'Evaluation of complexity: weak'|i18n('ocbootstrap')}{literal}"],
                '30': ['text-info', "{/literal}{'Evaluation of complexity: good'|i18n('ocbootstrap')}{literal}"],
                '40': ['text-success', "{/literal}{'Evaluation of complexity: very good'|i18n('ocbootstrap')}{literal}"],
                '50': ['text-success', "{/literal}{'Evaluation of complexity: excellent'|i18n('ocbootstrap')}{literal}"]
            }
        });
        $('[name="confirmPassword"]').password({
            strengthMeter:false,
            message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}"
        });
    });
</script>
{/literal}


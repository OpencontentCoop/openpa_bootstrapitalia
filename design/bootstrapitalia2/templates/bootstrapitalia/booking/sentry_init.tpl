{if fetch( 'user', 'current_user' ).is_logged_in|not()}
{def $sentry_script_loader = sentry_script_loader()}
{if $sentry_script_loader}
<script src="{$sentry_script_loader}" crossorigin="anonymous"></script>
<script>
  window.Sentry && Sentry.onLoad(function() {ldelim}
    Sentry.init({ldelim}
      environment: "{openpa_instance_identifier()}"
    {rdelim});
  {rdelim});
</script>
{/if}
{undef $sentry_script_loader}
{/if}

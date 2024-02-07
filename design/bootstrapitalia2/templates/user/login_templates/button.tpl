<h1 class='text-center title'>{ezini(concat('LoginTemplate_', $login_module_setting), 'Title', 'app.ini')}</h1>

{if ezini_hasvariable(concat('LoginTemplate_', $login_module_setting), 'Text', 'app.ini')}
    <p class="text-center" style="margin-bottom: 20px">{ezini(concat('LoginTemplate_', $login_module_setting), 'Text', 'app.ini')}</p>
{/if}

<div class="text-center">
    <a href="{ezini(concat('LoginTemplate_', $login_module_setting), 'LinkHref', 'app.ini')|ezurl(no)}" class="btn btn-lg btn-primary">{ezini(concat('LoginTemplate_', $login_module_setting), 'LinkText', 'app.ini')}</a>
</div>
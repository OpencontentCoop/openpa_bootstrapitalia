{def $login_layout = ezini('LoginTemplate', 'Layout', 'app.ini')}
{def $login_modules = ezini('LoginTemplate', 'LoginModules', 'app.ini')}
{def $login_modules_count = count($login_modules)}

{if ezini_hasvariable('LoginTemplate', 'LoginIntroObjectRemoteId', 'app.ini')}
    {def $login_object = fetch(content, object, hash('remote_id', ezini('LoginTemplate', 'LoginIntroObjectRemoteId', 'app.ini')))}
    {if and($login_object, $login_object|has_attribute('layout'))}
        {attribute_view_gui attribute=$login_object|attribute('layout')}
    {/if}
{/if}

{if $login_layout|eq('column')}

    {foreach $login_modules as $login_module}
        <div class="row">
            <div class="col-md-8 offset-md-2 col-lg-6 offset-lg-3">
                {def $login_module_parts = $login_module|explode('|')}
                {include uri=concat('design:user/login_templates/', $login_module_parts[0], '.tpl') login_module_setting=cond(is_set($login_module_parts[1]), $login_module_parts[1], $login_module_parts[0])}
                {undef $login_module_parts}
            </div>
        </div>
        {delimiter}
            <hr/>
        {/delimiter}
    {/foreach}

{elseif $login_layout|eq('row')}
    {def $row_span = 12|div($login_modules_count)|ceil()}
    <div class="row">
        {foreach $login_modules as $login_module}
            {def $login_module_parts = $login_module|explode('|')}
            <div class="col-md-{$row_span} mb-4">
                {include uri=concat('design:user/login_templates/', $login_module_parts[0], '.tpl') login_module_setting=cond(is_set($login_module_parts[1]), $login_module_parts[1], $login_module_parts[0])}
            </div>
            {undef $login_module_parts}
        {/foreach}
    </div>
    {undef $row_span}
{/if}

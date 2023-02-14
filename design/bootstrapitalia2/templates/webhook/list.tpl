<section class="hgroup">
    <h1>{'Webhook list'|i18n( 'extension/ocwebhookserver' )}</h1>
</section>

<div class="row">
    <div class="col-sm-4">
        <p>
            {if $webhook_count|gt(10)}
            {switch match=$limit}
            {case match=25}
                <a class="btn btn-xs btn-info" href={'/user/preferences/set/webhooks_limit/10/'|ezurl} title="{'Show 10 items per page.'|i18n( 'design/admin/node/view/full' )}">10</a>
                <span class="btn btn-xs btn-light current">25</span>
                <a class="btn btn-xs btn-info" href={'/user/preferences/set/webhooks_limit/50/'|ezurl} title="{'Show 50 items per page.'|i18n( 'design/admin/node/view/full' )}">50</a>
            {/case}

            {case match=50}
                <a class="btn btn-xs btn-info" href={'/user/preferences/set/webhooks_limit/10/'|ezurl} title="{'Show 10 items per page.'|i18n( 'design/admin/node/view/full' )}">10</a>
                <a class="btn btn-xs btn-info" href={'/user/preferences/set/webhooks_limit/25/'|ezurl} title="{'Show 25 items per page.'|i18n( 'design/admin/node/view/full' )}">25</a>
                <span class="btn btn-xs btn-light current">50</span>
            {/case}

            {case}
                <span class="btn btn-xs btn-light current">10</span>
                <a class="btn btn-xs btn-info" href={'/user/preferences/set/webhooks_limit/25/'|ezurl} title="{'Show 25 items per page.'|i18n( 'design/admin/node/view/full' )}">25</a>
                <a class="btn btn-xs btn-info" href={'/user/preferences/set/webhooks_limit/50/'|ezurl} title="{'Show 50 items per page.'|i18n( 'design/admin/node/view/full' )}">50</a>
            {/case}

            {/switch}
            {/if}
        </p>
    </div>
    <div class="{if $webhook_count|le(10)}offset-sm-4 {/if}col-sm-8 text-right">
        <p>
            <a class="btn btn-xs btn-success" href="{'webhook/edit/new'|ezurl(no)}">{"Add new webhook"|i18n( 'extension/ocwebhookserver' )}</a>
        </p>
    </div>
</div>

<hr />

<div class="row">
    <div class="col">
        {if $webhook_count|eq(0)}
            {"No webhooks"|i18n( 'extension/ocwebhookserver' )}
        {else}
            <form method="post" action="{$uri|ezurl(no)}" style="background: #fff">

                <table class="table table-hover">
                    <thead>
                    <tr>
                        <th width="1"></th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th class="text-center" width="1"><i class="fa fa-clock-o"></i></th>
                        <th class="text-center" width="1"><i class="fa fa-refresh"></i></th>
                    </tr>
                    </thead>
                    <tbody>
                    {foreach $webhooks as $webhook}
                        <tr class="{if $webhook.enabled|ne(1)}table-secondary{/if}">
                            <th>{$webhook.id|wash()}</th>
                            <td>{$webhook.name|wash()}</td>
                            <td>
                                <dl class="row">
                                    <dt class="col-sm-3">{"Endpoint"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                    <dd class="col-sm-9"><code>{$webhook.method|upcase|wash()} {$webhook.url|urldecode|wash()}</code></dd>
                                    {if $webhook.secret|ne('')}
                                    <dt class="col-sm-3">{"Secret"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                        <dd class="col-sm-9"><code>{$webhook.secret|wash()}</code></dd>
                                    {/if}
                                    <dt class="col-sm-3">{"Triggers"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                    <dd class="col-sm-9">{foreach $webhook.triggers as $trigger}<span class="badge badge-light">{$trigger['name']|wash()}</span>{delimiter} {/delimiter}{/foreach}</dd>
                                    {if $webhook.headers_array|count()}
                                        <dt class="col-sm-3">{"Headers"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                        <dd class="col-sm-9">
                                            {foreach $webhook.headers_array as $header}
                                                <code>{$header|wash()}</code>{delimiter}<br />{/delimiter}
                                            {/foreach}
                                        </dd>
                                    {/if}
                                </dl>
                            </td>
                            <td>
                                <button class="btn btn-xs btn-light text-nowrap" type="submit" {if $webhook.enabled|ne(1)}disabled="disabled"{/if} class="button" name="TestWebHook" value="{$webhook.id}"><i class="fa fa-gear"></i> {"Test"|i18n( 'extension/ocwebhookserver' )}</button>
                            </td>
                            <td>
                                {if $webhook.enabled|ne(1)}
                                    <button type="submit" class="btn btn-xs btn-success" name="EnableWebHook" value="{$webhook.id}">{"Enable"|i18n( 'extension/ocwebhookserver' )}</button>
                                {else}
                                    <button type="submit" class="btn btn-xs btn-danger" name="DisableWebHook" value="{$webhook.id}">{"Disable"|i18n( 'extension/ocwebhookserver' )}</button>
                                {/if}
                            </td>
                            <td>
                                <a class="btn btn-xs btn-light" href="{concat('webhook/logs/', $webhook.id)|ezurl(no)}">{"Logs"|i18n( 'extension/ocwebhookserver' )}</a>
                            </td>
                            <td>
                                <div class="dropdown">
                                    <button type="button" class="btn btn-xs btn-light dropdown-toggle text-nowrap" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        {"Edit"|i18n( 'extension/ocwebhookserver' )} <i class="fa fa-caret-down"></i>
                                    </button>
                                    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                                        <a class="dropdown-item" href="{concat('webhook/edit/', $webhook.id)|ezurl(no)}"><i class="fa fa-edit"></i> {"Edit"|i18n( 'extension/ocwebhookserver' )}</a>
                                        <a class="dropdown-item" onclick="return confirm('{'Are you sure you want to cancel this webhook ?'|i18n( 'extension/ocwebhookserver' )}')"
                                           href="{concat('webhook/remove/', $webhook.id)|ezurl(no)}"><i class="fa fa-trash"></i> {"Remove"|i18n( 'extension/ocwebhookserver' )}</a>
                                    </div>
                                </div>
                            </td>
                            <td class="text-center">
                                {if is_set($stats[$webhook.id]['pending'])}{$stats[$webhook.id]['pending']}{else}0{/if}
                            </td>
                            <td class="text-center">
                                {if $webhook.retry_enabled|eq(0)}NO{elseif is_set($stats[$webhook.id]['retry'])}{$stats[$webhook.id]['retry']}{else}0{/if}
                            </td>
                        </tr>
                    {/foreach}
                    </tbody>
                </table>
            </form>
        {/if}
        <div class="context-toolbar">
            {include name=navigator uri='design:navigator/google.tpl'
                     page_uri=$uri
                     item_count=$webhook_count
                     view_parameters=$view_parameters
                     item_limit=$limit}
        </div>
    </div>
</div>

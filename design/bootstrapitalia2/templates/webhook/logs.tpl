<section class="hgroup">
    <h1>
        {$webhook.name|wash()} {'Webhook logs'|i18n( 'extension/ocwebhookserver' )}
    </h1>
</section>

<div class="row">
    <div class="col-sm-4">
        <p>
            {if $job_count|gt(10)}
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
    <div class="col-sm-8 text-right">
        <p>
            <a class="btn btn-xs btn-info" href="{concat('webhook/logs/',$webhook.id)|ezurl(no)}">{"All"|i18n( 'extension/ocwebhookserver' )}</a>
            {if $status|eq(0)}
                <span class="btn btn-xs btn-light current">{"Pending"|i18n( 'extension/ocwebhookserver' )}</span>
            {else}
                <a class="btn btn-xs btn-info" href="{concat('webhook/logs/',$webhook.id, '/(status)/0')|ezurl(no)}">{"Pending"|i18n( 'extension/ocwebhookserver' )}</a>
            {/if}
            {if $status|eq(1)}
                <span class="btn btn-xs btn-light current">{"Running"|i18n( 'extension/ocwebhookserver' )}</span>
            {else}
                <a class="btn btn-xs btn-info" href="{concat('webhook/logs/',$webhook.id, '/(status)/1')|ezurl(no)}">{"Running"|i18n( 'extension/ocwebhookserver' )}</a>
            {/if}
            {if $status|eq(2)}
                <span class="btn btn-xs btn-light current">{"Done"|i18n( 'extension/ocwebhookserver' )}</span>
            {else}
                <a class="btn btn-xs btn-info" href="{concat('webhook/logs/',$webhook.id, '/(status)/2')|ezurl(no)}">{"Done"|i18n( 'extension/ocwebhookserver' )}</a>
            {/if}
            {if $status|eq(4)}
                <span class="btn btn-xs btn-light current">{"Retrying"|i18n( 'extension/ocwebhookserver' )}</span>
            {else}
                <a class="btn btn-xs btn-info" href="{concat('webhook/logs/',$webhook.id, '/(status)/4')|ezurl(no)}">{"Retrying"|i18n( 'extension/ocwebhookserver' )}</a>
            {/if}
            {if $status|eq(3)}
                <span class="btn btn-xs btn-light current">{"Failed"|i18n( 'extension/ocwebhookserver' )}</span>
            {else}
                <a class="btn btn-xs btn-info" href="{concat('webhook/logs/',$webhook.id, '/(status)/3')|ezurl(no)}">{"Failed"|i18n( 'extension/ocwebhookserver' )}</a>
            {/if}
        </p>
    </div>
</div>

<hr />

<div class="row">
    <div class="col">
        {if $job_count|eq(0)}
            {"No jobs"|i18n( 'extension/ocwebhookserver' )}
        {else}
            <form name="logsform" method="post" action="{concat($uri, $uri_parameters)|ezurl(no)}" style="background: #fff">
                <table class="table table-sm">
                    <thead class="thead-dark">
                    <tr>
                        {if or($status|eq(3), $status|eq(4))}
                        <th width="1"></th>
                        {/if}
                        <th width="1">{"ID"|i18n( 'extension/ocwebhookserver' )}</th>
                        <th>{"Status"|i18n( 'extension/ocwebhookserver' )}</th>
                        <th style="white-space: nowrap">{"Response code"|i18n( 'extension/ocwebhookserver' )}</th>
                        <th>{"Details"|i18n( 'extension/ocwebhookserver' )}</th>
                        <th>{"Payload"|i18n( 'extension/ocwebhookserver' )}</th>
                        <th style="white-space: nowrap">{"Response"|i18n( 'extension/ocwebhookserver' )}</th>
                    </tr>
                    </thead>

                    <tbody>
                    {foreach $jobs as $job}
                        <tr class="{if $job.execution_status|eq(2)}table-success{elseif $job.execution_status|eq(3)}table-danger{elseif $job.execution_status|eq(1)}table-warning{elseif $job.execution_status|eq(4)}table-info{/if}">
                            {if or($status|eq(3), $status|eq(4))}
                                <th width="1" class="align-middle">
                                    <input name="Jobs[]" type="checkbox" value="{$job.id|wash()}" />
                                </th>
                            {/if}
                            <th class="align-middle">{$job.id|wash()}</th>
                            <td class="align-middle">
                                {if $job.execution_status|eq(0)}
                                    {"Pending"|i18n( 'extension/ocwebhookserver' )}
                                {elseif $job.execution_status|eq(1)}
                                    {"Running"|i18n( 'extension/ocwebhookserver' )}
                                {elseif $job.execution_status|eq(2)}
                                    {"Done"|i18n( 'extension/ocwebhookserver' )}
                                {elseif $job.execution_status|eq(3)}
                                    {"Failed"|i18n( 'extension/ocwebhookserver' )}
                                    <p><a href="{concat('webhook/job/',$job.id,'/retry')|ezurl(no)}" class="btn btn-danger btn-xs">{"Retry"|i18n( 'extension/ocwebhookserver' )}</a></p>
                                {elseif $job.execution_status|eq(4)}
                                    {"Retrying..."|i18n( 'extension/ocwebhookserver' )}
                                    {def $failures = $job.failures}
                                    {if $failures|count()}
                                    <ol style="font-size: .875em">
                                        {foreach $failures as $failure}
                                            <li title="#{$failure.id|wash()}">
                                                {$failure.executed_at|l10n( shortdatetime )}: {if $failure.response_status}{$failure.response_status|wash()}{else}?{/if}
                                            </li>
                                        {/foreach}
                                        {if $job.next_retry}
                                            <li>
                                                <em>{"Next retry:"|i18n( 'extension/ocwebhookserver' )} {$job.next_retry|l10n( shortdatetime )}</em>
                                            </li>
                                        {/if}
                                    </ol>
                                    {/if}
                                    {if $job.next_retry}
                                        <p>
                                            <a href="{concat('webhook/job/',$job.id, '/stop')|ezurl(no)}" class="btn btn-danger btn-xs">{"Stop retry"|i18n( 'extension/ocwebhookserver' )}</a>
                                            <a href="{concat('webhook/job/',$job.id, '/retry')|ezurl(no)}" class="btn btn-danger btn-xs">{"Retry now"|i18n( 'extension/ocwebhookserver' )}</a>
                                        </p>
                                    {/if}
                                    {undef $failures}
                                {/if}
                            </td>
                            <td class="text-center align-middle">{$job.response_status|wash()}</td>
                            <td>
                                <dl>
                                    <dt>{"Trigger"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                    <dd class="m-0">{$job.trigger.name|wash()}</dd>

                                    <dt>{"Created at"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                    <dd class="m-0">{$job.created_at|l10n( datetime )}</dd>

                                    <dt>{"Executed at"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                    <dd class="m-0">{if $job.executed_at|int()|gt(0)}{$job.executed_at|l10n( datetime )}{/if}</dd>

                                    <dt>{"Executor"|i18n( 'extension/ocwebhookserver' )}:</dt>
                                    <dd class="m-0">{if $job.hostname}{$job.hostname|wash()} ({$job.pid|wash()}){/if}</dd>
                                </dl>

                            </td>
                            <td class="align-middle">
                                <button type="button" class="btn btn-secondary btn-xs" data-bs-toggle="modal" data-bs-target="#payloadModal-{$job.id}">
                                    Show payload
                                </button>
                                <div class="modal fade" id="payloadModal-{$job.id}" tabindex="-1" role="dialog" aria-labelledby="payloadModal-{$job.id}">
                                    <div class="modal-dialog modal-lg" role="document">
                                        <div class="modal-content">
                                            <pre><code class="json">{$job.serialized_payload|json_encode()|wash()}</code></pre>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td class="align-middle">
                                {if $job.execution_status|gt(1)}
                                <button type="button" class="btn btn-secondary btn-xs" data-bs-toggle="modal" data-bs-target="#responseModal-{$job.id}">
                                    Show response
                                </button>
                                <div class="modal fade" id="responseModal-{$job.id}" tabindex="-1" role="dialog" aria-labelledby="responseModal-{$job.id}">
                                    <div class="modal-dialog modal-lg" role="document">
                                        <div class="modal-content">
                                            <pre><code class="json">{$job.response_headers|wash()}</code></pre>
                                        </div>
                                    </div>
                                </div>
                                {/if}
                            </td>
                        </tr>
                    {/foreach}
                    </tbody>
                    {if or($status|eq(3), $status|eq(4))}
                        <tfoot>
                            <tr>
                                <td colspan="7">
                                    <a href="#" class="btn btn-light btn-sm" onclick="ezjs_toggleCheckboxes( document.logsform, 'Jobs[]' ); return false;">
                                        Toggle selection{*'Toggle selection'|i18n( 'design/ocbootstrap/content/history' )*}
                                    </a>
                                    {if $status|eq(3)}
                                        <button type="submit" class="btn btn-danger btn-sm" name="BatchRetry">Retry selected</button>
                                        <input type="hidden" name="BatchAction" value="Retry" />
                                    {elseif $status|eq(4)}
                                        <button type="submit" class="btn btn-danger btn-sm" name="BatchStopRetry">Stop retry selected</button>
                                        <input type="hidden" name="BatchAction" value="StopRetry" />
                                    {/if}
                                </td>
                            </tr>
                        </tfoot>
                    {/if}
                </table>
            </form>
        {/if}
        <div class="context-toolbar">
            {include name=navigator uri='design:navigator/google.tpl'
            page_uri=$uri
            item_count=$job_count
            view_parameters=$view_parameters
            item_limit=$limit}
        </div>
    </div>

</div>
{ezscript_require( 'tools/ezjsselection.js' )}
{literal}
<script>
    $(document).ready(function () {

        var library = {};
        library.json = {
            replacer: function(match, pIndent, pKey, pVal, pEnd) {
                var key = '<span class=json-key>';
                var val = '<span class=json-value>';
                var str = '<span class=json-string>';
                var r = pIndent || '';
                if (pKey)
                    r = r + key + pKey.replace(/[": ]/g, '') + '</span>: ';
                if (pVal)
                    r = r + (pVal[0] == '"' ? str : val) + pVal + '</span>';
                return r + (pEnd || '');
            },
            prettyPrint: function(obj) {
                var jsonLine = /^( *)("[\w]+": )?("[^"]*"|[\w.+-]*)?([,[{])?$/mg;
                return JSON.stringify(obj, null, 3)
                    .replace(/&/g, '&amp;').replace(/\\"/g, '&quot;')
                    .replace(/</g, '&lt;').replace(/>/g, '&gt;')
                    .replace(jsonLine, library.json.replacer);
            }
        };


        $('code.json').each(function () {
            try {
                var tmpData = JSON.parse($(this).text());
                $(this).html(library.json.prettyPrint(tmpData));
            } catch (e) {
                $(this).parent().css({'white-space':'normal'});
                console.log(e);
            }
        });
    });
</script>
<style>
    pre {
        background-color: #f8f8ff;
        border: 1px solid #C0C0C0;
        padding: 5px;
        margin: 0;
        font-size: .7em;
    }
    .json-key {
        color: #A52A2A;
    }
    .json-value {
        color: #000080;
    }
    .json-string {
        color: #556b2f;
    }
</style>
{/literal}
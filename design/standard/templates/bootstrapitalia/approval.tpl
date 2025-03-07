<div class="approval">

    {if $approval_item_list_by_object}
{literal}
        <style>
            /* Messages */

            .message {
                color: #000;
                clear: both;
                line-height: 18px;
                font-size: 15px;
                padding: 8px;
                position: relative;
                margin: 8px 0;
                max-width: 85%;
                word-wrap: break-word;
            }

            .message:after {
                position: absolute;
                content: "";
                width: 0;
                height: 0;
                border-style: solid;
            }

            .metadata {
                display: inline-block;
                float: right;
                padding: 0 0 0 7px;
                position: relative;
                bottom: -4px;
                margin-top:15px
            }

            .metadata .time {
                color: rgba(0, 0, 0, .45);
                font-size: 12px;
                display: inline-block;
                line-height: 1.1;
                text-align: right;
            }

            .message:first-child {
                margin: 16px 0 8px;
            }

            .message.received {
                background: #eee;
                border-radius: 0 5px 5px 5px;
                float: left;
            }

            .message.received .metadata {
                padding: 0 0 0 16px;
            }

            .message.received:after {
                border-width: 0 10px 10px 0;
                border-color: transparent #eee transparent transparent;
                top: 0;
                left: -10px;
            }

            .message.sent {
                background: #e1ffc7;
                border-radius: 5px 0 5px 5px;
                float: right;
            }

            .message.sent:after {
                border-width: 0 0 10px 10px;
                border-color: transparent transparent transparent #e1ffc7;
                top: 0;
                right: -10px;
            }
            .conversation {
                padding: 20px 20px 0;
                margin-bottom: 5px;
            }
        </style>
{/literal}
        <h3 class="mb-4">
            <a href="{'/bootstrapitalia/approval'|ezurl(no)}"><i class="fa fa-check-circle-o "></i></a>
            {$object.name|wash()}
        </h3>
        {if $approvals_by_object.count}
                <div class="accordion">
                {foreach $approvals_by_object.queues as $i => $queue}
                    {def $approval = cond($queue.pending, $queue.pending, $queue.latest)}
                    {def $is_pending = cond($approval.status|eq(0), true(), false())}
                    {def $open = cond(or($is_pending, count($approvals_by_object.queues)|eq(1), $queue.has_unread_comments), true(), false())}
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="heading-{$queue.authorId}">
                            <button class="{if count($approvals_by_object.queues)|gt(1)}accordion-button{/if} collapsed" type="button"
                                    {if count($approvals_by_object.queues)|gt(1)}data-bs-toggle="collapse" data-bs-target="#collapse-{$queue.authorId}"{/if} aria-expanded="{if $open}true{else}false{/if}" aria-controls="collapse-{$queue.authorId}">
                                <h5>
                                    {*
                                        <span class="text-capitalize">{'version'i18n('bootstrapitalia/moderation')}</span>
                                       {$approval.version.version}

                                    <span class="text-capitalize">{$approval.version.status|choose( 'Draft'|i18n( 'design/ocbootstrap/content/history' ), 'Published'|i18n( 'design/ocbootstrap/content/history' ), 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Archived'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ), 'Untouched draft'|i18n( 'design/ocbootstrap/content/history' ) )}</span>
                                    *}
                                    {switch match=$approval.version.status}
                                        {case match=2}
                                            {if $approval.is_author}
                                                {"Awaits approval by editor"|i18n('bootstrapitalia/moderation')}
                                            {else}
                                                La versione di {$queue.author.contentobject.name|wash()} attende la tua approvazione
                                            {/if}
                                        {/case}
                                        {case match=1}
                                            {if $approval.is_author}
                                                La versione è stata approvata per la pubblicazione ed è la versione corrente
                                            {else}
                                                La versione di {$queue.author.contentobject.name|wash()} è stata approvata per la pubblicazione ed è la versione corrente
                                            {/if}
                                        {/case}
                                        {case}
                                        {if $approval.is_author}
                                            La versione è stata archiviata
                                        {else}
                                            La versione di {$queue.author.contentobject.name|wash()} è stata archiviata
                                        {/if}
                                        {/case}
                                    {/switch}
                                </h5>
                            </button>
                        </h2>
                        <div id="collapse-{$queue.authorId}" class="accordion-collapse collapse{if $open} show{/if}" role="region" aria-labelledby="heading-{$queue.authorId}">
                            <div class="accordion-body">
                                {if $queue.pending}
                                    {include uri='design:bootstrapitalia/approval/item.tpl' approval_item=$queue.pending redirect='object'}
                                {else}
                                    {include uri='design:bootstrapitalia/approval/item.tpl' approval_item=$queue.latest redirect='object'}
                                {/if}
                                <div class="row justify-content-around mt-4">
                                    <div class="col col-sm-12 col-lg-8">
                                        <div class="border rounded mx-auto">
                                    <div class="conversation clearfix">
                                        {foreach $queue.discussion as $message}
                                            <div class="message {if $message.is_creator}sent{else}received{/if}{if $message.is_unread} font-weight-bold{/if}">
                                                {$message.text|wash()|nl2br()}
                                                <span class="metadata">
                                                    <span class="time">
                                                        {$message.creator.contentobject.name|wash()} {$message.createdAt|l10n( shortdatetime )}
                                                        {if $message.approval.version.status|gt(2)}
                                                            <em style="text-transform:lowercase" class="d-block">{'version'i18n('bootstrapitalia/moderation')} {$message.approval.version.version}</em>
                                                        {/if}
                                                    </span>
                                                </span>
                                            </div>
                                        {/foreach}
                                    </div>
                                    <form method="post" action="{concat('/bootstrapitalia/approval/version/', $queue.latest.contentObjectVersionId, '/comment?redirect=object')|ezurl(no)}" class="clearfix mt-5">
                                        <div class="form-group m-0 border-top">
                                            <div class="input-group">
                                                <label class="d-none" for="input-group-{$queue.authorId}">{'Add Comment'|i18n('design/admin/collaboration/handler/view/full/ezapprove')}</label>
                                                <input type="text" class="form-control border-0" id="input-group-{$queue.authorId}" placeholder="{'Add Comment'|i18n('design/admin/collaboration/handler/view/full/ezapprove')}" name="Comment">
                                                <div class="input-group-append">
                                                    <button class="btn btn-primary rounded-0" type="submit" name="AddCommentButton" id="button-{$queue.authorId}">{'Send'|i18n('design/standard/content/tipafriend')}</button>
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                    {undef $approval $is_pending $open}
            {/foreach}
            </div>

            <div>
                <table class="table my-4" cellspacing="0">
                    <thead>
                    <tr>
                        <th width="1"></th>
                        <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                        <th width="1">{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                        <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    {foreach $approvals_by_object.timeline as $item}
                        <tr{if or($item.is_unread, $item.is_creator)} class="bg-light bg-opacity-{if $item.is_unread}75 font-weight-bold{else}50{/if}"{/if}>
                            <td style="vertical-align:middle" width="1">
                                {if $item.type|eq('ocmoderation_comment')}<i class="fa fa-comment"></i>{/if}
                                {if $item.type|eq('ocmoderation_approved')}<i class="fa fa-check"></i>{/if}
                                {if array('ocmoderation_rejected', 'ocmoderation_archived', 'ocmoderation_modified', 'ocmoderation_discard')|contains($item.type)}<i class="fa fa-times"></i>{/if}
                                {if $item.type|eq('ocmoderation_created')}<i class="fa fa-history"></i>{/if}
                            </td>
                            <td style="vertical-align:middle;white-space:nowrap">{$item.creator.contentobject.name|wash()}</td>
                            <td style="vertical-align:middle;white-space:nowrap;text-align:center">
                                {*<a href="{concat('/bootstrapitalia/approval/version/', $item.approval.contentObjectVersionId)|ezurl(no)}">{$item.approval.version.version}</a>*}
                                {$item.approval.version.version}
                            </td>
                            <td style="vertical-align:middle;white-space:nowrap">{$item.createdAt|l10n( shortdatetime )}</td>
                            <td style="vertical-align:middle">
                                {switch match=$item.type}
                                {case match='ocmoderation_created'}
                                {'Request for approval'|i18n( 'bootstrapitalia/moderation' )} {'version'i18n('bootstrapitalia/moderation')} {$item.approval.version.version}
                                {/case}
                                {case match='ocmoderation_approved'}
                                {'The version has been approved'|i18n( 'bootstrapitalia/moderation' )}
                                {/case}
                                {case match='ocmoderation_rejected'}
                                {'The version was rejected'|i18n( 'bootstrapitalia/moderation' )}
                                {/case}
                                {case match='ocmoderation_archived'}
                                {'The version was archived following the publication of version %id'|i18n( 'bootstrapitalia/moderation',, hash('%id', $item.archivedByVersion) )}
                                {/case}
                                {case match='ocmoderation_modified'}
                                {'The version was archived following the request approval of version %id'|i18n( 'bootstrapitalia/moderation',, hash('%id', $item.archivedByVersion) )}
                                {/case}
                                {case match='ocmoderation_discard'}
                                {'The version was discard by creator'|i18n( 'bootstrapitalia/moderation' )}
                                {/case}
                                {case}{/case}
                                {/switch}
                            </td>
                        </tr>
                    {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}



    {elseif $approval_item}

        <h3 class="mb-4">
            <a href="{'/bootstrapitalia/approval'|ezurl(no)}"><i class="fa fa-check-circle-o "></i></a>
            {$approval_item.object.name|wash()}
            <span class="btn btn-outline-secondary btn-xs px-2 py-1 ml-2 ms-2">{'version'i18n('bootstrapitalia/moderation')} {$approval_item.version.version}</span>
        </h3>

        {if $approval_item.is_author|not()}
            <h4>{$approval_item.author.contentobject.name|wash()}</h4>
        {/if}

        {include uri='design:bootstrapitalia/approval/item.tpl'}
        {include uri='design:bootstrapitalia/approval/history.tpl'}
{*        {include uri='design:bootstrapitalia/approval/comment_form.tpl'}*}

    {else}

        <h2 class="mt-5 mb-4"><i class="fa fa-check-circle-o "></i> {'Approval dashboard'|i18n('bootstrapitalia/moderation')}</h2>

        <div class="clearfix mt-4 mb-4 text-center">
            <form action="{'bootstrapitalia/approval/'|ezurl(no)}" method="post">
            <div class="input-group mb-3 justify-content-center">
                <button class="border border-secondary btn btn-md {if $current_filters.status|eq(-1)}btn-secondary{else}btn-outline-secondary{/if}" style="box-shadow:none;" name="ByStatus" type="submit" value="-1">{'All'|i18n('bootstrapitalia/moderation')}</button>
                <button class="border border-secondary btn btn-md {if $current_filters.status|eq(100)}btn-secondary{else}btn-outline-secondary{/if}" style="box-shadow:none;border-left:none !important;" name="ByStatus" type="submit" value="100">{'Unread list'|i18n('bootstrapitalia/moderation')}</button>
                {foreach array(0) as $status}
                    <button class="border border-secondary btn btn-md {if $current_filters.status|eq($status)}btn-secondary{else}btn-outline-secondary{/if}" style="box-shadow:none;border-left:none !important;" name="ByStatus" type="submit" value="{$status}">
                        {$status|choose( 'Pending list'|i18n( 'bootstrapitalia/moderation' ), 'Approved list'|i18n( 'bootstrapitalia/moderation' ), 'Rejected list'|i18n( 'bootstrapitalia/moderation' ) )}
                    </button>
                {/foreach}
            </div>
            <input type="hidden" name="status" value="{$current_filters.status}">
            {if or(count($approvals_facets.assignment), count($approvals_facets.classIdentifier))}
            <div class="input-group mb-3 justify-content-center">
                {if count($approvals_facets.assignment)}
                <div class="input-group-append" style="min-width:110px">
                    <label class="input-group-text border bg-light rounded-start" for="assignment">{'Location'|i18n( 'design/admin/node/view/full' )}</label>
                </div>
                <select name="assignment" id="assignment" class="custom-select" style="min-width:110px">
                    <option value="" {if $current_filters.assignment|not}selected{/if}>{'All'|i18n('bootstrapitalia/moderation')}</option>
                    {foreach $approvals_facets.assignment as $assignment}
                        {def $node = fetch(content, node, hash(node_id, $assignment, load_data_map, false()))}
                        {if $node}
                            <option value="{$assignment}" {if $current_filters.assignment|eq($assignment)}selected{/if}>{$node.name|wash}</option>
                        {/if}
                        {undef $node}
                    {/foreach}
                </select>
                <div class="d-block d-lg-none w-100 my-2"></div>
                {/if}
                {if count($approvals_facets.classIdentifier)}
                <div class="input-group-append" style="min-width:110px">
                    <label class="input-group-text border bg-light" for="classIdentifier">{'Type'|i18n( 'design/admin/node/view/full' )}</label>
                </div>
                <select name="classIdentifier" id="classIdentifier" class="custom-select" style="min-width:110px">
                    <option value="" {if $current_filters.classIdentifier|not()}selected{/if}>{'All'|i18n('bootstrapitalia/moderation')}</option>
                    {foreach $approvals_facets.classIdentifier as $classIdentifier}
                        <option value="{$classIdentifier}" {if $current_filters.classIdentifier|eq($classIdentifier)}selected{/if}>
                            {fetch(content, class, hash('class_id', $classIdentifier)).name|wash}
                        </option>
                    {/foreach}
                </select>
                {/if}
                <div class="d-block d-lg-none w-100 my-2"></div>
                <div class="input-group-append">
                    <input class="btn btn-secondary" name="Filter" type="submit" value="{'Search'|i18n('design/base')}" />
                </div>
            </div>
            {/if}
        </form>
        </div>
        {if $approvals_count|gt(0)}
            <table class="table" cellspacing="0">
                <thead>
                <tr>
                    <th>{'Content'|i18n( 'design/standard/pagelayout' )}</th>
                    <th>{'Type'|i18n( 'design/admin/node/view/full' )}</th>
                    <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Status'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                {foreach $approvals as $approvals_by_object sequence array( '', 'bg-light bg-opacity-50' ) as $style}
                    {foreach $approvals_by_object.queues as $index => $queue}
                    {def $approval = cond($queue.pending, $queue.latest, $queue.latest)}
                    <tr>
                        {if $index|eq(0)}
                            <td class="{$style}" style="vertical-align:middle" rowspan="{count($approvals_by_object.queues)}">
                                {$approval.object.name|wash()}
                            </td>
                            <td class="{$style}" style="vertical-align:middle" rowspan="{count($approvals_by_object.queues)}">{$approval.contentclass.name|wash()}</td>
                        {/if}
                        <td class="{$style}" style="vertical-align:middle">{$approval.author.contentobject.name|wash()}</td>
                        <td class="{$style}" style="vertical-align:middle">{$approval.createdAt|l10n( shortdatetime )}</td>
                        <td style="vertical-align:middle" class="{$style}">
                            {switch match=$approval.version.status}
                                {case match=2}
                                    {if $approval.is_author}
                                        {"Awaits approval by editor"|i18n('bootstrapitalia/moderation')}
                                    {else}
                                        {"Awaits your approval"|i18n('bootstrapitalia/moderation')}
                                    {/if}
                                {/case}
                                {case match=1}
                                    {"Was approved for publishing"|i18n('bootstrapitalia/moderation')}
                                {/case}
                                {case}
                                    {'Archived'|i18n( 'design/ocbootstrap/content/history' )}
                                {/case}
                            {/switch}
                        </td>
                        {if $index|eq(0)}
                            <td class="{$style}" style="white-space:nowrap; vertical-align:middle" rowspan="{count($approvals_by_object.queues)}">
                                <a class="btn btn-sm px-2 py-1 btn-link" href="{concat('/bootstrapitalia/approval/object/', $approval.contentObjectId)|ezurl(no)}">{'Details'|i18n( 'design/admin/node/view/full' )}</a>
                            </td>
                        {/if}
                    </tr>
                    {undef $approval}
                    {/foreach}
                {/foreach}
                </tbody>
            </table>
            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri='/bootstrapitalia/approval'
                     item_count=$approvals_count
                     view_parameters=$view_parameters
                     item_limit=$page_limit}
        {else}
            <p class="text-center"><em>{'No contents'|i18n('opendata_forms')}</em></p>
        {/if}
    {/if}

</div>
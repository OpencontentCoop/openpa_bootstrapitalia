<div class="approval">

    {if $approval_item}

        <h3 class="mb-4">
            <a href="{'/bootstrapitalia/approval'|ezurl(no)}"><i class="fa fa-check-circle-o "></i></a>
            {$approval_item.object.name|wash()}
            {if $approval_item.object.main_node_id}
                <a target="_blank" class="btn btn-outline-secondary btn-xs px-2 py-1 ml-2 ms-2" href="{$approval_item.object.main_node.url_alias|ezurl(no)}">{"Current version"|i18n("design/standard/content/view")} {$approval_item.object.current_version} <i class="fa fa-external-link"></i></a>
            {/if}
        </h3>

        <div class="input-group mb-3 justify-content-center">
            {if $approval_item.version}
            <a data-toggle="modal" data-target="#version-preview" data-bs-toggle="modal" data-bs-target="#version-preview"
               class="btn btn-secondary btn-md me-2 mr-2"
               href="#">
                {'Preview'|i18n('design/base')} {'version'i18n('bootstrapitalia/moderation')} {$approval_item.version.version}
            </a>
            {/if}
            <a target="_blank"
               class="btn btn-secondary btn-md"
               href="{concat('/content/history/', $approval_item.object.id)|ezurl(no)}">
                {'Manage versions'|i18n('design/standard/content/edit')} <i class="fa fa-external-link"></i>
            </a>

            {if and( $approval_item.version, eq( $approval_item.version.status, 2 ), can_approve_version($approval_item.version.id), $approval_item.object.can_edit )}
                <a class="btn btn-md btn-success text-white ms-2 ml-2 me-2 mr-2"
                   {if $approval_item.has_concurrent_pending}onclick="return window.confirmDiscard ? confirmDiscard( '{'By publishing content, versions currently awaiting moderation will be archived'|i18n( 'bootstrapitalia/moderation' )|wash(javascript)}' ): true;"{/if}
                   href="{concat('/bootstrapitalia/approval/', $approval_item.version.id, '/approve?redirect=version')|ezurl(no)}" title="{'Approve'|i18n('bootstrapitalia/moderation')}">
                    <i class="fa fa-check"></i> {'Approve'|i18n('bootstrapitalia/moderation')}
                </a>
                <a class="btn btn-md btn-danger text-white" href="{concat('/bootstrapitalia/approval/', $approval_item.version.id, '/deny?redirect=version')|ezurl(no)}" title="{'Deny'|i18n('bootstrapitalia/moderation')}">
                    <i class="fa fa-times"></i> {'Deny'|i18n('bootstrapitalia/moderation')}
                </a>
            {/if}
        </div>
        <script>function confirmDiscard( question ) {ldelim}return confirm( question );{rdelim}</script>

        <table class="table" cellspacing="0">
            <thead>
            <tr>
                <th width="1"></th>
                <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            {foreach $approval_item.history as $item}
                <tr{if $item.is_creator} class="bg-light bg-opacity-50"{/if}>
                    <td style="vertical-align:middle" width="1">
                        {if $item.type|eq('ocmoderation_comment')}<i class="fa fa-comment"></i>{/if}
                        {if $item.type|eq('ocmoderation_approved')}<i class="fa fa-check"></i>{/if}
                        {if array('ocmoderation_rejected', 'ocmoderation_archived')|contains($item.type)}<i class="fa fa-times"></i>{/if}
                        {if $item.type|eq('ocmoderation_created')}<i class="fa fa-history"></i>{/if}
                    </td>
                    <td style="vertical-align:middle;white-space:nowrap">{$item.creator.contentobject.name|wash()}</td>
                    <td style="vertical-align:middle;white-space:nowrap">{$item.createdAt|l10n( shortdatetime )}</td>
                    <td style="vertical-align:middle">
                        {switch match=$item.type}
                        {case match='ocmoderation_created'}
                            {'Request for approval'|i18n( 'bootstrapitalia/moderation' )} {'version'i18n('bootstrapitalia/moderation')} {$approval_item.version.version}
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
                        {case match='ocmoderation_comment'}
                            {$item.text|wash()|nl2br()}
                        {/case}
                        {case}{/case}
                        {/switch}
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>

        <div class="mx-5 p-5 mt-5 bg-light bg-opacity-50 border rounded">
        <form method="post" action="{concat('/bootstrapitalia/approval/', $approval_item.contentObjectVersionId, '/comment')|ezurl(no)}">
            <textarea required class="form-control border mb-2" rows="5" name="Comment"></textarea>
            <div class="text-end text-right">
                <input type="submit" value="Aggiungi commento" class="btn btn-secondary btn-md" name="AddCommentButton" />
            </div>
        </form>
        </div>

        {if $approval_item.version}
        <div id="version-preview" class="modal fade modal-fullscreen" style="z-index:10000">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-body">
                        <div class="clearfix">
                            <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                        </div>
                        <iframe src="{concat("content/versionview/",$approval_item.contentObjectId,"/",$approval_item.version.version,"/",$approval_item.contentObjectVersionLanguage, '?embedded=true' )|ezurl(no)}" width="100%" height="100%" style="overflow-x:hidden">
                            Your browser does not support iframes. Please see this <a href="{concat("content/versionview/",$approval_item.contentObjectId,"/",$approval_item.version.version,"/",$approval_item.contentObjectVersionLanguage )|ezurl(no)}">link</a> instead.
                        </iframe>
                    </div>
                </div>
            </div>
        </div>
        {/if}

    {else}
        <h2 class="mt-5 mb-4"><i class="fa fa-check-circle-o "></i> {'Approval dashboard'|i18n('bootstrapitalia/moderation')}</h2>

        <div class="clearfix mt-4 mb-4 text-center">
            <form action="{'bootstrapitalia/approval/'|ezurl(no)}" method="post">
            <div class="input-group mb-3 justify-content-center">
                <button class="border border-secondary btn btn-md {if $current_filters.status|eq(-1)}btn-secondary{else}btn-outline-secondary{/if}" style="box-shadow:none;" name="ByStatus" type="submit" value="-1">{'All'|i18n('bootstrapitalia/moderation')}</button>
                <button class="border border-secondary btn btn-md {if $current_filters.status|eq(100)}btn-secondary{else}btn-outline-secondary{/if}" style="box-shadow:none;border-left:none !important;" name="ByStatus" type="submit" value="100">{'Unread list'|i18n('bootstrapitalia/moderation')}</button>
                {foreach array(0,1,2) as $status}
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
                    <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Status'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                {foreach $approvals as $grouped_object sequence array( '', 'bg-light bg-opacity-50' ) as $style}
                    {foreach $grouped_object.items as $index => $approval}
                    {def $can_approve = cond(and( array(0)|contains($approval.status), can_approve_version($approval.contentObjectVersionId), $approval.can_edit ), true(), false())}
                    <tr>
                        {if $index|eq(0)}
                        <td class="{$style}" style="vertical-align:middle" rowspan="{$grouped_object.count}">
                            {if $approval.object.main_node_id}
                                <a target="_blank" href="{$approval.object.main_node.url_alias|ezurl(no)}">{$approval.object.name|wash()}</a>
                            {else}
                                {$approval.object.name|wash()}
                            {/if}
                        </td>
                        {/if}
                        <td class="{$style}" style="vertical-align:middle">{$approval.contentclass.name|wash()}</td>
                        <td class="{$style}" style="vertical-align:middle;text-align:center" id="obj-{$approval.contentObjectId}-{$approval.contentObjectVersionId}-{$approval.processId}">
                            {if $approval.version}
                                <code>{$approval.version.version|wash()}</code>
                            {/if}
                        </td>
                        <td class="{$style}" style="vertical-align:middle">{$approval.author.contentobject.name|wash()}</td>
                        <td class="{$style}" style="vertical-align:middle">{$approval.createdAt|l10n( shortdatetime )}</td>
                        <td style="vertical-align:middle"{if $approval.status|eq(2)}class="bg-danger bg-opacity-25"{elseif $approval.status|eq(1)}class="bg-success bg-opacity-25"{else}class="{$style}"{/if}>
                            {switch match=$approval.status}
                                {case match=0}
                                {if $approval.processId|not()}
                                {elseif $approval.is_author}
                                    {"Awaits approval by editor"|i18n('bootstrapitalia/moderation')}
                                {else}
                                    {"Awaits your approval"|i18n('bootstrapitalia/moderation')}
                                {/if}
                                {/case}
                                {case match=1}
                                    {"Was approved for publishing"|i18n('bootstrapitalia/moderation')}
                                {/case}
                                {case in=array(2,3)}
                                    {"Was not approved for publishing"|i18n('bootstrapitalia/moderation')}
                                {/case}
                                {case/}
                            {/switch}
                        </td>
                        <td class="{$style}" style="white-space:nowrap; vertical-align:middle">
                            <a class="btn btn-sm px-2 py-1 btn-link" href="{concat('/bootstrapitalia/approval/', $approval.contentObjectVersionId)|ezurl(no)}">{'Details'|i18n( 'design/admin/node/view/full' )}</a>
                        </td>
                    </tr>
                    {undef $can_approve}
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
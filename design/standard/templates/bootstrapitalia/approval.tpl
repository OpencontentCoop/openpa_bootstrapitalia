<div class="approval">
    <h2 class="mb-4">
        <i class="fa fa-code-fork"></i> Approvazione dei contenuti
    </h2>

    <div class="clearfix mt-4 mb-4 text-center">
        <form action="{'bootstrapitalia/approval/'|ezurl(no)}" method="post">
            <div class="input-group mb-3 justify-content-center">
                <div class="input-group-append" style="width:110px">
                    <label class="input-group-text border bg-light rounded-start" for="assignment">{'Location'|i18n( 'design/admin/node/view/full' )}</label>
                </div>
                <select name="assignment" id="assignment" class="custom-select" style="width:240px">
                    <option value="" {if $current_filters.assignment|not}selected{/if}>{'All'|i18n('design/admin/package/list')}</option>
                    {foreach $approvals_facets.assignment as $assignment}
                        {def $node = fetch(content, node, hash(node_id, $assignment, load_data_map, false()))}
                        {if $node}
                            <option value="{$assignment}" {if $current_filters.assignment|eq($assignment)}selected{/if}>{$node.name|wash}</option>
                        {/if}
                        {undef $node}
                    {/foreach}
                </select>
                <div class="d-block d-lg-none w-100 my-2"></div>
                <div class="input-group-append" style="width:110px">
                    <label class="input-group-text border bg-light" for="classIdentifier">{'Type'|i18n( 'design/admin/node/view/full' )}</label>
                </div>
                <select name="classIdentifier" id="classIdentifier" class="custom-select" style="width:240px">
                    <option value="" {if $current_filters.classIdentifier|not()}selected{/if}>{'All'|i18n('design/admin/package/list')}</option>
                    {foreach $approvals_facets.classIdentifier as $classIdentifier}
                        <option value="{$classIdentifier}" {if $current_filters.classIdentifier|eq($classIdentifier)}selected{/if}>
                            {fetch(content, class, hash('class_id', $classIdentifier)).name|wash}
                        </option>
                    {/foreach}
                </select>
                <div class="d-block d-lg-none w-100 my-2"></div>
                <div class="input-group-append" style="width:110px">
                    <label class="input-group-text border bg-light" for="status">{'State'|i18n('design/admin/package')}</label>
                </div>
                <select name="status" id="status" class="custom-select" style="width:240px">
                    <option value="-1" {if $current_filters.status|eq(-1)}selected{/if}>{'All'|i18n('design/admin/package/list')}</option>
                    {foreach array(0,1,2) as $status}
                        <option value="{$status}" {if $current_filters.status|eq($status)}selected{/if}>
                            {$status|choose( 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Approvato'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ) )}
                        </option>
                    {/foreach}
                </select>
                <div class="d-block d-lg-none w-100 my-2"></div>
                <div class="input-group-append">
                    <input class="btn btn-success" name="Filter" type="submit" value="{'Search'|i18n('design/base')}" />
                </div>
            </div>
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
            <tr class="{$style}">
                {if $index|eq(0)}
                <td style="vertical-align:middle" rowspan="{$grouped_object.count}">
                    {$approval.object.name|wash()} {$approval.object.id}
                </td>
                {/if}
                <td style="vertical-align:middle">{$approval.contentclass.name|wash()}</td>
                <td style="vertical-align:middle">
                    <a target="_blank" class="btn btn-link btn-sm text-nowrap" href="{concat('/content/versionview/', $approval.contentObjectId, '/', $approval.version.version, '/', $approval.contentObjectVersionLanguage)|ezurl(no)}">
                        {$approval.version.version|wash()} <i class="fa fa-external-link"></i>
                    </a>
                </td>
                <td style="vertical-align:middle">{$approval.author.contentobject.name|wash()}</td>
                <td style="vertical-align:middle">{$approval.createdAt|l10n( shortdatetime )}</td>
                <td style="vertical-align:middle"{if $can_approve|not} colspan="2"{/if} {if $approval.status|eq(2)}class="bg-danger bg-opacity-25"{elseif $approval.status|eq(1)}class="bg-success bg-opacity-25"{/if}>
                    {switch match=$approval.status}
                        {case match=0}
                        {if $approval.is_author}
                            {"%1 awaits approval by editor"|i18n('design/standard/collaboration/handler/view/line/ezapprove',,array(concat('')))}
                        {else}
                            {"%1 awaits your approval"|i18n('design/standard/collaboration/handler/view/line/ezapprove',,array(concat('')))}
                        {/if}
                        {/case}
                        {case match=1}
                            {"%1 was approved for publishing"|i18n('design/standard/collaboration/handler/view/line/ezapprove',,array(concat('')))}
                        {/case}
                        {case in=array(2,3)}
                            {"%1 was not approved for publishing"|i18n('design/standard/collaboration/handler/view/line/ezapprove',,array(concat('')))}
                        {/case}
                        {case/}
                    {/switch}
                </td>
                {if $can_approve}
                <td style="white-space:nowrap; vertical-align:middle">
                    <a class="btn btn-sm px-2 py-1 btn-success" href="{concat('/bootstrapitalia/approval/', $approval.contentObjectVersionId, '/approve')|ezurl(no)}" title="{'Approve'|i18n('design/standard/collaboration/approval')}">
                        <i class="fa fa-thumbs-o-up"></i> {'Approve'|i18n('design/standard/collaboration/approval')}
                    </a>
                    <a class="btn btn-sm px-2 py-1 btn-danger" href="{concat('/bootstrapitalia/approval/', $approval.contentObjectVersionId, '/deny')|ezurl(no)}" title="{'Deny'|i18n('design/standard/collaboration/approval')}">
                        <i class="fa fa-thumbs-o-down"></i> {'Deny'|i18n('design/standard/collaboration/approval')}
                    </a>
                </td>
                {/if}
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
{/if}
</div>
<table class="table my-4" cellspacing="0">
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
                {if array('ocmoderation_rejected', 'ocmoderation_archived', 'ocmoderation_modified', 'ocmoderation_discard')|contains($item.type)}<i class="fa fa-times"></i>{/if}
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
                {case match='ocmoderation_modified'}
                {'The version was archived following the request approval of version %id'|i18n( 'bootstrapitalia/moderation',, hash('%id', $item.archivedByVersion) )}
                {/case}
                {case match='ocmoderation_discard'}
                {'The version was discard by creator'|i18n( 'bootstrapitalia/moderation' )}
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
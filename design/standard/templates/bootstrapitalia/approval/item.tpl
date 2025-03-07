{set_defaults(hash('redirect', 'version'))}
<div class="text-center">
{if $approval_item.version}
    <a data-toggle="modal" data-target="#version-preview-{$approval_item.contentObjectVersionId}" data-bs-toggle="modal" data-bs-target="#version-preview-{$approval_item.contentObjectVersionId}"
       class="btn btn-secondary btn-md"
       href="#">
        <i class="fa fa-eye"></i> Visualizza il contenuto
        {if ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')|ne($approval.version.initial_language.locale))}
            <img src="{$approval.version.initial_language.locale|flag_icon}"
                 style="vertical-align: middle;height: 25px;width: 25px;border-radius: 100%;border: 2px solid #fff;margin-left: 5px;"
                 alt="{$approval.version.initial_language.locale}"
                 title="{'Content in %language'|i18n( 'design/ezflow/edit/frontpage',, hash('%language', $approval.version.initial_language.name ) )}"
            />
        {/if}
    </a>
{/if}
{if $approval_item.is_author}
    <a class="btn btn-md btn-secondary text-white"
       href="{concat('/bootstrapitalia/approval/edit/', $approval_item.contentObjectId)|ezurl(no)}" title="{'Approve'|i18n('bootstrapitalia/moderation')}">
        <i class="fa fa-pencil"></i> {'Edit'|i18n('design/standard/parts/website_toolbar')}
    </a>
    {if $approval_item.status|eq(0)}
    <a class="btn btn-md btn-danger text-white" href="{concat('bootstrapitalia/approval/version/', $approval_item.contentObjectVersionId, '/discard?redirect=object')|ezurl(no)}">
        <i class="fa fa-trash"></i> {'Annulla richiesta di approvazione'|i18n('bootstrapitalia/moderation')}
    </a>
    {/if}
{elseif and( $approval_item.version, eq( $approval_item.version.status, 2 ), can_approve_version($approval_item.version.id), $approval_item.object.can_edit )}
    {if $approval_item.depends_on|count()|eq(0)}
        <a class="btn btn-md btn-success text-white"
           {if $approval_item.has_concurrent_pending}onclick="return window.confirmDiscard ? confirmDiscard( '{'By publishing content, versions currently awaiting moderation will be archived'|i18n( 'bootstrapitalia/moderation' )|wash(javascript)}' ): true;"{/if}
           href="{concat('/bootstrapitalia/approval/version/', $approval_item.version.id, '/approve?redirect=',$redirect)|ezurl(no)}" title="{'Approve'|i18n('bootstrapitalia/moderation')}">
            <i class="fa fa-check"></i> {'Approve'|i18n('bootstrapitalia/moderation')}
        </a>
    {else}
        <span class="btn btn-md btn-success text-white disabled" style="cursor:not-allowed !important;">
            <i class="fa fa-ban"></i> {'Approve'|i18n('bootstrapitalia/moderation')}
        </span>
    {/if}
    <a class="btn btn-md btn-danger text-white" href="{concat('/bootstrapitalia/approval/version/', $approval_item.version.id, '/deny?redirect=',$redirect)|ezurl(no)}" title="{'Deny'|i18n('bootstrapitalia/moderation')}">
        <i class="fa fa-close"></i> {'Deny'|i18n('bootstrapitalia/moderation')}
    </a>
    {if $approval_item.depends_on|count()|gt(0)}
    <div class="row justify-content-around mt-4">
        <div class="col col-sm-12 col-lg-8">
        <p class="lead text-left text-start">Per approvare questa richiesta, devi prima moderare queste richieste:</p>
        <table class="table text-left text-start" cellspacing="0">
            <thead>
                <tr>
                    <th>{'Content'|i18n( 'design/standard/pagelayout' )}</th>
                    <th>{'Type'|i18n( 'design/admin/node/view/full' )}</th>
                    <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            {foreach $approval_item.depends_on as $dep}
            <tr>
                <td>{$dep.object.name|wash()}</td>
                <td>{$dep.contentclass.name|wash()}</td>
                <td>{$dep.author.contentobject.name|wash()}</td>
                <td>{$dep.createdAt|l10n( shortdatetime )}</td>
                <td>
                    <a href="{concat('/bootstrapitalia/approval/object/', $dep.contentObjectId)|ezurl(no)}">{'Details'|i18n( 'design/admin/node/view/full' )}</a>
                </td>
            </tr>
            {/foreach}
            </tbody>
        </table>
        </div>
    </div>
    {/if}
{/if}
<script>function confirmDiscard( question ) {ldelim}return confirm( question );{rdelim}</script>
</div>

{if $approval_item.version}
    <div id="version-preview-{$approval_item.contentObjectVersionId}" class="modal fade modal-fullscreen" style="z-index:10000">
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
{unset_defaults(array('redirect'))}
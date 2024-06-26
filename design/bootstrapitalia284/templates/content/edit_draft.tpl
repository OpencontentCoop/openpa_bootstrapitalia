{let has_own_drafts=false()
     has_other_drafts=false()
     current_creator=fetch(user,current_user)}
{section loop=$draft_versions}
    {section show=eq($item.creator_id,$current_creator.contentobject_id)}
        {set has_own_drafts=true()}
    {section-else}
        {set has_other_drafts=true()}
    {/section}
{/section}

<div class="container" style="margin-top: 80px;">

<form method="post" action={concat('content/edit/',$object.id,'/',$edit_language,'/',$from_language)|ezurl}>

<h1>{$object.name|wash}</h1>

<div class="alert alert-info mt-1 mb-3">
    {"The currently published version is %version and was published at %time."|i18n('design/ocbootstrap/content/edit_draft',,hash('%version',$object.current_version,'%time',$object.published|l10n(datetime) ))}<br />
    {"The last modification was done at %modified."|i18n('design/ocbootstrap/content/edit_draft',,hash('%modified',$object.modified|l10n(datetime)))}<br />
    {"The object is owned by %owner."|i18n('design/ocbootstrap/content/edit_draft',,hash('%owner',$object.owner.name))}
</div>

<div class="alert alert-warning mt-1 mb-3">
{section show=and($has_own_drafts,$has_other_drafts)}
   {"This object is already being edited by yourself and others.
    You can either continue editing one of your drafts or you can create a new draft."|i18n('design/ocbootstrap/content/edit_draft')}
{section-else}
    {section show=$has_own_drafts}
      {"This object is already being edited by you.
        You can either continue editing one of your drafts or you can create a new draft."|i18n('design/ocbootstrap/content/edit_draft')}
    {/section}
    {section show=$has_other_drafts}
      {"This object is already being edited by someone else.
        You should either contact the person about their draft or create a new draft for your own use."|i18n('design/ocbootstrap/content/edit_draft')}
    {/section}
{/section}
</div>

<h2>{'Current drafts'|i18n('design/ocbootstrap/content/edit_draft')}</h2>

<div class="table-responsive">
    <table class="table">
    <tr>
        {section show=$has_own_drafts}
            <th></th>
        {/section}
        <th>{'Version'|i18n('design/ocbootstrap/content/edit_draft')}</th>
        <th>{'Name'|i18n('design/ocbootstrap/content/edit_draft')}</th>
        <th>{'Owner'|i18n('design/ocbootstrap/content/edit_draft')}</th>
        <th>{'Created'|i18n('design/ocbootstrap/content/edit_draft')}</th>
        <th>{'Last modified'|i18n('design/ocbootstrap/content/edit_draft')}</th>
    </tr>
    {section name=Draft loop=$draft_versions sequence=array(bglight,bgdark)}
    <tr class="{$:sequence}">
        {section show=$has_own_drafts}
            <td width="1">
                {section show=eq($:item.creator_id,$current_creator.contentobject_id)}
                    <input type="radio" name="SelectedVersion" value="{$:item.version}"
                        {run-once}
                            checked="checked"
                        {/run-once}
                     />
                {/section}
            </td>
        {/section}
        <td width="1">
            {$:item.version}
        </td>
        <td>
            <a href={concat('content/versionview/',$object.id,'/',$:item.version)|ezurl}>{$:item.version_name|wash}</a>
        </td>
        <td>
            {content_view_gui view=text_linked content_object=$:item.creator}
        </td>
        <td>
            {$:item.created|l10n(shortdatetime)}
        </td>
        <td>
            {$:item.modified|l10n(shortdatetime)}
        </td>
    </tr>
    {/section}
    </table>
</div>

{section show=and($has_own_drafts,$has_other_drafts)}
    <input class="btn btn-success" type="submit" name="EditButton" value="{'Edit'|i18n('design/ocbootstrap/content/edit_draft')}" />
    <input class="btn btn-warning" type="submit" name="NewDraftButton" value="{'New draft'|i18n('design/ocbootstrap/content/edit_draft')}" />
{section-else}
    {section show=$has_own_drafts}
        <input class="btn btn-success" type="submit" name="EditButton" value="{'Edit'|i18n('design/ocbootstrap/content/edit_draft')}" />
        <input class="btn btn-warning" type="submit" name="NewDraftButton" value="{'New draft'|i18n('design/ocbootstrap/content/edit_draft')}" />
    {/section}
    {section show=$has_other_drafts}
        <input class="btn btn-warning" type="submit" name="NewDraftButton" value="{'New draft'|i18n('design/ocbootstrap/content/edit_draft')}" />
    {/section}
{/section}

<input type="hidden" name="ContentObjectLanguageCode" value="{$edit_language}" />

</form>
{/let}

</div>

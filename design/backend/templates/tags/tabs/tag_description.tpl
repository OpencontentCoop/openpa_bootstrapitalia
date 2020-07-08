<div class="block">
    {foreach $tag.translations as $translation}
    <fieldset>
        <legend><img src="{$translation.locale|flag_icon}" width="18" height="12" alt="{$translation.locale}" />&nbsp; {'Tag description'|i18n( 'bootstrapitalia/tag_description' )}</legend>
        <form method="post" action={concat('tagdescription/update/',$tag.id,'/',$translation.locale)|ezurl}>
            <textarea name="TagDescriptionText" class="halfbox">{tag_description($tag.id, $translation.locale)|wash()}</textarea>
            <input class="button" type="submit" name="StoreTagDescriptionButton" value="{'Update'|i18n( 'extension/eztags/tags/view' )}" />
        </form>
    </fieldset>
    {/foreach}
</div>

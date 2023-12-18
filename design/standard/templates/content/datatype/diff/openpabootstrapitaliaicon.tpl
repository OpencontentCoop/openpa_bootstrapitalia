{def $oldAttr=$diff.old_content
     $newAttr=$diff.new_content}
<div class="attribute-view-diff-old">
    <label>{'Version: %old'|i18n( 'design/standard/content/datatype',, hash( '%old', $old ) )}</label>
    {$oldAttr.content}
</div>
<div class="attribute-view-diff-new">
    <label>{'Version: %new'|i18n( 'design/standard/content/datatype',, hash( '%new', $new ) )}</label>
    {$newAttr.content}
</div>
{def $oldAttr=$diff.old_content
     $newAttr=$diff.new_content}
<div class="attribute-view-diff-old">
    <label>{'Version: %old'|i18n( 'design/standard/content/datatype',, hash( '%old', $old ) )}</label>
    {foreach $oldAttr.content.zones as $zone}
        {if is_set($zone.blocks)}
        <table class="list" cellspacing="0">
            <tr>
                <th>{'Type'|i18n( 'design/standard/content/datatype' )}</th>
                <th>{'Object name'|i18n( 'design/standard/content/datatype' )}</th>
            </tr>
            {foreach $zone.blocks as $block}
                <tr>
                    <td>{$block.type|wash()}</td>
                    <td>{$block.name|wash()}</td>
                </tr>
            {/foreach}
        </table>
        {/if}
    {/foreach}
</div>
<div class="attribute-view-diff-new">
    <label>{'Version: %new'|i18n( 'design/standard/content/datatype',, hash( '%new', $new ) )}</label>
    {foreach $newAttr.content.zones as $zone}
        {if is_set($zone.blocks)}
            <table class="list" cellspacing="0">
                <tr>
                    <th>{'Type'|i18n( 'design/standard/content/datatype' )}</th>
                    <th>{'Object name'|i18n( 'design/standard/content/datatype' )}</th>
                </tr>
                {foreach $zone.blocks as $block}
                    <tr>
                        <td>{$block.type|wash()}</td>
                        <td>{$block.name|wash()}</td>
                    </tr>
                {/foreach}
            </table>
        {/if}
    {/foreach}
</div>
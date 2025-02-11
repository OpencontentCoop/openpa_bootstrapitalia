{if $attribute.type|eq('custom_source')}
    {include uri='design:block/edit/parts/custom_source.tpl' attribute=$attribute}
{else}
    {if $attribute.type}
        {switch match = $attribute.type}
        {case match = 'text'}
            {include uri='design:block/edit/parts/text.tpl' attribute=$attribute}
        {/case}
        {case match = 'checkbox'}
            {include uri='design:block/edit/parts/checkbox.tpl' attribute=$attribute}
        {/case}
        {case match = 'string'}
            {include uri='design:block/edit/parts/string.tpl' attribute=$attribute}
        {/case}
        {case match = 'select'}
            {include uri='design:block/edit/parts/select.tpl' attribute=$attribute}
        {/case}
        {case match = 'class_select'}
            {include uri='design:block/edit/parts/class_select.tpl' attribute=$attribute}
        {/case}
        {case match = 'state_select'}
            {include uri='design:block/edit/parts/state_select.tpl' attribute=$attribute}
        {/case}
        {case match = 'topic_select'}
            {include uri='design:block/edit/parts/topic_select.tpl' attribute=$attribute}
        {/case}
        {case match = 'tag_tree_select'}
            {include uri='design:block/edit/parts/tag_tree_select.tpl' attribute=$attribute}
        {/case}
        {case}
            {include uri='design:block/edit/parts/default.tpl' attribute=$attribute}
        {/case}
        {/switch}
    {else}
        {include uri='design:block/edit/parts/default.tpl' attribute=$attribute}
    {/if}
{/if}
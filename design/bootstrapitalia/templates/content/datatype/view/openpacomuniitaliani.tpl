{def $content = $attribute.content}
{foreach $content as $item}
    <div class="text-sans-serif chip text-nowrap chip-simple chip-secondary"><span class="chip-label">{$item.name|wash}</span></div>
{/foreach}

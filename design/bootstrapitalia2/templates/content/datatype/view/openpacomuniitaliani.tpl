{def $content = $attribute.content}
<div class="d-flex flex-wrap gap-2 mt-10 mb-30 font-sans-serif">
{foreach $content as $item}
    <div class="chip chip-simple chip-primary bg-tag"><span class="chip-label">{$item.name|wash}</span></div>
{/foreach}
</div>

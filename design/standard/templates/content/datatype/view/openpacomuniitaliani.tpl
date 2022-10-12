{def $content = $attribute.content}
<ul class="list-unstyled">
{foreach $content as $item}
    <li>{$item.name|wash}</li>
{/foreach}
</ul>

{def $authors = array()}
{foreach $attribute.content.author_list as $author}
    {if $author.name|eq('')}{skip}{/if}
    {set $authors = $authors|append($author)}
{/foreach}
{if $authors|count()}
    <div class="mb-40">
    {foreach $authors as $author}
        {$author.name|wash( xhtml )}{delimiter},{/delimiter}
    {/foreach}
    </div>
{/if}
{undef $authors}
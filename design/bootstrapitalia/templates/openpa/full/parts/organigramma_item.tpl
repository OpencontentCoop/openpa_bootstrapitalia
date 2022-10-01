<span class="vcard {$item.class_identifier}">
    <a class="text-black text-decoration-none text-uppercase size-lg" href={$item.url_alias|ezurl}>{$item.name|wash}</a>
</span>
{if $item.items|count()}
    {set $level = $level|inc()}
    {foreach $item.items as $collection}
        <ul{if $collection.identifier} class="{$collection.identifier}"{/if}>
            {foreach $collection.items as $sub_item}
                <li>
                    {include level=$level uri='design:openpa/full/parts/organigramma_item.tpl' item=$sub_item name=organigramma_sub_item current_id=$current_id}
                </li>
            {/foreach}
        </ul>
    {/foreach}
{/if}
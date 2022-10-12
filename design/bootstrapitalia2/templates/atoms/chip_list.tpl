{set_defaults(hash('data_element', false()))}
<div class="d-flex flex-wrap gap-2 mt-10 mb-30 font-sans-serif">
        {foreach $items as $child}
        <div class="cmp-tag">
                <a class="chip chip-simple t-primary bg-tag text-decoration-none" href="{$child.url_alias|ezurl(no)}"{if $data_element} data-element="{$data_element|wash()}"{/if} data-focus-mouse="false">
                        <span class="chip-label">{$child.name|wash()}</span>
                </a>
        </div>
        {/foreach}
</div>
{unset_defaults(array('data_element'))}
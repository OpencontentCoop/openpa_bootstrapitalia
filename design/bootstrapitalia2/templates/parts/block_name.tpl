{def $intro = cond(is_set($block.custom_attributes.intro_text), $block.custom_attributes.intro_text, '')}
{set_defaults(hash('block_index', 0))}
{if or($block.name|ne(''), $intro|ne(''))}
    <div class="row row-title{if and(is_set($no_margin), $no_margin)|not()} pb-3{/if}">
        <div class="col-12">
            {if $block.name|ne('')}
                {if $block_index|gt(3)}
                    <h2 class="block-title{if is_set($css_class)} {$css_class}{/if}"{if $block.view|contains('accordion')} style="border:none !important;margin-bottom: 0;padding-bottom: 0 !important;"{/if}>{$block.name|wash()}</h2>
                {else}
                    <h2 class="{if and($intro|eq(''), and(is_set($no_margin), $no_margin)|not())}mb-2 {/if}block-title title-xxlarge{if is_set($css_class)} {$css_class}{/if}"{if $block.view|contains('accordion')} style="border:none !important;margin-bottom: 0;padding-bottom: 0 !important;"{/if}>{$block.name|wash()}</h2>
                {/if}
            {/if}
            {if $intro|ne('')}
                <p class="lead">{$intro|simpletags|autolink}</p>
            {/if}
        </div>
    </div>
{elseif $block.id|eq('e60d1373e30187166ab36ff0f088d87f')} {*SECTION_LATEST_NEWS || SECTION_NEWS*}
    <h2 class="visually-hidden">{fetch(content, object, hash(remote_id, 'news')).name|wash()}</h2>
{elseif $block.id|eq('3213d4722665b8ca7155847fb767eb62')} {*SECTION_MANAGEMENT*}
    <h2 class="visually-hidden">{fetch(content, object, hash(remote_id, 'management')).name|wash()}</h2>
{elseif $block.id|eq('9cd237a12fdb73a490fee0b01a3fab9d')} {*SECTION_NEXT_EVENTS || SECTION_CALENDAR*}
    <h2 class="visually-hidden">{fetch(content, object, hash(remote_id, 'all-events')).name|wash()}</h2>
{/if}
{unset_defaults(array('block_index'))}
{undef $intro}
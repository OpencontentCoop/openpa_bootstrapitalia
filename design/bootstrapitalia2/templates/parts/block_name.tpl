{def $intro = cond(is_set($block.custom_attributes.intro_text), $block.custom_attributes.intro_text, '')}
{set_defaults(hash('block_index', 0))}
{if or($block.name|ne(''), $intro|ne(''))}
    <div class="row row-title{if and(is_set($no_margin), $no_margin)|not()} pb-3{/if}">
        <div class="col-12">
            {if $block.name|ne('')}
                {if $block_index|gt(3)}
                    <h2 class="h3 mb-3 u-grey-light block-title{if is_set($css_class)} {$css_class}{/if}">{$block.name|wash()}</h2>
                {else}
                    <h2 class="{if and($intro|eq(''), and(is_set($no_margin), $no_margin)|not())}mb-2 {/if}block-title title-xxlarge{if is_set($css_class)} {$css_class}{/if} ">{$block.name|wash()}</h2>
                {/if}
            {/if}
            {if $intro|ne('')}
                <p class="lead">{$intro|simpletags|autolink}</p>
            {/if}
        </div>
    </div>
{/if}
{unset_defaults(array('block_index'))}
{undef $intro}
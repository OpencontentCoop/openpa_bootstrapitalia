{def $intro = cond(is_set($block.custom_attributes.intro_text), $block.custom_attributes.intro_text, '')}
{if or($block.name|ne(''), $intro|ne(''))}
    <div class="row">
        <div class="col-md-12">
            {if $block.name|ne('')}
            <h3 class="{if and($intro|eq(''), and(is_set($no_margin), $no_margin)|not())}mb-4 {/if}block-title{if is_set($css_class)} {$css_class}{else} text-primary{/if}">{$block.name|wash()}</h3>
            {/if}
            {if $intro|ne('')}
                <p class="lead">{$intro|simpletags|autolink}</p>
            {/if}
        </div>
    </div>
{/if}
{undef $intro}
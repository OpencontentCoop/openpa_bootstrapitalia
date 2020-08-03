{if $block.name|ne('')}
    <div class="row">
        <div class="col-md-12">
            <h3 class="{if and(is_set($no_margin), $no_margin)|not()}mb-4 {/if}block-title text-primary{if is_set($css_class)} {$css_class}{/if}">{$block.name|wash()}</h3>
        </div>
    </div>
{/if}
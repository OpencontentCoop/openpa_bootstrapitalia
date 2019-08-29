{if $block.name|ne('')}
    <div class="row">
        <div class="col-md-12">
            <h3 class="mb-4 block-title text-primary{if is_set($css_class)} {$css_class}{/if}">{$block.name|wash()}</h3>
        </div>
    </div>
{/if}
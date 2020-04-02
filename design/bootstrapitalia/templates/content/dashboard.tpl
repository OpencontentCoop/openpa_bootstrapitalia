{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path', false() )}

<section class="section section-muted section-inset-shadow pb-5">
    <div class="container">

        <h3>Strumenti</h3>

        {foreach $blocks as $block}
            {if $block.template}
                {include uri=concat( 'design:', $block.template )}
            {else}
                {include uri=concat( 'design:dashboard/', $block.identifier, '.tpl' )}
            {/if}
        {/foreach}
    </div>
</section>
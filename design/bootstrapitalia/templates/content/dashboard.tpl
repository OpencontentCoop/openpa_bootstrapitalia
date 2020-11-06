{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path', false() )}

<section class="section section-muted section-inset-shadow py-5">
    <div class="container">

        {*<h3 class="mb-4">{'Dashboard'|i18n('bootstrapitalia')}</h3>*}

        {foreach $blocks as $block}
            <div class="mb-4">
            {if $block.template}
                {include uri=concat( 'design:', $block.template )}
            {else}
                {include uri=concat( 'design:dashboard/', $block.identifier, '.tpl' )}
            {/if}
            </div>
        {/foreach}
    </div>
</section>
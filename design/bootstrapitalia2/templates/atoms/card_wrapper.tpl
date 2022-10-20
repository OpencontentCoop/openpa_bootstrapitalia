{set_defaults(hash(
    'items_per_row', 3,
    'i_view', 'card',
    'image_class', 'large',
    'show_icon', true(),
    'view_variation', false(),
    'grid_wrapper', true(),
    'exclude_classes', array()
))}

{if array('2', '3', '4')|contains($items_per_row)|not()}
    {include uri='design:atoms/grid.tpl'
             items_per_row=$items_per_row
             i_view=$i_view
             view_variation=$view_variation
             show_icon=$show_icon
             image_class=$image_class
             items=$items}
{else}
    <div class="row">
        <div class="card-wrapper {$grid_wrapper} card-teaser-block-{$items_per_row}">
            {foreach $items as $child }
                <div class="card card-teaser no-after rounded shadow-sm mb-0 border border-light">
                    <div class="card-body pb-5">
                        <div class="category-top">
                            <span class="title-xsmall-semi-bold fw-semibold">Organi di governo</span>
                        </div>
                        <h3 class="card-title text-paragraph-medium u-grey-light">Il consiglio comunale</h3>
                        <p class="text-paragraph-card u-grey-light m-0">Il Consiglio è un organo collegiale ed elettivo che
                            rimane in carica per 5 anni.
                        </p>
                    </div>
                    <a class="read-more" href="#">
                        <span class="text">Vai alla pagina</span>
                        <svg class="icon ms-0">
                            <use xlink:href="../assets/bootstrap-italia/dist/svg/sprites.svg#it-arrow-right"></use>
                        </svg>
                    </a>
                </div>
            {/foreach}
        </div>
    </div>
{/if}

{unset_defaults(array(
    'items_per_row',
    'i_view',
    'image_class',
    'view_variation',
    'exclude_classes'
))}


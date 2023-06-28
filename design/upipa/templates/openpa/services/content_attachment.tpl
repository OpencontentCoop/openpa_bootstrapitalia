
{if $openpa.content_attachment.children_count}
    <div class="container my-5">
    {include uri='design:atoms/grid.tpl'
         items_per_row=3
         i_view=card_teaser
         show_icon = false()
         items=$openpa.content_attachment.children}
    </div>
{/if}
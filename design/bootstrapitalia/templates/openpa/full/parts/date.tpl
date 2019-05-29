{if $openpa.content_date.show_date}
<div class="row mt40">
    <div class="offset-xl-1 col-xl-2 offset-lg-1 col-lg-3 col-md-3">
        {if $node.object.published|gt(0)}
        <p class="info-date"><span>Data:</span><br><strong>{$node.object.published|datetime( 'custom', '%j %F %Y' )}</strong></p>
        {/if}
        {*if $node.object.modified|gt(sum($node.object.published,86400))}
            <p class="info-date"><span>Ultima modifica:</span><br><strong>{$node.object.modified|datetime( 'custom', '%j %F %Y' )}</strong></p>
        {/if*}
    </div>
</div>
{/if}
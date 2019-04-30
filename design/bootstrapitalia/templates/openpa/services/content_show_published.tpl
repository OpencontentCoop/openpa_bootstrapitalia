<div class="row mt-5 mb-4">
    {if $node.object.published|gt(0)}
    <div class="col-6">
        <small>Data di pubblicazione:</small>
        <p class="font-weight-semibold text-monospace">{$node.object.published|datetime( 'custom', '%j %F %Y' )}</p>
    </div>
    {/if}
    {if $node|has_attribute('reading_time')}
    <div class="col-6">
        <small>Tempo di lettura:</small>
        <p class="font-weight-semibold">{$node|attribute('reading_time').content|wash()} min</p>
    </div>
    {/if}
</div>
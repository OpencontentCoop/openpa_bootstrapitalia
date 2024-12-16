{if count($data.rows)}
    {if and(is_set( $caption ), $caption)}<p class="h2 font-sans-serif">{$caption|wash}</p>{/if}
    <div class="cmp-accordion accordion font-sans-serif mb-3">
        {foreach $data.rows as $index => $row}
            <div class="accordion-item">
                <h2 class="accordion-header" id="heading-{concat($data.hash, '-', $index)}">
                    <button class="accordion-button collapsed" type="button"
                            data-bs-toggle="collapse" data-bs-target="#collapse-{concat($data.hash, '-', $index)}" aria-expanded="false" aria-controls="collapse-{concat($data.hash, '-', $index)}">
                        {$row[0]}
                    </button>
                </h2>
                <div id="collapse-{concat($data.hash, '-', $index)}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{concat($data.hash, '-', $index)}">
                    <div class="accordion-body">
                        {foreach $row as $cell offset 1}
                            <div class="mb-3">
                                {$cell}
                            </div>
                        {/foreach}
                    </div>
                </div>
            </div>
        {/foreach}
    </div>
{/if}
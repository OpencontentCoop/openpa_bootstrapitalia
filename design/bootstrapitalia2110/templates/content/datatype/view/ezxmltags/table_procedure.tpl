{if count($data.rows)}
    <div class="table-procedure-wrapper font-sans-serif mb-3">
        {if count($data.rows)|gt(1)}
            {if and(is_set( $caption ), $caption)}<p class="h2">{$caption|wash}</p>{/if}
            <div>
                <button type="button" data-procedure-toggle class="procedure-toggle">
                    <span data-procedure-show-all class="">Mostra tutto {display_icon('it-expand', 'svg', 'icon')}</span>
                    <span data-procedure-collapse-all style="display:none">Nascondi tutto {display_icon('it-collapse', 'svg', 'icon')}</span>
                </button>
            </div>
        {/if}
        {foreach $data.rows as $index => $row}
            {def $counter = $index|inc()}

            <div class="procedure-item">
                <div class="procedure-item-header d-flex align-items-center"
                     id="heading-{concat($data.hash, '-', $index)}">
                    <span class="procedure-number">{$counter}</span>
                    <span class="procedure-title lh-1">{$row[0]}</span>
                </div>
                <div class="procedure-item-body">
                    <div>
                        <button type="button"
                           data-bs-toggle="collapse"
                           data-bs-target="#collapse-{concat($data.hash, '-', $index)}"
                           aria-expanded="false"
                           class="procedure-toggle"
                           aria-controls="collapse-{concat($data.hash, '-', $index)}">
                            <span data-procedure-show>Mostra dettagli{display_icon('it-expand', 'svg', 'icon')}</span>
                            <span data-procedure-collapse style="display:none">Nascondi dettagli{display_icon('it-collapse', 'svg', 'icon')}</span>
                        </button>
                    </div>
                    <div id="collapse-{concat($data.hash, '-', $index)}"
                         data-procedure
                         class="procedure-item-content richtext-wrapper collapse"
                         role="region"
                         aria-labelledby="heading-{concat($data.hash, '-', $index)}">
                        {foreach $row as $cell offset 1}
                            <div class="mb-3">
                                {$cell}
                            </div>
                        {/foreach}
                    </div>
                </div>
            </div>
            {undef $counter}
        {/foreach}
    </div>
{/if}
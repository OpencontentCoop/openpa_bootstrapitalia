{if count($data.rows)}
<div class="it-timeline-wrapper font-sans-serif mb-3">
    <div class="row">
        {foreach $data.rows as $index => $row}
        <div class="col-12">
            <div class="timeline-element">
                <h3 class="it-pin-wrapper ">
                    <div class="pin-icon">
                        <svg class="icon" role="presentation" focusable="false">
                          <use href="{'images/svg/sprites.svg'|ezdesign('no')}#it-flag"></use>
                        </svg>
                    </div>
                    <div class="pin-text"><span>{$row[0]}</span></div>
                </h3>
                <div class="card-wrapper">
                    <div class="card">
                        <div class="card-body">
                            {foreach $row as $cell offset 1}
                                <div class="mb-3 card-text">
                                    {$cell}
                                </div>
                            {/foreach}
                        </div>
                    </div>
                </div>
            </div>
        </div>
        {/foreach}
    </div>
</div>
{/if}
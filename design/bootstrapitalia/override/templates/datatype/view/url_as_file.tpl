<div class="row mx-lg-n3">
    <div class="col-md-6 px-lg-3 pb-lg-3">
        <div class="card card-teaser shadow p-4 mt-3 rounded border">
            {display_icon('it-link', 'svg', 'icon')}
            <div class="card-body">
                <h5 class="card-title">
                    <a class="stretched-link" href="{$attribute.content|wash( xhtml )}" title="Vai al documento">
                        {if $attribute.data_text}{$attribute.data_text|wash( xhtml )}{else}{$attribute.content|wash( xhtml )}{/if}
                    </a>
                    {if $attribute.data_text}<small class="text-truncate d-block mw-100">{$attribute.content|wash( xhtml )}</small>{/if}
                </h5>
            </div>
        </div>
    </div>
</div>
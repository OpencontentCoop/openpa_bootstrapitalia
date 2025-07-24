<div class="card h-100 card-teaser p-3 position-relative overflow-hidden rounded border">
    <div class="card-body{if $data.image} pr-3 pe-3{/if}">
        <div class="etichetta mb-2">
            {display_icon('it-link', 'svg', 'icon')}
            <a class="text-decoration-none neutral-1-color-a8" href="{$data.source_uri|wash()}" title="{'Go to content'|i18n('bootstrapitalia')} {$data.source_name|wash()}">{$data.source_name|wash()}</a>
        </div>
        <h3 class="mb-3 h6 font-weight-normal">
            <a href="{$data.uri|wash()}" title="{'Go to content'|i18n('bootstrapitalia')} {$data.name|wash()}">{$data.name|wash()}</a>
        </h3>
        <div class="card-text">
            <p>{$data.abstract}</p>
            {if count($data.attachments)}
                <ul class="list-unstyled">
                    {foreach $data.attachments as $attachment}
                        <li><i class="fa fa-paperclip"></i> <a class="text-decoration-none" href="{$attachment.uri|wash()}">{$attachment.name|wash()}</a></li>
                    {/foreach}
                </ul>
            {/if}
        </div>
    </div>
    {if $data.image}
        <div class="avatar size-xl">
            <img src="{$data.image|wash()}" alt="{$data.name|wash()}">
        </div>
    {/if}
</div>
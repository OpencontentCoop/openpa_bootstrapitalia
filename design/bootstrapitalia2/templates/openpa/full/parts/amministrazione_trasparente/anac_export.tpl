{if count($exports)|gt(0)}
    <div class="anac-export mt-4">
        <h3 class="h5">{'ANAC publication schemas'|i18n('bootstrapitalia/anac_export')}</h3>
        <ul class="list-unstyled mb-2">
            {foreach $exports as $export}
                {foreach $export.latest_urls as $extension => $url}
                    <li class="mb-1">
                        {display_icon('it-file', 'svg', 'icon icon-sm icon-primary me-1')}<a class="btn btn-link p-0 text-decoration-underline" href="{$url|wash()}">{$export.label|wash()} ({$extension|upcase()|wash()})</a>
                        <small class="text-muted">— {'updated on'|i18n('bootstrapitalia/anac_export')} {$export.last_modified|wash()}</small>
                    </li>
                {/foreach}
            {/foreach}
        </ul>
        {def $has_history = false()}
        {foreach $exports as $export}
            {if count($export.versions)|gt(1)}
                {set $has_history = true()}
            {/if}
        {/foreach}
        {if $has_history}
            <a class="btn-link btn-xs p-0 text-decoration-underline" data-bs-toggle="collapse" data-toggle="collapse" href="#anac-export-versions" role="button" aria-expanded="false" aria-controls="anac-export-versions">
                {'Previous versions'|i18n('bootstrapitalia/anac_export')}
            </a>
            <div class="collapse mt-2" id="anac-export-versions">
                <ul class="list-unstyled ps-3 border-start mb-0">
                    {foreach $exports as $export}
                        {foreach $export.versions as $version}
                            {if not($version.isLatest)}
                                <li class="mb-1">
                                    <small class="text-muted">{$version.dataUltimaModifica|wash()} — {$export.label|wash()}</small>
                                    —
                                    {foreach $version.urls as $extension => $url}
                                        <a class="btn-link btn-xs p-0 text-decoration-underline font-monospace" href="{$url|wash()}">{$url|explode('/')|extract_right(1)|implode('')|wash()}</a>
                                    {/foreach}
                                </li>
                            {/if}
                        {/foreach}
                    {/foreach}
                </ul>
            </div>
        {/if}
    </div>
{/if}

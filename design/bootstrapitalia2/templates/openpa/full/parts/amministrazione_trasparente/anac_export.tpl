{if count($exports)|gt(0)}
<section class="callout w-100 mw-100 note anac-export">
    <h3 class="callout-title">{display_icon('it-file', 'svg', 'icon')}{'ANAC-compliant open data'|i18n('bootstrapitalia/anac_export')}</h3>
    {foreach $exports as $export}
        <div class="anac-export-schema mb-3">
            <p class="mb-2">
                {'Download the data for this section in the format required by ANAC'|i18n('bootstrapitalia/anac_export')}
                {foreach $export.latest_urls as $extension => $url}
                    <a class="btn btn-outline-primary btn-sm me-2" href="{$url|wash()}" target="_blank" rel="noopener">{$extension|upcase()|wash()}</a>
                {/foreach}
            </p>
            {if count($export.versions)|gt(1)}
                {def $collapse_id = concat('anac-export-versions-', $export.dom_id)}
                <button class="btn btn-link btn-sm p-0" type="button" data-bs-toggle="collapse" data-toggle="collapse" href="#{$collapse_id}" role="button" aria-expanded="false" aria-controls="{$collapse_id}">
                    {'Previous versions'|i18n('bootstrapitalia/anac_export')}
                </button>
                <div class="collapse" id="{$collapse_id}">
                    <ul class="list-unstyled mt-2 mb-0">
                        {foreach $export.versions as $version}
                            {if not($version.isLatest)}
                                <li>
                                    {$version.dataUltimaModifica|wash()}:
                                    {foreach $version.urls as $extension => $url}
                                        <a href="{$url|wash()}" target="_blank" rel="noopener">{$extension|upcase()|wash()}</a>
                                    {/foreach}
                                </li>
                            {/if}
                        {/foreach}
                    </ul>
                </div>
            {/if}
        </div>
    {/foreach}
</section>
{/if}

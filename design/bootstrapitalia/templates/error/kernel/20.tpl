<div class="it-hero-card it-hero-bottom-overlapping rounded px-lg-5 pb-5">
    <div class="row">
        <div class="col-12 col-lg-8 pl-lg-8">
            <h1 class="mb-3">{"Page not found"|i18n("bootstrapitalia/error")}</h1>
            <p class="lead">{"The page you’re looking for can’t be found."|i18n("bootstrapitalia/error")}</p>

            <form class="mb-5 col-lg-8" action="{'content/search'|ezurl(no)}" method="get">
                <div class="form-group floating-labels mb-0">
                    <div class="form-label-group">
                        <input type="text"
                               autocomplete="off"
                               class="form-control border"
                               id="search-text"
                               name="SearchText"
                               placeholder="{'Search'|i18n('bootstrapitalia')}"/>
                        <label class="" for="search-text">
                            {'Search in the site'|i18n('bootstrapitalia')}
                        </label>
                        <button type="submit" class="autocomplete-icon btn btn-link me-1 mr-1 mt-1" aria-label="{'Search'|i18n('openpa/search')}">
                            {display_icon('it-search', 'svg', 'icon')}
                        </button>
                    </div>
                </div>
            </form>

            <a href="{'/'|ezurl(no)}" class="text-decoration-none">
                {display_icon('it-arrow-left', 'svg', 'icon icon-sm mr-2 me-2 icon-primary')}
                <span style="vertical-align: middle;">{"Return to the home page"|i18n("bootstrapitalia/error")}</span>
            </a>
        </div>
    </div>
</div>


{if $embed_content}
    {$embed_content}
{/if}

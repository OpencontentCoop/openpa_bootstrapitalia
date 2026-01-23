{if $attribute.has_content}
    {def $groups = links_available_groups($attribute)}
    {def $groups_count = count($groups)}
    {if $in_accordion}
        {foreach $groups as $group}
            <ul class="link-list">
                {foreach links_list_by_group($attribute, $group) as $link}
                    <li>
                        <div class="cmp-icon-link mb-2">
                            <a class="list-item icon-left d-inline-block font-sans-serif{if $link.description|ne('')} mb-0{/if}"
                               href="{$link.link|wash()}"
                               data-focus-mouse="false">{*
                            *}<span class="list-item-title-icon-wrapper">{*
                            *}{display_icon('it-link', 'svg', 'icon icon-primary icon-sm me-1')}{*
                            *}<span class="list-item">{*
                            *}{$link.title|wash( xhtml )}{*
                            *}</span>{*
                            *}</span>{*
                            *}</a>
                            {if $link.description|ne('')}
                                <small class="d-block mt-2 mb-4" style="margin-left: 28px !important;">{$link.description|wash( xhtml )}</small>
                            {/if}
                        </div>
                    </li>
                {/foreach}
            </ul>
        {/foreach}
    {else}
        {if $groups_count|eq(1)}
            <div class="row mx-lg-n3">
                {foreach $groups as $group}
                    {def $link_list = links_list_by_group($attribute, $group)}
                    {if and($group|ne(''), $link_list|count()|gt(0))}
                        <div class="col-12 px-lg-3">
                            <h6 class="no_toc">{$group|wash()}</h6>
                        </div>
                    {/if}
                    <div class="col-12">
                        <div class="row row-cols-2 mx-0">
                        {foreach $link_list as $link}
                                <div class="col font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
                                    {display_icon('it-link', 'svg', 'icon')}
                                    <div class="card-body">
                                        <h5 class="card-title">
                                            <a class="stretched-link"
                                               href="{$link.link|wash()}">
                                                {$link.title|wash( xhtml )}
                                            </a>
                                            {if $link.description|ne('')}
                                                <small class="d-block my-2">{$link.description|wash( xhtml )}</small>
                                            {/if}
                                        </h5>
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    </div>
                    {undef $link_list}
                {/foreach}
            </div>
        {else}
            {ezscript_require('jquery.quicksearch.min.js')}
            {run-once}
                <script>{literal}
                  $(document).ready(function () {
                    $('.multilink-search').each(function () {
                      var searchInput = $(this).find('input');
                      var containerId = $(this).find('.link-list').attr('id');
                      searchInput.quicksearch('#' + containerId + ' li');
                    });
                  })
                    {/literal}</script>
            {/run-once}
            <div class="cmp-accordion accordion my-4 font-sans-serif" role="tablist">
                {foreach $groups as $index => $group}
                    {def $link_list = links_list_by_group($attribute, $group)}
                    {if $link_list|count()|eq(0)}{skip}{/if}
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="heading-{$attribute.id}-{$index}">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#collapse-{$attribute.id}-{$index}" aria-expanded="false"
                                    aria-controls="collapse-{$attribute.id}-{$index}">
                                {if $group|eq('')}{'More...'|i18n('design/base')}{else}{$group|wash()}{/if}
                            </button>
                        </h2>
                        <div id="collapse-{$attribute.id}-{$index}" class="accordion-collapse collapse" role="region"
                             aria-labelledby="heading-{$attribute.id}-{$index}">
                            <div class="accordion-body pb-2{if count($link_list)|gt(3)} multilink-search{/if}">
                                {if count($link_list)|gt(3)}
                                    <div class="form-group mb-4">
                                        <input type="text"
                                               class="form-control form-control-sm"
                                               placeholder="{'Search in'|i18n('bootstrapitalia')} {$group|wash()}"
                                               aria-invalid="false"/>
                                        <label class="d-none">
                                            {'Search in'|i18n('bootstrapitalia')} {$group|wash()}
                                        </label>
                                        <button class="autocomplete-icon btn btn-link"
                                                aria-label="{'Search'|i18n('openpa/search')}">
                                            {display_icon('it-search', 'svg', 'icon icon-sm')}
                                        </button>
                                    </div>
                                {/if}
                                <ul class="link-list mb-0" id="list-{$attribute.id}-{$index}">
                                    {foreach $link_list as $link}
                                        <li>
                                            <div class="cmp-icon-link mb-2 pb-2">
                                                <a class="list-item icon-left d-inline-block font-sans-serif mb-1"
                                                   href="{$link.link|wash()}">
                                                    <span class="list-item-title-icon-wrapper">
                                                        {display_icon('it-link', 'svg', 'icon icon-sm')}<span class="list-item">{$link.title|wash( xhtml )}</span>
                                                    </span>
                                                </a>
                                                {if $link.description|ne('')}
                                                    <small class="d-block my-2 ms-2">{$link.description|wash( xhtml )}</small>
                                                {/if}
                                            </div>
                                        </li>
                                    {/foreach}
                                </ul>
                                {*						</div>*}
                            </div>
                            {undef $link_list}
                        </div>
                    </div>
                {/foreach}
            </div>
        {/if}
    {/if}
    {undef $groups $groups_count}
{/if}

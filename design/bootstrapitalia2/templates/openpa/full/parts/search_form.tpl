<form class="mb-5" action="{'content/search'|ezurl(no)}" method="get">
    <div class="form-group floating-labels">
        <div class="form-label-group">
            <input type="text"
                   autocomplete="off"
                   class="form-control"
                   id="search-text"
                   name="SearchText"
                   placeholder="{'Search in'|i18n('bootstrapitalia')} {$current_node.name|wash()}"/>
            <label class="" for="search-text">
                {'Search in'|i18n('bootstrapitalia')} {$current_node.name|wash()}
            </label>
            <button type="submit" class="autocomplete-icon btn btn-link" aria-label="{'Search'|i18n('openpa/search')}">
                {display_icon('it-search', 'svg', 'icon')}
            </button>
        </div>
    </div>

    <div class="section-search-form-filters">
        <p class="small mb-1">{'Filters'|i18n('bootstrapitalia')}</p>
        <a href="#" class="chip chip-lg selected no-minwith"
           data-section_subtree_group="all">
            <span class="chip-label">{'All'|i18n('bootstrapitalia')}</span>
        </a>
        <a href="#"
           class="btn btn-outline-primary btn-icon btn-xs align-top ml-1 mt-1"
           id="toggleSectionSearch"
           {if is_set($subtree_preselect)}data-subtree_preselect="{$subtree_preselect|wash()}"{/if}
           data-section_subtree="{$current_node.node_id}">
            {display_icon('it-plus', 'svg', 'icon icon-primary mr-1')} {'Add filter'|i18n('editorialstuff/dashboard')}
        </a>
        <input type="hidden"
               name="SubtreeBoundary"
               value="{$current_node.node_id}" />
    </div>
</form>
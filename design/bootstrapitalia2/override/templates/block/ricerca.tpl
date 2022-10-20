<div class="section section-muted p-0 py-5 useful-links-section">
    <div class="container">
        <div class="row d-flex justify-content-center">
            <div class="col-12 col-lg-6">
                <div class="cmp-input-search">
                    <form action="{'/content/search/'|ezurl(no)}" method="get" class="form-group autocomplete-wrapper mb-2 mb-lg-4">
                        <div class="input-group">
                            <label for="autocomplete-autocomplete-three" class="visually-hidden">{'Search'|i18n('design/base')}</label>
                            <input type="search" class="autocomplete form-control" placeholder="{$block.name|wash()}" id="autocomplete-autocomplete-three" name="autocomplete-three" data-bs-autocomplete="[]" data-focus-mouse="false">

                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit" id="button-3">{'Search'|i18n('design/base')}</button>
                            </div>

                            <span class="autocomplete-icon" aria-hidden="true">
                                {display_icon('it-search', 'svg', 'icon icon-sm icon-primary')}
                            </span>
                        </div>
                    </form>
                </div>
                {if count($block.valid_nodes)|gt(0)}
                <div class="link-list-wrapper">
                    <div class="link-list-heading text-uppercase mb-3 ps-0">Link utili</div>
                    <ul class="link-list" role="list">
                        {foreach $block.valid_nodes as $valid_node}
                        <li role="listitem">
                            {node_view_gui content_node=$valid_node a_class="list-item mb-3 active ps-0" span_class="text-button-normal" view=text_linked}
                        </li>
                        {/foreach}
                    </ul>
                </div>
                {/if}
            </div>
        </div>
    </div>
</div>
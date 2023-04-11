<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <h3 class="openpa-widget-title"><span>{$block.name}</span></h3>
    <div class="openpa-widget-content">
        <form id="search-form-{$block.id}" action="{'ezajax/search'|ezurl('no')}" method="post">
            <input id="search-string-{$block.id}" type="text" name="SearchStr" class="form-control" value="" />

            <ul class="list-unstyled margin-top" id="search-results-{$block.id}"></ul>

            <div class="form-group margin-top clearfix">
            <input id="search-button-{$block.id}" class="btn btn-primary pull-right" type="submit" name="SearchButton" value="{'Search'|i18n('openpa_designitalia')}" />
            </div>
        </form>

        {ezscript_require( array( 'ezjsc::yui3', 'ezjsc::yui3io', 'ezajaxsearch.js' ) )}

        <script>
        eZAJAXSearch.cfg = {ldelim}
                                searchstring: '#search-string-{$block.id}',
                                searchbutton: '#search-button-{$block.id}',
                                searchresults: '#search-results-{$block.id}',
                                resulttemplate: '<li class="item-title"><small>{ldelim}class_name{rdelim}</small><br/><a href="{ldelim}url_alias{rdelim}">{ldelim}title{rdelim}</a></li>'
                           {rdelim};
        eZAJAXSearch.init();
        </script>
    </div>
</div>

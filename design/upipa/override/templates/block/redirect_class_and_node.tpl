<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    <div class="openpa-widget-content">
        <form id="search-form-{$block.id}" action="{'ezajax/search'|ezurl('no')}" method="post">
            <input class="form-control" id="search-string-{$block.id}" type="text" name="SearchStr" value="" />
            <input id="search-button-{$block.id}" class="button" type="submit" name="SearchButton" value="Search" />
        </form>

        <div id="search-results-{$block.id}"></div>
        {ezscript_require( array( 'ezjsc::yui3', 'ezjsc::yui3io', 'ezajaxsearch.js' ) )}

        <script>
            eZAJAXSearch.cfg = {ldelim}
                searchstring: '#search-string-{$block.id}',
                searchbutton: '#search-button-{$block.id}',
                searchresults: '#search-results-{$block.id}',
                resulttemplate: '<div class="result-item float-break"><div class="item-title"><a href="{ldelim}url_alias{rdelim}">{ldelim}title{rdelim}</a></div><div class="item-published-date">[{ldelim}class_name{rdelim}] {ldelim}date{rdelim}</div></div>'
                {rdelim};
            eZAJAXSearch.init();
        </script>
    </div>
</div>

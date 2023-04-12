{def $max_checkbox_items = 10}

{def $current = false()}
{if is_set($view_parameters.view)}
    {set $current = $view_parameters.view}
{/if}

{def $classes = subtree_classes($node)}
{def $blacklist_classes = openpaini( 'ExcludedClassesAsChild', 'FromFolder', array())}
{def $search_root_node_id = $node.node_id}
{if $openpa.content_virtual.folder}
    {set $search_root_node_id = $openpa.content_virtual.folder.subtree|implode(',')}
    {if $openpa.content_virtual.folder.classes|count()}
        {set $classes = fetch( 'class', 'list', hash( 'class_filter', $openpa.content_virtual.folder.classes ) )}
    {/if}
{/if}

{def $search_attributes = find_common_class_attributes($classes, 'search_form')}

<section>
    <form id="main-search">
        <div class="container">
            <div class="row pt-3 pb-4">
                <div class="col">
                    <div class="input-group">
                        <input type="text" name="q" class="form-control border-top border-bottom border-left main-input" style="border-top-left-radius: 4px;border-bottom-left-radius: 4px;"
                               aria-label="Search input">
                        <div class="input-group-append">
                            <button class="btn btn-link border-top border-right border-bottom" type="submit">
                                {display_icon('it-search', 'svg', 'icon icon-sm')}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {if count($classes)|gt(1)}
        <div class="container">
            <div class="row pb-4" style="align-items: stretch;">
                {foreach $classes as $class}
                    {def $icon = class_extra_parameters($class.identifier, 'bootstrapitalia_icon').icon}
                    <div class="col-12 col-sm-12 col-md pb-2 pb-md-0">
                        <a href="#" data-trigger="class-{$class.id}" data-class="{$class.identifier}" class="rounded shadow bg-{if $current|eq($class.identifier)}primary{else}secondary{/if} text-decoration-none h-100 d-block px-1 py-2 text-center">
                            {if $icon}
                                {display_icon($icon, 'svg', 'icon icon-white icon-xl')}
                            {/if}
                            <small class="text-white m-0 d-block" style="font-size:.8em">{$class.name|wash()}</small>
                            <div class="hide" data-icon_class="{$class.identifier}" data-icon="{$icon}"></div>
                            <div class="hide" data-class_name="{$class.identifier}" data-name="{$class.name|wash()}"></div>
                        </a>
                    </div>
                    {undef $icon}
                {/foreach}
            </div>
        </div>
        {elseif count($classes)|gt(0)}
        <input type="hidden" data-trigger="class-{$classes[0].id}" data-class="{$classes[0].identifier}" class="bg-primary" />
        {/if}

        <div class="d-block d-lg-none d-xl-none text-center">
            <a href="#filtersCollapse" role="button" class="btn btn-default btn-md text-uppercase collapsed" data-toggle="collapse" aria-expanded="false" aria-controls="filtersCollapse">Open/close search filters</a>
        </div>

        {def $has_filters = false()}
        {foreach $search_attributes as $type => $attributes}
            {if $attributes|count()}
                {set $has_filters = true()}
                {break}
            {/if}
        {/foreach}

        <section class="bg-100 border-top">
            <div class="container">
                <div class="row{if $has_filters} row-column-border row-column-menu-left attribute-list border-0 mt-0{/if}">

                    {if $has_filters}
                    <aside class="col-lg-3 d-lg-flex d-xl-flex collapse" style="position: relative;" id="filtersCollapse">
                        <div class="pt-lg-5 card px-3">

                            {foreach $search_attributes as $type => $attributes}
                                {foreach $attributes as $attribute}
                                    {if array('ezstring', 'ezemail', 'eztext', 'ezinteger')|contains($attribute.data_type_string)}
                                        <div class="form-group floating-labels mb-1 {$type}">
                                            <div class="form-label-group">
                                                <input type="text"
                                                       class="form-control"
                                                       id="{$attribute.identifier}"
                                                       name="{$attribute.identifier}"
                                                       value=""
                                                       placeholder="Find by {$attribute.name|downcase|wash()}"
                                                       aria-invalid="false"/>
                                                <label for="{$attribute.identifier}">Find by {$attribute.name|downcase|wash()}</label>
                                            </div>
                                        </div>

                                    {elseif and($attribute.data_type_string|eq('eztags'), $attribute.data_int1)}
                                        {def $facets = api_search(concat('facets [raw[attr_',$attribute.identifier,'_lk]|alpha|600] limit 1')).facets
                                        $facets_count = $facets[0].data|count()}
                                        {if $facets_count}
                                            <div class="pt-4 pt-lg-0 {$type}">
                                                <h6>{$attribute.name|wash()}</h6>
                                                <div class="mb-3">
                                                    {foreach $facets[0].data as $name => $count max $max_checkbox_items}
                                                        <div class="form-check custom-control custom-checkbox">
                                                            <input name="{$attribute.identifier}"
                                                                   data-checkbox-container=""
                                                                   id="{$attribute.identifier}-{$name|slugize}"
                                                                   value="{$name|wash()}"
                                                                   class="custom-control-input"
                                                                   type="checkbox">
                                                            <label class="custom-control-label text-capitalize"
                                                                   for="{$attribute.identifier}-{$name|slugize}">
                                                                {$name|wash()}
                                                            </label>
                                                        </div>
                                                    {/foreach}
                                                    {if $facets_count|gt($max_checkbox_items)}
                                                        <a class="text-decoration-none" href="#more-{$attribute.identifier}" data-toggle="collapse" aria-expanded="false" aria-controls="more-{$attribute.identifier}">
                                                            {display_icon('it-more-items', 'svg', 'icon icon-primary right')} <small>SHOW/HIDE MORE ITEMS</small>
                                                        </a>
                                                        <div class="collapse" id="more-{$attribute.identifier}">
                                                            {foreach $facets[0].data as $name => $count offset $max_checkbox_items}
                                                                <div class="form-check custom-control custom-checkbox">
                                                                    <input name="{$attribute.identifier}"
                                                                           data-checkbox-container=""
                                                                           id="{$attribute.identifier}-{$name|slugize}"
                                                                           value="{$name|wash()}"
                                                                           class="custom-control-input"
                                                                           type="checkbox">
                                                                    <label class="custom-control-label text-capitalize"
                                                                           for="{$attribute.identifier}-{$name|slugize}">
                                                                        {$name|wash()}
                                                                    </label>
                                                                </div>
                                                            {/foreach}
                                                        </div>
                                                    {/if}
                                                </div>
                                            </div>
                                        {/if}
                                        {undef $facets $facets_count}

                                    {elseif $attribute.data_type_string|eq('ezobjectrelationlist')}
                                        {def $items_count = 80
                                        $parent_node_id = cond(is_set($attribute.content.default_placement.node_id), $attribute.content.default_placement.node_id, 1)
                                        $sort_array = array('name', true())}
                                        {if $parent_node_id|ne(1)}
                                            {set $sort_array = fetch(content, node, hash(node_id, $parent_node_id)).sort_array}
                                        {/if}
                                        {if $attribute.content.class_constraint_list|count()}
                                            {set $items_count = fetch(content, tree_count, hash('parent_node_id', $parent_node_id, 'class_filter_type', 'include', 'class_filter_array', $attribute.content.class_constraint_list))}
                                        {/if}
                                        {if $items_count|lt(80)}
                                            <div class="pt-4 pt-lg-0 {$type}">
                                                <h6>{$attribute.name|wash()}</h6>
                                                <div class="mb-3">
                                                    {def $items = fetch(content, tree, hash('parent_node_id', $parent_node_id, 'class_filter_type', 'include', 'class_filter_array', $attribute.content.class_constraint_list, 'sort_by', $sort_array))}
                                                    {foreach $items as $item max $max_checkbox_items}
                                                        <div class="form-check custom-control custom-checkbox">
                                                            <input name="{$attribute.identifier}.id"
                                                                   id="{$attribute.identifier}-{$item.contentobject_id}"
                                                                   value="{$item.contentobject_id}"
                                                                   class="custom-control-input"
                                                                   type="checkbox">
                                                            <label class="custom-control-label text-capitalize"
                                                                   for="{$attribute.identifier}-{$item.contentobject_id}">
                                                                {$item.name|wash()}
                                                            </label>
                                                        </div>
                                                    {/foreach}
                                                    {if $items_count|gt($max_checkbox_items)}
                                                        <a class="text-decoration-none" href="#more-{$attribute.identifier}" data-toggle="collapse" aria-expanded="false" aria-controls="more-{$attribute.identifier}">
                                                            {display_icon('it-more-items', 'svg', 'icon icon-primary right')} <small>SHOW/HIDE MORE ITEMS</small>
                                                        </a>
                                                        <div class="collapse" id="more-{$attribute.identifier}">
                                                            {foreach $items as $item offset $max_checkbox_items}
                                                                <div class="form-check custom-control custom-checkbox">
                                                                    <input name="{$attribute.identifier}.id"
                                                                           id="{$attribute.identifier}-{$item.contentobject_id}"
                                                                           value="{$item.contentobject_id}"
                                                                           class="custom-control-input"
                                                                           type="checkbox">
                                                                    <label class="custom-control-label text-capitalize"
                                                                           for="{$attribute.identifier}-{$item.contentobject_id}">
                                                                        {$item.name|wash()}
                                                                    </label>
                                                                </div>
                                                            {/foreach}
                                                        </div>
                                                    {/if}
                                                    {undef $items}
                                                </div>
                                            </div>
                                        {else}
                                            <div class="form-group floating-labels mb-1 {$type}">
                                                <div class="form-label-group">
                                                    <input type="text"
                                                           class="form-control"
                                                           id="{$attribute.identifier}"
                                                           name="{$attribute.identifier}.name"
                                                           value=""
                                                           placeholder="{$attribute.name|wash()}"
                                                           aria-invalid="false"/>
                                                    <label for="{$attribute.identifier}">{$attribute.name|wash()}</label>
                                                </div>
                                            </div>
                                        {/if}
                                        {undef $items_count $parent_node_id $sort_array}

                                    {elseif $attribute.data_type_string|eq('ezselection')}
                                        <div class="pt-4 pt-lg-0 {$type}">
                                            <h6>{$attribute.name|wash()}</h6>
                                            <div class="mb-3">
                                                {foreach $attribute.content.options as $option}
                                                    <div class="form-check custom-control custom-checkbox">
                                                        <input name="{$attribute.identifier}"
                                                               id="{$attribute.identifier}-{$option.id}"
                                                               value="{$option.name|wash()}"
                                                               class="custom-control-input"
                                                               type="checkbox">
                                                        <label class="custom-control-label text-capitalize"
                                                               for="{$attribute.identifier}-{$option.id}">
                                                            {$option.name|wash()}
                                                        </label>
                                                    </div>
                                                {/foreach}
                                            </div>
                                        </div>

                                    {elseif $attribute.data_type_string|eq('ezdate')}
                                        <div class="it-datepicker-wrapper {$type}">
                                            <div class="form-group mb-3 bg-white">
                                                <input class="form-control it-date-datepicker"
                                                       name="{$attribute.identifier}"
                                                       id="{$attribute.identifier}"
                                                       placeholder="{$attribute.name|wash()}"
                                                       style="height: 3.125rem;padding: .75rem;"
                                                       type="text" />
                                                <label class="invisible" style="height: 1px;" for="{$attribute.identifier}">
                                                    {$attribute.name|wash()}
                                                </label>
                                            </div>
                                        </div>
                                    {/if}

                                {/foreach}
                            {/foreach}
                        </div>
                    </aside>
                    {/if}
                    <div class="col{if $has_filters}-lg-9 pr-0{/if}">
                        <div class="sorters row"{if $has_filters|not()} style="margin-top: 50px;"{/if}>
                            <div class="col col-lg-2">
                                <div class="bootstrap-select-wrapper">
                                    <label>Totale risultati</label>
                                    <div class="pl-2 pt-2 font-weight-bold" data-count></div>
                                </div>
                            </div>
                            <div class="col col-lg-{if $has_filters|not()}2{else}4{/if}">
                                <div class="bootstrap-select-wrapper">
                                    <label>Ordina per</label>
                                    <select data-param="sort">
                                        <option value="published">Data di pubblicazione</option>
                                        <option selected="selected" value="name">Titolo</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col col-lg-2">
                                <div class="bootstrap-select-wrapper">
                                    <label{if $has_filters} class="invisible"{/if}>Ordinamento</label>
                                    <select data-param="direction">
                                        <option value="desc">Z-A</option>
                                        <option selected="selected" value="asc">A-Z</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="py-4 results"></div>
                    </div>
                </div>
            </div>
        </section>
    </form>
</section>

{ezscript_require(array('jsrender.js','handlebars.min.js'))}

<style>
    #main-search .bootstrap-select-wrapper {ldelim}
        white-space: nowrap;
        border-top-left-radius: 4px;
        border-bottom-left-radius: 4px;
        height: 45px;
    {rdelim}
    #main-search .bootstrap-select-wrapper .bootstrap-select{ldelim}
        padding: 0 24px;
    {rdelim}
    #main-search .bootstrap-select-wrapper .dropdown-menu.show{ldelim}
        left: -24px !important;
    {rdelim}
    #main-search .bootstrap-select-wrapper button .filter-option::after {ldelim}
        content: none
    {rdelim}
    #main-search .bootstrap-select-wrapper button.dropdown-toggle::after {ldelim}
        margin-left: 10px
    {rdelim}
    #main-search .main-input {ldelim}
        height: 45px;
    {rdelim}
    #main-search .it-date-datepicker::placeholder{ldelim}
        font-weight: 600;
    {rdelim}
    #main-search .it-datepicker-wrapper .input-group .datepicker-button .icon{ldelim}
        top: 65%;
    {rdelim}
    #main-search .form-check [type="checkbox"]:not(:checked) + label::after {ldelim}
        background: #fff;
    {rdelim}
    {if count($classes)|gt(1)}
    {foreach $classes as $class}#main-search .class-{$class.id}{delimiter},{/delimiter}{/foreach}{ldelim}
        display: none;
    {rdelim}
    {/if}
    #main-search .sorters .bootstrap-select {ldelim}
        padding-left: 0;
    {rdelim}
</style>

{literal}
    <script id="tpl-results" type="text/x-jsrender">
	<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-2">
	{{for searchHits}}
		{{:~i18n(extradata, 'view')}}
	{{/for}}
	</div>

	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Esempio di navigazione della pagina">
	            <ul class="pagination">
	                {{if prevPageQuery}}
	                <li class="page-item">
	                    <a class="page-link prevPage" data-page="{{>prevPage}}" href="#">
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
	                        </svg>
	                        <span class="text-uppercase">Previous</span>
	                    </a>
	                </li>
	                {{/if}}
	                <!--{{for pages ~current=currentPage}}
						<li class="page-item"><a href="#" class="page-link page" data-page="{{:query}}"{{if ~current == query}} aria-current="page"{{/if}}>{{:page}}</a></li>
					{{/for}}-->
					{{if nextPageQuery }}
	                <li class="page-item">
	                    <a class="page-link nextPage" data-page="{{>nextPage}}" href="#">
	                        <span class="text-uppercase">Next</span>
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
	                        </svg>
	                    </a>
	                </li>
	                {{/if}}
	            </ul>
	        </nav>
	    </div>
	</div>
	{{/if}}
</script>
    <script id="tpl-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
</div>
</script>
    <script id="tpl-empty" type="text/x-jsrender">
<div class="col-xs-12 text-center">
    <a href="#" class="text-decoration-none" data-reset><i class="fa fa-times"></i> No results found</a>
</div>
</script>

<script>
    $.views.helpers($.extend({}, $.opendataTools.helpers, {
        'shorten': function (text, maxLength) {
            var ellipsis = "...";
            text = $.trim(text);

            if (text.length > maxLength){
                text = text.substring(0, maxLength - ellipsis.length)
                return text.substring(0, text.lastIndexOf(" ")) + ellipsis;
            }

            return text;
        }
    }));
    {/literal}
    {def $current_language=ezini('RegionalSettings', 'Locale')}
    {def $moment_language = $current_language|explode('-')[1]|downcase()}
    $.opendataTools.settings('accessPath', "{''|ezurl(no)}");
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('locale', "{$moment_language}");
    var SearchRootNodeId = {$search_root_node_id};
    {literal}
    $(document).ready(function() {
        var form = $('#main-search');
        var triggers = form.find('[data-trigger]');
        var currentPage = 0;
        var queryPerPage = [];
        var limitPagination = 12;
        var baseQuery;
        var resultsContainer = form.find('.results');
        var template = $.templates('#tpl-results');
        var spinner = $.templates('#tpl-spinner');
        var noResults = $.templates('#tpl-empty');
        var baseUrl = $.opendataTools.settings('accessPath');
        if (baseUrl !== '/'){
            baseUrl += '/';
        }

        form.find('.it-date-datepicker').datepicker({
            inputFormat: ["dd/MM/yyyy"],
            outputFormat: 'yyyy-MM-dd',
        });
        triggers.on('click', function (e) {
            var self = $(this);
            var target = self.data('trigger');
            triggers.each(function () {
                var other = $(this);
                if (other.data('trigger') !== target) {
                    other.removeClass('bg-primary').addClass('bg-secondary');
                    $('.' + other.data('trigger')).hide().find('input').each(function(){
                        var input = $(this);
                        if (input.attr('type') === 'checkbox' || input.attr('type') === 'radio'){
                            input.prop('checked',false);
                        }else{
                            input.val('');
                        }
                    });

                }
            });
            if (self.hasClass('bg-primary')){
                self.removeClass('bg-primary').addClass('bg-secondary');
                var input = $('.'+target).hide().find('input').each(function(){
                    var input = $(this);
                    if (input.attr('type') === 'checkbox' || input.attr('type') === 'radio'){
                        input.prop('checked',false);
                    }else{
                        input.val('');
                    }
                });
            }else{
                self.addClass('bg-primary').removeClass('bg-secondary');
                $('.'+target).show();
            }
            form.trigger('submit');
            e.preventDefault();
        });

        form.find('[data-param], input[type="checkbox"], input[type="radio"]').on('change', function () {
            form.trigger('submit');
        });

        form.on('submit', function (e) {
            var classes = [];
            var selectedClasses = [];
            triggers.each(function () {
                classes.push($(this).data('class'));
                if($(this).hasClass('bg-primary')){
                    selectedClasses.push($(this).data('class'));
                }
            });
            if (selectedClasses.length > 0){
                classes = selectedClasses;
            }
            var formSerializeArray = $(this).serializeArray();
            var d = {};
            $.each(formSerializeArray, function () {
                if (this.value.length > 0) {
                    var value = this.value.replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
                    if (d[this.name] !== undefined) {
                        d[this.name].push(value);
                    } else {
                        d[this.name] = [value];
                    }
                }
            });
            var query = [];
            query.push('subtree ['+SearchRootNodeId+']');
            if (classes.length > 0) {
                query.push('classes [' + classes.join(',') + ']');
            }
            query.push('raw[meta_node_id_si] != '+ SearchRootNodeId);
            //query.push('raw[meta_depth_si] = '+ (SearchRootNodeDepth + 1));
            $.each(d, function (i,v) {
                if (i === 'q')
                    query.push(i+' = \''+ v.join(' ') + '\'');
                else
                    query.push(i+' in [\''+ v.join('\',\'') + '\']');
            });
            var sort = $('[data-param="sort"]').val();
            var direction = $('[data-param="direction"]').val();
            query.push('sort ['+sort+ '=>'+direction+']');

            baseQuery = query.join(' and ');
            currentPage = 0;
            queryPerPage = [];
            loadSearchBlockContents();

            e.preventDefault();
        });

        var findSearchBlockIcon = function(content){
            var definition = form.find('[data-icon_class="'+content.metadata.classIdentifier+'"]');
            if (definition.length && definition.data('icon').length){
                return definition.data('icon');
            }
            return null;
        };

        var findSearchBlockClassName = function(content){
            var definition = form.find('[data-class_name="'+content.metadata.classIdentifier+'"]');
            if (definition.length && definition.data('name').length){
                return definition.data('name');
            }
            return null;
        };

        var loadSearchBlockContents = function(){
            var paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage*limitPagination;
            resultsContainer.html($(spinner.render({})));
            $.ajax({
                type: "GET",
                url: $.opendataTools.settings('endpoint').search + paginatedQuery,
                data: {
                    view: 'card_teaser',
                    q: paginatedQuery
                },
                dataType: 'json',
                success: function (response,textStatus,jqXHR){
                    form.find('[data-count]').html(response.totalCount);
                    if (response.totalCount === 0){
                        resultsContainer.html($(noResults.render(response)));
                        resultsContainer.find('[data-reset]').on('click', function (e) {
                            resetSearchBlockContents();
                            e.preventDefault();
                        });
                    }else {
                        queryPerPage[currentPage] = paginatedQuery;
                        response.currentPage = currentPage;
                        response.prevPage = currentPage - 1;
                        response.nextPage = currentPage + 1;
                        var pagination = response.totalCount > 0 ? Math.ceil(response.totalCount / limitPagination) : 0;
                        var pages = [];
                        var i;
                        for (i = 0; i < pagination; i++) {
                            queryPerPage[i] = baseQuery + ' and limit ' + limitPagination + ' offset ' + (limitPagination * i);
                            pages.push({'query': i, 'page': (i + 1)});
                        }
                        response.pages = pages;
                        response.pageCount = pagination;

                        response.prevPageQuery = jQuery.type(queryPerPage[response.prevPage]) === "undefined" ? null : queryPerPage[response.prevPage];

                        $.each(response.searchHits, function () {
                            this.icon = findSearchBlockIcon(this);
                            this.className = findSearchBlockClassName(this);
                            this.baseUrl = baseUrl;
                        });
                        var renderData = $(template.render(response));
                        resultsContainer.html(renderData);

                        resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
                            currentPage = $(this).data('page');
                            loadSearchBlockContents();
                            e.preventDefault();
                        });
                    }
                },
                error: function (jqXHR) {
                    let error = {
                        error_code: jqXHR.status,
                        error_message: jqXHR.statusText
                    };
                    if(error.error_message || error.error_code){
                        console.log(error.error_code, error.error_message);
                        return true;
                    }
                    return false;
                }
            });
        };

        var resetSearchBlockContents = function(){
            form.find('input').each(function () {
                var input = $(this);
                if (input.attr('type') === 'checkbox' || input.attr('type') === 'radio'){
                    input.prop('checked',false);
                }else{
                    input.val('');
                }
            });
            form.trigger('submit');
        };

        resetSearchBlockContents();

    });
</script>
{/literal}
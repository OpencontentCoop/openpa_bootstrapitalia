;(function ($, window, document, undefined) {
  'use strict';
  var pluginName = 'searchPeopleByRole',
    defaults = {
      'localAccessPrefix': '/',
      'limitPagination': 8,
      'itemsPerRow': 2,
      'spinnerTpl': '#tpl-remote-gui-spinner',
      'listTpl': '#tpl-remote-gui-list',
      'query': null,
      'subQuery': null,
      'facetQuery': null,
      'searchApi': '/api/opendata/v2/content/search/',
      'view': 'card_teaser',
      'context': null,
      'facets': [],
      'removeExistingEmptyFacets': true,
      'i18n': {
        placeholder: 'Select item',
        noResults: 'No results found',
        statusQueryTooShort: 'Type in ${minQueryLength} or more characters for results',
        statusSelectedOption: '${selectedOption} ${index + 1} of ${length} is highlighted',
        assistiveHint: "When autocomplete results are available use up and down arrows to review and enter to select. Touch device users, explore by touch or with swipe gestures.",
        selectedOptionDescription: 'Press Enter or Space to remove selection'
      }
    };

  function Plugin(element, options) {
    this.settings = $.extend({}, defaults, options);
    this.container = $(element);
    this.baseId = this.container.attr('id')+'-';
    let prefix = '/';
    if ($.isFunction($.ez)) {
      prefix = $.ez.root_url;
    }
    var localAccessPrefix = this.settings.localAccessPrefix.substr(1);
    this.searchUrl = localAccessPrefix.length === 0 ? '/opendata/api/content/search/' : this.settings.localAccessPrefix + '/opendata/api/content/search/';
    this.searchUrl += '?view=' + this.settings.view + '&q='
    this.searchForm = this.container.find('.search-form');
    this.currentPage = 0;
    this.queryPerPage = [];
    let paginationStyle = $.inArray(this.settings.view, ['latest_messages_item','accordion','text_linked']) !== -1 ? 'append' : 'reload';
    this.spinnerTpl = $($.templates(this.settings.spinnerTpl).render({paginationStyle:paginationStyle}));
    this.listTpl = $.templates(this.settings.listTpl);
    this.ajaxDatatype = 'json';
    this.paginationStyle = paginationStyle;
    let plugin = this;

    plugin.searchForm.find('button').on('click', function (e) {
      plugin.currentPage = 0;
      plugin.runSearch();
      e.preventDefault();
    });
    plugin.searchForm.find('input').on('keydown', function (e) {
      if (e.keyCode === 13) {
        plugin.currentPage = 0;
        plugin.runSearch();
        e.preventDefault();
      }
    });

    plugin.buildFacets();
    plugin.runSearch();
  }

  $.extend(Plugin.prototype, {

    buildQuery: function () {
      let plugin = this;
      let baseQuery = plugin.settings.query;
      let baseSubQuery = plugin.settings.subQuery;
      if (plugin.searchForm.find('input').length > 0) {
        let q = plugin.searchForm.find('input').val();
        if (q.length > 0) {
          q = q.replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
          baseQuery = 'q = \'' + q + '\' and ' + baseQuery;
        }
      }
      let hasFacets = false
      if (plugin.settings.facets.length > 0) {
        $.each(plugin.settings.facets, function (index, facetField) {
          let facetSelect = plugin.container.find('select[data-facets_select="facet-'+index+'"]');
          let values = facetSelect.val();
          let type = facetSelect.data('datatype') || 'string';
          if (values && values.length > 0) {
            if (!$.isArray(values)){
              values = [values];
            }
            if (type === 'string') {
              baseSubQuery = facetField + ' in [\'"' + values.join('"\',\'"') + '"\'] and ' + baseSubQuery;
            }else{
              baseSubQuery = facetField + " in ['" + values.join("','") + "'] and " + baseSubQuery;
            }
            hasFacets = true
          }
        });
      }
      if (hasFacets){
        baseQuery += ' and id in [{'+baseSubQuery+'}]'
      }
      if (plugin.searchForm.find('input').length > 0 && plugin.searchForm.find('input').val().length > 0) {
        baseQuery += ' and offset 0 sort [score=>desc]'; //workaround se già presente il parametro sort in query
      }
      return baseQuery;
    },

    buildPaginatedQueryParams: function (limit, offset){
      let plugin = this;
      return plugin.buildQuery() + ' and limit ' + limit + ' offset ' + offset;
    },

    buildFacetedQueryParams: function (){
      let plugin = this;
      return plugin.settings.facetQuery;
    },

    detectError: function(response,jqXHR){
      if(response.error_message || response.error_code){
        console.log(response.error_code, response.error_message);
        return true;
      }
      return false;
    },

    renderList: function (template) {
      let plugin = this;
      let resultsContainer = plugin.container.find('#'+plugin.baseId+'list');
      let limit = plugin.settings.limitPagination;
      let offset = plugin.currentPage * plugin.settings.limitPagination;
      let paginatedQuery = plugin.buildPaginatedQueryParams(limit, offset);

      if (plugin.currentPage === 0 || plugin.paginationStyle === 'reload') {
        resultsContainer.html(plugin.spinnerTpl);
      } else {
        resultsContainer.find('.nextPage').replaceWith(plugin.spinnerTpl);
      }

      $.ajax({
        type: "GET",
        url: plugin.searchUrl + paginatedQuery,
        dataType: plugin.ajaxDatatype,
        success: function (response,textStatus,jqXHR) {
          if (!plugin.detectError(response,jqXHR)){
            plugin.queryPerPage[plugin.currentPage] = paginatedQuery;
            response.currentPage = plugin.currentPage;
            response.prevPage = plugin.currentPage - 1;
            response.nextPage = plugin.currentPage + 1;
            let pagination = response.totalCount > 0 ? Math.ceil(response.totalCount / plugin.settings.limitPagination) : 0;
            let pages = [];
            let i;
            for (i = 0; i < pagination; i++) {
              plugin.queryPerPage[i] = plugin.buildPaginatedQueryParams(plugin.settings.limitPagination, (plugin.settings.limitPagination * i));
              pages.push({'query': i, 'page': (i + 1)});
            }
            response.pages = pages;
            response.pageCount = pagination;
            response.prevPageQuery = jQuery.type(plugin.queryPerPage[response.prevPage]) === 'undefined' ? null : plugin.queryPerPage[response.prevPage];
            $.each(response.searchHits, function(){
              this.fields = plugin.settings.fields;
              this.remoteUrl = plugin.settings.remoteUrl;
              this.useCustomTpl = plugin.settings.useCustomTpl;
              this.customTpl = plugin.settings.customTpl;
            });
            response.view = plugin.settings.view;
            response.paginationStyle = plugin.paginationStyle;
            response.autoColumn = plugin.settings.itemsPerRow !== 'auto' && $.inArray(plugin.settings.view, ['card_teaser', 'banner_color', 'card_children', 'card_simple']) > -1;
            response.itemsPerRow = plugin.settings.itemsPerRow;

            let renderData = $(template.render(response));
            if (plugin.currentPage === 0 || plugin.paginationStyle === 'reload') {
              resultsContainer.html(renderData);
            }else{
              resultsContainer.find('.spinner').replaceWith(renderData);
            }
            if (typeof bootstrap === 'object' && plugin.settings.itemsPerRow === 'auto' && plugin.paginationStyle === 'reload') {
              new bootstrap.Masonry(renderData[0]);
            }
            resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
              plugin.currentPage = $(this).data('page');
              if (plugin.currentPage >= 0){
                plugin.renderList(template);
              }
              e.preventDefault();
            });
            let more = $('<li class="page-item"><span class="page-link">...</span></li');
            let displayPages = resultsContainer.find('.page[data-page_number]');

            let currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
            let length = 3;
            if (displayPages.length > (length + 2)) {
              if (currentPageNumber <= (length - 1)) {
                resultsContainer.find('.page[data-page_number="' + length + '"]').parent().after(more.clone());
                for (i = length; i < pagination; i++) {
                  resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                }
              } else if (currentPageNumber >= length) {
                resultsContainer.find('.page[data-page_number="1"]').parent().after(more.clone());
                let itemToRemove = (currentPageNumber + 1 - length);
                for (i = 2; i < pagination; i++) {
                  if (itemToRemove > 0) {
                    resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                    itemToRemove--;
                  }
                }
                if (currentPageNumber < (pagination - 1)) {
                  resultsContainer.find('.page[data-current]').parent().after(more.clone());
                }
                for (i = (currentPageNumber + 1); i < pagination; i++) {
                  resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                }
              }
            }

            if (plugin.settings.hideIfEmpty && response.totalCount > 0){
              plugin.container.parents('.remote-gui-wrapper').show();
            }

            if ($.isFunction(plugin.settings.responseCallback)) {
              plugin.settings.responseCallback(response, resultsContainer);
            }
          }
        },
        error: function (jqXHR) {
          let error = {
            error_code: jqXHR.status,
            error_message: jqXHR.statusText
          };
          plugin.detectError(error,jqXHR);
        }
      });
    },

    buildFacets: function () {
      let plugin = this;

      if (plugin.settings.facets.length > 0) {
        if (plugin.settings.removeExistingEmptyFacets){
          $.each(plugin.settings.facets, function (index, value) {
            plugin.container.find('select[data-facets_select="facet-'+index+'"] option').hide();
          });
        }
        let facetedQuery = plugin.buildFacetedQueryParams();
        $.ajax({
          type: "GET",
          url: plugin.searchUrl + facetedQuery,
          dataType: plugin.ajaxDatatype,
          success: function (response, textStatus, jqXHR) {
            var getFacetType = function(facet, name) {
              if (name.includes('name') === false
                && moment(new Date(facet)).isValid()) {
                return 'date';
              }
              return 'string';
            };
            var getFacetOptionText = function(facet, name) {
              if (name.includes('name') === false) {
                let date = moment(new Date(facet));
                if (date.isValid()) {
                  if (facet.indexOf('-01-01T00:00:00Z') > -1) {
                    return date.format('YYYY');
                  }
                  return date.format(MomentDateFormat);
                }
              }
              return facet;
            };
            if (!plugin.detectError(response, jqXHR)) {
              $.each(response.facets, function (index, value) {
                var facetContainer = plugin.container.find('select[data-facets_select="facet-'+index+'"]');
                var notEmpty = facetContainer.find('option').length === 0;
                $.each(value.data, function (facet, count) {
                  let datatype = getFacetType(facet, value.name);
                  if (notEmpty) {
                    facetContainer
                      .append('<option value="' + facet.replace(/"/g, '').replace(/'/g, "\\'").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "") + '">' + getFacetOptionText(facet, value.name) + '</option>');
                  }else if (plugin.settings.removeExistingEmptyFacets){
                    plugin.container.find('select[data-facets_select="facet-' + index + '"] option[value="'+ facet+'"]').show();
                  }
                  if (!facetContainer.data('datatype')) {
                    facetContainer.data('datatype', datatype);
                  }
                });
                let facetSelect = plugin.container.find('select[data-facets_select="facet-'+index+'"]')
                let placeHolder = facetSelect.data('placeholder') || plugin.settings.i18n.placeholder
                if (typeof accessibleAutocomplete !== 'undefined') {
                  accessibleAutocomplete.enhanceSelectElement({
                    defaultValue: '',
                    autoselect: false,
                    showAllValues: true,
                    displayMenu: 'overlay',
                    dropdownArrow: function (){return null},
                    placeholder: placeHolder,
                    selectElement: facetSelect[0],
                    onConfirm: function (query) {
                      let options = facetSelect[0].options
                      let matchingOption
                      if (query) {
                        matchingOption = [].filter.call(options, option => (option.textContent || option.innerText) === query)[0]
                      } else {
                        matchingOption = [].filter.call(options, option => option.value === '')[0]
                      }
                      if (matchingOption) {
                        matchingOption.selected = true
                      }
                      plugin.currentPage = 0;
                      plugin.runSearch();
                    },
                    onRemove: function (value) {
                      const optionToRemove = [].filter.call(facetSelect[0].options, option => (option.textContent || option.innerText) === value)[0]
                      if (optionToRemove) {
                        optionToRemove.selected = false
                      }
                      plugin.currentPage = 0;
                      plugin.runSearch();
                    }
                  })
                }
                facetSelect
                  .show()
                  .on('change', function () {
                    plugin.currentPage = 0;
                    plugin.runSearch();
                  });
              });
            }
          },
          error: function (jqXHR) {
            let error = {
              error_code: jqXHR.status,
              error_message: jqXHR.statusText
            };
            plugin.detectError(error, jqXHR);
          }
        });
      }
    },

    runSearch: function () {
      this.renderList(this.listTpl);
    }

  });

  $.fn[pluginName] = function (options) {
    return this.each(function () {
      if (!$.data(this, 'plugin_' + pluginName)) {
        $.data(this, 'plugin_' +
          pluginName, new Plugin(this, options));
      }
    });
  };

})(jQuery, window, document);


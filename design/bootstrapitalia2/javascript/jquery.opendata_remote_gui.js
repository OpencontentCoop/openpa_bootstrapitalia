;(function ($, window, document, undefined) {
    'use strict';
    var pluginName = 'remoteContentsGui',
        defaults = {
            'queryBuilder': 'browser',
            'remoteUrl': '',
            'localAccessPrefix': '/',
            'limitPagination': 3,
            'itemsPerRow': 3,
            'spinnerTpl': null,
            'listTpl': null,
            'popupTpl': null,
            'query': null,
            'searchApi': '/api/opendata/v2/content/search/',
            'geoSearchApi': '/api/opendata/v2/extrageo/search/',
            'calendarSearchApi': '/api/opendata/v2/calendar/search/',
            'customTpl': '#no-template-defined',
            'useCustomTpl': false,
            'removeExistingEmptyFacets': false,
            'fields': [],
            'facets': [],
            'responseCallback': null,
            'view': 'card_teaser',
            'context': null,
            'hideIfEmpty': false,
            'locale': 'it-IT',
            'i18n': {
                placeholder: 'Select item',
                noResults: 'No results found',
                statusQueryTooShort: 'Type in ${minQueryLength} or more characters for results',
                statusSelectedOption: '${selectedOption} ${index + 1} of ${length} is highlighted',
                assistiveHint: "When autocomplete results are available use up and down arrows to review and enter to select. Touch device users, explore by touch or with swipe gestures.",
                selectedOptionDescription: 'Press Enter or Space to remove selection',
                calendarToday: 'Today',
                calendarMoreEvents: "view more"
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
        this.settings.localAccessPrefix = this.settings.localAccessPrefix.substring(1);
        if (this.settings.queryBuilder === 'browser') {
            if (this.settings.remoteUrl === '') {
                var replaceEndpoint = this.settings.localAccessPrefix.length === 0 ? 'opendata/api' : this.settings.localAccessPrefix + '/opendata/api';
                this.settings.searchApi = this.settings.searchApi.replace('api/opendata/v2', replaceEndpoint);
                this.settings.geoSearchApi = this.settings.geoSearchApi.replace('api/opendata/v2', replaceEndpoint);
                this.settings.calendarSearchApi = this.settings.calendarSearchApi.replace('api/opendata/v2', replaceEndpoint);
                if (this.settings.context && this.settings.context.length > 0){
                    this.settings.searchApi += '?view=' + this.settings.view + '&context=' + this.settings.context + '&q=';
                } else {
                    this.settings.searchApi += '?view=' + this.settings.view + '&q=';
                }
            }
            this.searchUrl = this.settings.remoteUrl + this.settings.searchApi;
            this.cardSearchUrl = this.settings.remoteUrl + this.settings.searchApi.replace(this.settings.view, 'card');
            this.geoSearchUrl = this.settings.remoteUrl + this.settings.geoSearchApi;
            this.calendarSearchUrl = this.settings.remoteUrl + this.settings.calendarSearchApi;
        }else if (this.settings.queryBuilder === 'server') {
            let blockId = this.container.attr('id').replace('remote-gui-', '');
            this.searchUrl = prefix+'openpa/data/block_opendata_queried_contents/'+blockId+'/search/';
            this.geoSearchUrl = prefix+'openpa/data/block_opendata_queried_contents/'+blockId+'/geo/';
            this.calendarSearchUrl = prefix+'openpa/data/block_opendata_queried_contents/'+blockId+'/calendar/';
            this.settings.query = '';
        }else {
            this.searchUrl = prefix+'openpa/data/block_opendata_queried_contents/'+this.settings.queryBuilder+'/search/';
            this.geoSearchUrl = prefix+'openpa/data/block_opendata_queried_contents/'+this.settings.queryBuilder+'/geo/';
            this.calendarSearchUrl = prefix+'openpa/data/block_opendata_queried_contents/'+this.settings.queryBuilder+'/calendar/';
            this.settings.query = '';
            if (this.settings.context && this.settings.context.length > 0){
                this.settings.searchApi += '?view=' + this.settings.view + '&context=' + this.settings.context;
            } else {
                this.settings.searchApi += '?view=' + this.settings.view;
            }
        }
        this.searchFormToggle = this.container.find('.search-form-toggle');
        this.searchForm = this.container.find('.search-form');
        this.intervalFilter = this.container.find('[name="time_interval"]');
        this.publishedRangeFilterFrom = this.container.find('[name="published_from"]');
        this.publishedRangeFilterTo = this.container.find('[name="published_to"]');
        this.publishedRangeFilterReset = this.container.find('.published_reset');

        this.currentPage = 0;
        this.queryPerPage = [];
        this.resultWrapper = this.container.find('.items');
        let paginationStyle = $.inArray(this.settings.view, ['latest_messages_item','accordion','text_linked']) !== -1 ? 'append' : 'reload';
        this.spinnerTpl = $($.templates(this.settings.spinnerTpl).render({paginationStyle:paginationStyle}));
        this.listTpl = $.templates(this.settings.listTpl);
        this.popupTpl = $.templates(this.settings.popupTpl);

        this.ajaxDatatype = this.settings.remoteUrl === '' ? 'json' : 'jsonp';

        this.hasMap = $('#'+this.baseId+'map').length > 0;

        if (this.hasMap) {
            this.markers = L.markerClusterGroup();
            this.map = L.map(this.baseId + 'map').setView([0, 0], 1);
            this.map.scrollWheelZoom.disable();
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'}).addTo(this.map);
            this.map.addLayer(this.markers);
        }

        let calendar = $('#'+this.baseId+'calendar');
        this.hasCalender = calendar.length > 0;
        if (this.hasCalender) {
          this.calendar = calendar;
          this.currentCalendar = null;
          addEventListener("resize", (event) => {
            if (!this.currentCalendar || typeof this.currentCalendar.getView !== 'function') {
              return
            }
            this.currentCalendar.setOption('view', window.innerWidth > 768 ? 'dayGridMonth': 'timeGridDay');
          });
        }

        this.paginationStyle = paginationStyle;

        let plugin = this;
        $('body').on('shown.bs.tab', function (e) {
            if ($(e.target).hasClass('view-selector')) {
                if ($(e.target).attr('href') === '#'+plugin.baseId+'geo') {
                    plugin.map.invalidateSize(false);
                }
                if ($(e.target).attr('href') === '#'+plugin.baseId+'agenda') {
                    plugin.container.find('[data-datepicker]').hide();
                } else {
                    plugin.container.find('[data-datepicker]').show();
                }
                if ($(e.target).attr('href').indexOf(plugin.baseId) > -1) {
                    plugin.runSearch();
                }
            }
        });
        plugin.searchFormToggle.on('click', function (e) {
            e.preventDefault();
            if (plugin.searchForm.hasClass('hide')){
                plugin.searchFormToggle.find('i').removeClass('fa-search').addClass('fa-close');
                plugin.searchForm.removeClass('hide');
                plugin.container.find('select[data-facets_select]').trigger("change");
            }else{
                plugin.searchFormToggle.find('i').removeClass('fa-close').addClass('fa-search');
                plugin.searchForm.find('input').val('');
                plugin.searchForm.find('button').trigger('click');
                plugin.searchForm.addClass('hide');
            }
        });

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
        if (plugin.settings.hideIfEmpty){
            plugin.container.parents('.remote-gui-wrapper').hide();
        }
        plugin.buildFacets();
        if (plugin.intervalFilter.length > 0){
            plugin.intervalFilter.each(function (){
                $(this).on('change', function (){
                    plugin.currentPage = 0;
                    plugin.runSearch();
                })
            })
        }
        if (plugin.publishedRangeFilterFrom.length > 0 && plugin.publishedRangeFilterTo.length > 0){
            plugin.publishedRangeFilterReset.on('click', function (e){
                e.preventDefault();
                plugin.publishedRangeFilterFrom.val('')
                plugin.publishedRangeFilterFrom.removeAttr('max')
                plugin.publishedRangeFilterTo.removeAttr('min')
                plugin.publishedRangeFilterTo.val('')
                plugin.publishedRangeFilterReset.hide();
                plugin.currentPage = 0;
                plugin.runSearch();
            })
            plugin.publishedRangeFilterFrom.on('change', function (){
                plugin.publishedRangeFilterTo.attr('min', $(this).val());
                if (plugin.validatePublishedRange()) {
                    plugin.currentPage = 0;
                    plugin.runSearch();
                }
            })
            plugin.publishedRangeFilterTo.on('change', function (){
                if (plugin.publishedRangeFilterFrom.val().length === 0) {
                    plugin.publishedRangeFilterFrom.attr('max', $(this).val());
                }
                if (plugin.validatePublishedRange()) {
                    plugin.currentPage = 0;
                    plugin.runSearch();
                }
            })
        }
        plugin.runSearch();
    }

    $.extend(Plugin.prototype, {

        buildQuery: function (ignoreIntervalFilter = false) {
            let plugin = this;
            let baseQuery = plugin.settings.query;
            let queryParams = {
                'facets': {}
            };
            if (plugin.searchForm.find('input').length > 0) {
                let q = plugin.searchForm.find('input').val();
                if (q.length > 0) {
                    baseQuery = 'q = \'' + plugin.escapeValue(q) + '\' and ' + baseQuery;
                    queryParams.search = q;
                }
            }
            if (plugin.settings.facets.length > 0) {
                $.each(plugin.settings.facets, function (index, facet) {
                    let facetField = facet.split('|')[0];
                    let facetSelect = plugin.container.find('select[data-facets_select="facet-'+index+'"]');
                    let values = facetSelect.val();
                    let type = facetSelect.data('datatype') || 'string';
                    if (values && values.length > 0) {
                        if (!$.isArray(values)){
                            values = [values];
                        }
                        if (type === 'string') {
                            baseQuery = facetField + ' in [\'"' + plugin.escapeValue(values).join('"\',\'"') + '"\'] and ' + baseQuery;
                            queryParams.facets[facetField] = plugin.escapeValue(values);
                        }else if (type === 'date') {
                            let dates = facetField.indexOf('_dt') > -1 ? values.map(x => '"'+moment(x).format('YYYY-MM-DD')+'T00:00:00Z'+'"') : values;
                            baseQuery = facetField + " in ['" + dates.join("','") + "'] and " + baseQuery;
                            queryParams.facets[facetField] = dates;
                        }else{
                            baseQuery = facetField + " in ['" + plugin.escapeValue(values).join("','") + "'] and " + baseQuery;
                            queryParams.facets[facetField] = plugin.escapeValue(values);
                        }
                    }
                });
            }
            if (!ignoreIntervalFilter){
                if (plugin.intervalFilter.length > 0) {
                    let interval = plugin.intervalFilter.filter(':checked').val();
                    var start = moment();
                    var end = '*';
                    switch (interval) {
                        case 'today':
                            end = moment();
                            break;
                        case 'weekend':
                            start = moment().day(6);
                            end = moment().day(7);
                            break;
                        case 'next7days':
                            end = moment().add(7, 'days');
                            break;
                        case 'next30days':
                            end = moment().add(30, 'days');
                            break;
                    }
                    if (end === '*') {
                        baseQuery += ' and calendar[time_interval] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',*]';
                    } else {
                        baseQuery += ' and calendar[time_interval] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',' + end.set('hour', 23).set('minute', 59).format('YYYY-MM-DD HH:mm') + ']';
                    }
                    queryParams.interval = interval;
                }
                if (plugin.validatePublishedRange()) {
                    let range = plugin.getPublishedRange();
                    let startRange = range.fromDate.set('hour', 0).set('minute', 0);
                    let endRange = range.toDate.set('hour', 23).set('minute', 59);
                    baseQuery += ' and published range [' + startRange.format('YYYY-MM-DD HH:mm') + ',' + endRange.format('YYYY-MM-DD HH:mm') + ']';
                    queryParams.range = startRange.format('YYYY-MM-DD')+','+endRange.format('YYYY-MM-DD');
                }
            }

            if (plugin.searchForm.find('input').length > 0 && plugin.searchForm.find('input').val().length > 0) {
                baseQuery += ' and offset 0 sort [score=>desc]'; //workaround se già presente il parametro sort in query
            }
            if (plugin.settings.queryBuilder === 'browser') {
                return baseQuery;
            }else{
                return $.param(queryParams);
            }
        },

        buildByIdSearchUrl: function (id){
            let plugin = this;
            if (plugin.settings.queryBuilder === 'browser') {
                return plugin.cardSearchUrl + 'id = ' + id;
            } else {
                return plugin.searchUrl + '?limit=1&id=' + id + '&view=banner&' + plugin.buildQuery();
            }
        },

        buildPaginatedQueryParams: function (limit, offset){
            let plugin = this;
            if (plugin.settings.queryBuilder === 'browser') {
                return plugin.buildQuery() + ' and limit ' + limit + ' offset ' + offset;
            }else{
                return '?limit='+limit + '&offset=' + offset + '&' + plugin.buildQuery();
            }
        },

        buildFacetedQueryParams: function (){
            let plugin = this;
            if (plugin.settings.queryBuilder === 'browser') {
                return plugin.buildQuery() + ' and limit 1 facets [' + plugin.settings.facets.join('|alpha|1000,') + '|alpha|1000]';
            }else{
                return '?limit=1&offset=0&f=1&' + plugin.buildQuery();
            }
        },

        buildGeoQueryParams: function (){
            let plugin = this;
            if (plugin.settings.queryBuilder === 'browser') {
                return plugin.buildQuery();
            }else{
                return '?' + plugin.buildQuery();
            }
        },

        detectError: function(response,jqXHR){
            if(response.error_message || response.error_code){
                console.log(response.error_code, response.error_message);
                return true;
            }
            return false;
        },

        markerBuilder: function (response) {
            let plugin = this;
            return L.geoJson(response, {
                pointToLayer: function (feature, latlng) {
                    let customIcon = L.divIcon({html: '<i class="fa fa-map-marker fa-4x text-primary"></i>',iconSize: [20, 20],className: 'myDivIcon'});;
                    return L.marker(latlng, {icon: customIcon});
                },
                onEachFeature: function (feature, layer) {
                    let popupDefault = '<p class="text-center"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + plugin.settings.remoteUrl + '/content/view/full/' + feature.properties.mainNodeId + '" target="_blank" rel="noopener">';
                    popupDefault += feature.properties.name;
                    popupDefault += '</a></p>';
                    let popup = new L.Popup({maxHeight: 360, minWidth: 300});
                    popup.setContent(popupDefault);
                    layer.on('click', function (e) {
                        $.ajax({
                            type: "GET",
                            url: plugin.buildByIdSearchUrl(e.target.feature.properties.id),
                            dataType: plugin.ajaxDatatype,
                            success: function (response,textStatus,jqXHR) {
                                if (!plugin.detectError(response,jqXHR)){
                                    let content = response.searchHits[0];
                                    content.fields = plugin.settings.fields;
                                    content.remoteUrl = plugin.settings.remoteUrl;
                                    content.useCustomTpl = plugin.settings.useCustomTpl;
                                    content.customTpl = plugin.settings.customTpl;
                                    let htmlOutput = plugin.popupTpl.render([content]);
                                    popup.setContent(htmlOutput);
                                    popup.update();
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
                    });
                    layer.bindPopup(popup);
                }
            });
        },

        renderGeo: function () {
            let plugin = this;
            let query = plugin.buildGeoQueryParams();
            plugin.markers.clearLayers();

            let geoJsonFindAll = function (query, cb, context) {
                let features = [];
                let geoJsonFind = function (query, cb, context) {
                    $.ajax({
                        type: "GET",
                        url: plugin.geoSearchUrl+query,
                        dataType: plugin.ajaxDatatype,
                        success: function (response,textStatus,jqXHR) {
                            if (!plugin.detectError(response,jqXHR)){
                                if ($.isFunction(cb)) {
                                    cb.call(context, response);
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
                };
                let getSubRequest = function (query) {
                    geoJsonFind(query, function (data) {
                        parseSubResponse(data);
                    });
                };
                let parseSubResponse = function (response) {
                    if (response.features.length > 0) {
                        $.each(response.features, function () {
                            features.push(this);
                        });
                    }
                    if (response.nextPageQuery) {
                        getSubRequest(response.nextPageQuery);
                    } else {
                        let featureCollection = {
                            'type': 'FeatureCollection',
                            'features': features
                        };
                        cb.call(context, featureCollection);
                    }
                };
                getSubRequest(query);
            };

            geoJsonFindAll(query, function (response) {
                if (response.features.length > 0) {
                    let geoJsonLayer = plugin.markerBuilder(response);
                    plugin.markers.addLayer(geoJsonLayer);
                    plugin.map.fitBounds(plugin.markers.getBounds());
                }
            });
        },

        renderList: function (template) {
            let plugin = this;
            let resultsContainer = plugin.resultWrapper.find('#'+plugin.baseId+'list');

            let limit = plugin.settings.limitPagination;
            let offset = plugin.currentPage * plugin.settings.limitPagination;
            let paginatedQuery = plugin.buildPaginatedQueryParams(limit, offset);

            if ((resultsContainer.html().length === 0 && plugin.paginationStyle === 'reload') || plugin.currentPage === 0) {
              resultsContainer.html(plugin.spinnerTpl);
            } else if (resultsContainer.html().length > 0 && plugin.paginationStyle === 'reload') {
              resultsContainer.find('div.row').not('.remote-pagination').css('opacity', 0.5)
            } else {
              resultsContainer.find('.nextPage').replaceWith(plugin.spinnerTpl);
            }
            let data = null;
            if (plugin.settings.remoteUrl !== '') {
                data = {view: plugin.settings.view};
            }

            $.ajax({
                type: "GET",
                url: plugin.searchUrl + paginatedQuery,
                data: data,
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
                        response.autoColumn = plugin.settings.itemsPerRow !== 'auto' && $.inArray(plugin.settings.view, ['card_teaser_info', 'card_teaser', 'banner_color', 'card_children']) > -1;
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
                          let self = this;
                          e.preventDefault();
                          const htmlElement = document.querySelector('html');
                          let scrollPaddingTop = window.getComputedStyle(htmlElement).scrollPaddingTop;
                          if (!scrollPaddingTop) {
                            scrollPaddingTop = "72px";
                          }
                          scrollPaddingTop = parseInt(scrollPaddingTop, 10);
                          if (plugin.paginationStyle === 'reload'){
                              $('html, body').animate({
                                  scrollTop: resultsContainer.offset().top - scrollPaddingTop
                              }, 0, function(){
                                  plugin.currentPage = $(self).data('page');
                                  if (plugin.currentPage >= 0){
                                      plugin.renderList(template);
                                  }
                              });
                          } else{
                              plugin.currentPage = $(self).data('page');
                              if (plugin.currentPage >= 0){
                                  plugin.renderList(template);
                              }
                          }
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

        renderCalendar: function () {
            let plugin = this;
            if (plugin.currentCalendar === null) {
              plugin.currentCalendar = new EventCalendar(plugin.calendar[0], {
                view: window.innerWidth > 768 ? 'dayGridMonth': 'timeGridDay',
                dayMaxEvents: true,
                allDaySlot: false,
                scrollTime: '09:00:00',
                views: {
                  dayGridMonth: {
                    firstDay: 1,
                    height: '800px'
                  },
                  timeGridDay: {
                    firstDay: 1,
                  }
                },
                eventClick: function (info) {
                  let url = '';
                  if (info.event.extendedProps.location) {
                    url = info.event.extendedProps.location;
                  } else {
                    url = plugin.settings.localAccessPrefix.length ? '/' + plugin.settings.localAccessPrefix + '/openpa/object/' + info.event.id : '/openpa/object/' + info.event.id;
                  }
                  window.location.href = url
                },
                loading: function (isLoading) {
                  // console.log(isLoading)
                },
                locale: plugin.settings.locale,
                buttonText: {
                  today: plugin.settings.i18n.calendarToday
                },
                moreLinkContent: plugin.settings.i18n.calendarMoreEvents,
                eventSources: [{
                  url: plugin.calendarSearchUrl,
                  extraParams: function () {
                    let query = plugin.buildQuery(true);
                    return { q: query };
                  },
                }]
              });
            } else {
              plugin.currentCalendar.refetchEvents();
            }
        },

        escapeValue: function (value){
            let plugin = this;
            if ($.isArray(value)){
                var newArray = []
                for (var i = 0, l = value.length; i < l; i++) {
                    newArray.push(plugin.escapeValue(value[i]));
                }
                return newArray;
            }
            return value.toString()
              .replace(/"/g, '\\"')
              .replace(/'/g, "\\'")
              .replace(/\(/g, "\\(")
              .replace(/\)/g, "\\)")
              .replace(/\[/g, "\\[")
              .replace(/\]/g, "\\]");
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
                              && facet.length > 15
                              && moment(facet, moment.ISO_8601, true).isValid()) {
                                return 'date';
                            }
                            return 'string';
                        };
                        var getFacetOptionText = function(facet, name) {
                            if (name.includes('name') === false && facet.length > 15) {
                                let date = moment(facet, moment.ISO_8601, true);
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
                                var isEmpty = facetContainer.find('option').length === 0;
                                $.each(value.data, function (facet, count) {
                                    let datatype = getFacetType(facet, value.name);
                                    if (isEmpty) {
                                        facetContainer
                                          .append('<option value="' + facet + '">' + getFacetOptionText(facet, value.name) + '</option>');
                                    } else {
                                        var currentOption = plugin.container.find('select[data-facets_select="facet-' + index + '"] option[value="' + facet + '"]')
                                        var treeOption = plugin.container.find('select[data-facets_select="facet-' + index + '"] option[value="' + currentOption.data('tree') + '"]');
                                        currentOption.removeAttr('disabled')
                                        treeOption.removeAttr('disabled')
                                        if (plugin.settings.removeExistingEmptyFacets) {
                                            currentOption.show();
                                            treeOption.show();
                                        }
                                    }
                                    if (!facetContainer.data('datatype')) {
                                        facetContainer.data('datatype', datatype);
                                    }
                                });
                                facetContainer.find('option[disabled="disabled"]').remove();
                                let placeHolder = facetContainer.data('placeholder') || plugin.settings.i18n.placeholder
                                if (typeof accessibleAutocomplete !== 'undefined' && facetContainer.length > 0) {
                                    accessibleAutocomplete.enhanceSelectElement({
                                        defaultValue: '',
                                        autoselect: false,
                                        showAllValues: true,
                                        displayMenu: 'overlay',
                                        dropdownArrow: function (){return null},
                                        placeholder: placeHolder,
                                        tNoResults: () => plugin.settings.i18n.noResults,
                                        tStatusQueryTooShort: () => plugin.settings.i18n.statusQueryTooShort,
                                        tStatusSelectedOption: () => plugin.settings.i18n.statusSelectedOption,
                                        tAssistiveHint: () => plugin.settings.i18n.assistiveHint,
                                        tSelectedOptionDescription: () => plugin.settings.i18n.selectedOptionDescription,
                                        selectElement: facetContainer[0],
                                        onConfirm: function (query) {
                                            let options = facetContainer[0].options
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
                                            const optionToRemove = [].filter.call(facetContainer[0].options, option => (option.textContent || option.innerText) === value)[0]
                                            if (optionToRemove) {
                                                optionToRemove.selected = false
                                            }
                                            plugin.currentPage = 0;
                                            plugin.runSearch();
                                        },
                                        templates: {
                                            suggestion: function (value){
                                                var spaces  =  value.search(/\S/);
                                                if (spaces > 0){
                                                    return '<span class="tree-item ps-'+spaces+'">'+value.trim()+'</span>';
                                                }
                                                return value;
                                            }
                                        }
                                    })
                                }
                                facetContainer
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
            let plugin = this;
            if (plugin.container.find('a.view-selector.active').attr('href') === '#'+plugin.baseId+'list') {
                plugin.renderList(plugin.listTpl);
            } else if (plugin.container.find('a.view-selector.active').attr('href') === '#'+plugin.baseId+'geo' && plugin.hasMap) {
                plugin.renderGeo();
            } else if (plugin.container.find('a.view-selector.active').attr('href') === '#'+plugin.baseId+'agenda') {
                plugin.renderCalendar();
            }
        },

        getPublishedRange: function (){
            let plugin = this;
            let fromDate = moment(plugin.publishedRangeFilterFrom.val());
            let toDate = moment(plugin.publishedRangeFilterTo.val());
            return {
                fromDate: fromDate,
                toDate: toDate
            };
        },

        validatePublishedRange: function (){
            let plugin = this;
            let range = plugin.getPublishedRange();
            if (range.fromDate.isValid() || range.toDate.isValid()) {
                plugin.publishedRangeFilterReset.show();
            }
            return  range.fromDate.isValid() && range.toDate.isValid(); // && range.toDate.isAfter(range.fromDate);
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


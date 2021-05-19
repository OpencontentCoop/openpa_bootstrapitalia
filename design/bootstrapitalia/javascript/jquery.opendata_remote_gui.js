;(function ($, window, document, undefined) {
    'use strict';
    var pluginName = 'remoteContentsGui',
        defaults = {
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
            'customTpl': '#no-template-defined',
            'useCustomTpl': false,
            'removeExistingEmptyFacets': false,
            'fields': [],
            'facets': [],
            'responseCallback': null
        };

    function Plugin(element, options) {
        this.settings = $.extend({}, defaults, options);
        this.container = $(element);
        this.baseId = this.container.attr('id')+'-';
        if (this.settings.remoteUrl === '') {
            var localAccessPrefix = this.settings.localAccessPrefix.substr(1);
            var replaceEndpoint = localAccessPrefix.length === 0 ? 'opendata/api' : localAccessPrefix + '/opendata/api';
            this.settings.searchApi = this.settings.searchApi.replace('api/opendata/v2', replaceEndpoint);
            this.settings.geoSearchApi = this.settings.geoSearchApi.replace('api/opendata/v2', replaceEndpoint);
            this.settings.searchApi += '?view=card_teaser&q=';
        }
        this.searchUrl = this.settings.remoteUrl + this.settings.searchApi;
        this.geoSearchUrl = this.settings.remoteUrl + this.settings.geoSearchApi;
        this.searchFormToggle = this.container.find('.search-form-toggle');
        this.searchForm = this.container.find('.search-form');

        this.currentPage = 0;
        this.queryPerPage = [];
        this.resultWrapper = this.container.find('.items');
        this.spinnerTpl = $($.templates(this.settings.spinnerTpl).render({}));
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
        let plugin = this;
        $('body').on('shown.bs.tab', function (e) {
            if ($(e.target).hasClass('view-selector')) {
                if ($(e.target).attr('href') === '#'+plugin.baseId+'geo') {
                    plugin.map.invalidateSize(false);
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
                plugin.container.find('select[data-facets_select]').trigger("chosen:updated");
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

        plugin.buildFacets();
        plugin.runSearch();
    }

    $.extend(Plugin.prototype, {

        buildQuery: function () {
            let plugin = this;
            let baseQuery = plugin.settings.query;
            if (plugin.searchForm.find('input').length > 0) {
                let q = plugin.searchForm.find('input').val();
                if (q.length > 0) {
                    q = q.replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
                    baseQuery = 'q = \'' + q + '\' ' + baseQuery;
                }
            }
            if (plugin.settings.facets.length > 0) {
                $.each(plugin.settings.facets, function (index, facet) {
                    let values = plugin.container.find('select[data-facets_select="facet-'+index+'"]').val();
                    if (values.length > 0) {
                        baseQuery = facet + ' in [\'"' + values.join('"\',\'"') + '"\'] and ' + baseQuery;
                    }
                });
            }
            return baseQuery;
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
                    let customIcon = L.MakiMarkers.icon({icon: 'circle', size: 'l'});
                    return L.marker(latlng, {icon: customIcon});
                },
                onEachFeature: function (feature, layer) {
                    let popupDefault = '<p class="text-center"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + plugin.settings.remoteUrl + '/content/view/full/' + feature.properties.mainNodeId + '" target="_blank">';
                    popupDefault += feature.properties.name;
                    popupDefault += '</a></p>';
                    let popup = new L.Popup({maxHeight: 360, minWidth: 300});
                    popup.setContent(popupDefault);
                    layer.on('click', function (e) {
                        $.ajax({
                            type: "GET",
                            url: plugin.searchUrl + 'id = '+e.target.feature.properties.id,
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
            let query = plugin.buildQuery();
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

            let baseQuery = plugin.buildQuery();
            let paginatedQuery = baseQuery + ' and limit ' + plugin.settings.limitPagination + ' offset ' + plugin.currentPage * plugin.settings.limitPagination;
            resultsContainer.html(plugin.spinnerTpl);

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
                            plugin.queryPerPage[i] = baseQuery + ' and limit ' + plugin.settings.limitPagination + ' offset ' + (plugin.settings.limitPagination * i);
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
                        response.itemsPerRow = plugin.settings.itemsPerRow;

                        let renderData = $(template.render(response));
                        resultsContainer.html(renderData);

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
                let paginatedQuery = plugin.buildQuery() + ' and limit 1 facets [' + plugin.settings.facets.join(',') + ']';
                $.ajax({
                    type: "GET",
                    url: plugin.searchUrl + paginatedQuery,
                    dataType: plugin.ajaxDatatype,
                    success: function (response, textStatus, jqXHR) {
                        if (!plugin.detectError(response, jqXHR)) {
                            $.each(response.facets, function (index, value) {
                                var notEmpty = plugin.container.find('select[data-facets_select="facet-'+index+'"] option').length === 0;
                                $.each(value.data, function (facet, count) {
                                    if (notEmpty) {
                                        plugin.container.find('select[data-facets_select="facet-' + index + '"]')
                                            .append('<option value="' + facet.replace(/"/g, '').replace(/'/g, "\\'").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "") + '">' + facet + '</option>');
                                    }else if (plugin.settings.removeExistingEmptyFacets){
                                        plugin.container.find('select[data-facets_select="facet-' + index + '"] option[value="'+ facet+'"]').show();
                                    }
                                });
                                plugin.container.find('select[data-facets_select="facet-'+index+'"]')
                                    .show()
                                    .chosen()
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
            let query = plugin.buildQuery();
            if (plugin.container.find('a.view-selector.active').attr('href') === '#'+plugin.baseId+'list') {
                plugin.renderList(plugin.listTpl);
            } else if (plugin.container.find('a.view-selector.active').attr('href') === '#'+plugin.baseId+'geo' && plugin.hasMap) {
                plugin.renderGeo(query);
            }
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


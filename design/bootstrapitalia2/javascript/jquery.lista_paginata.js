$(document).ready(function () {
    $.views.helpers($.opendataTools.helpers);
    $('[data-block_subtree_query]').each(function () {
        let baseUrl = '/';
        if (typeof (UriPrefix) !== 'undefined' && UriPrefix !== '/') {
            baseUrl = UriPrefix + '/';
        }
        let container = $(this);
        let resultsContainer = container.find('.results');
        let subTreeFilter = container.data('subtree_filter');
        let limitPagination = container.data('limit');
        let itemsPerRow = container.data('items_per_row');
        let view = container.data('view');
        let icon = container.data('icon');
        let currentPage = 0;
        let queryPerPage = [];
        let template = $.templates('#tpl-results');
        let searchType = container.data('search_type') || 'search';
        let searchEndpoint = searchType === 'calendar' ? '/opendata/api/calendar/search' : $.opendataTools.settings('endpoint').search;
        let dayLimit = container.data('day_limit') || 7;

        let removeFilterLoader = function() {
            container.find('[data-block_subtree_filter] i.loading').remove();
        }

        let filters = container.find('[data-block_subtree_filter]').on('click', function (e) {
            let self = $(this);
            if (self.hasClass('btn-secondary')) {
                self.removeClass('btn-secondary').addClass('btn-outline-secondary');
            } else {
                filters.removeClass('btn-secondary').addClass('btn-outline-secondary');
                self.addClass('btn-secondary').removeClass('btn-outline-secondary');
                self.append('<i class="ms-1 loading fa fa-circle-o-notch fa-spin fa-fw"></i>')
            }
            currentPage = 0;
            loadContents();
            e.preventDefault();
        });
        if (filters.length > 2) {
            container.find('.filters-wrapper').removeClass('hide');
        }

        let buildQuery = function () {
            let subtreeList = [];
            container.find('.btn-secondary[data-block_subtree_filter]').each(function () {
                let subtree = $(this).data('block_subtree_filter');
                if (subtree) {
                    subtreeList.push(subtree);
                }
            });
            let query = container.data('block_subtree_query');
            if (subtreeList.length > 0) {
                query += ' and ' + subTreeFilter + ' in [' + subtreeList.join(',') + ']';
            }

            return query;
        };

        let findSubtree = function (content) {
            let subtree;
            $.each(content.metadata.assignedNodes, function () {
                if (!subtree) {
                    let pathList = this.path_string.split('/');
                    $.each(pathList, function () {
                        if (this !== '' && !subtree) {
                            let current = parseInt(this);
                            if (current > 0) {
                                let button = container.find('[data-block_subtree_filter="' + current + '"]');
                                if (button.length > 0) {
                                    subtree = {text: button.text(), url: baseUrl + 'content/view/full/' + current};
                                }
                            }
                        }
                    });
                }
            });

            return subtree;
        };

        let detectError = function (response, jqXHR) {
            if (response.error_message || response.error_code) {
                console.log(response.error_code, response.error_message, jqXHR);
                return true;
            }
            return false;
        };

        let find = function (query, cb, context) {
            $.ajax({
                type: 'GET',
                url: searchEndpoint,
                data: {
                    q: query,
                    start: moment().format('YYYY-MM-DD'),
                    end: moment().add(dayLimit, 'days').format('YYYY-MM-DD'),
                    view: view},
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (data, textStatus, jqXHR) {
                    if (!detectError(data, jqXHR)) {
                        cb.call(context, data);
                    }
                },
                error: function (jqXHR) {
                    let error = {
                        error_code: jqXHR.status,
                        error_message: jqXHR.statusText
                    };
                    detectError(error, jqXHR);
                }
            });
        };

        let loadContents = function () {
            let baseQuery = buildQuery();
            let paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage * limitPagination;

            find(paginatedQuery, function (response) {
                if (searchType === 'calendar'){
                    var hits = [];
                    var avoidDuplication = [];
                    $.each(response, function (){
                        let start = moment(this.start);
                        let end = moment(this.end);
                        if ($.inArray(this.id, avoidDuplication) === -1) {
                            avoidDuplication.push(this.id);
                            hits.push(this.content);
                        }
                    });
                    response = {
                        searchHits: hits,
                        totalCount: hits.length,
                    };
                }
                queryPerPage[currentPage] = paginatedQuery;
                response.view = view;
                response.autoColumn = itemsPerRow !== 'auto' && $.inArray(view, ['card_teaser', 'banner_color', 'card_children']) > -1;
                response.itemsPerRow = itemsPerRow;
                response.icon = icon;
                response.currentPage = currentPage;
                response.prevPage = currentPage - 1;
                response.nextPage = currentPage + 1;
                let pagination = response.totalCount > 0 ? Math.ceil(response.totalCount / limitPagination) : 0;
                let pages = [];
                let i;
                for (i = 0; i < pagination; i++) {
                    queryPerPage[i] = baseQuery + ' and limit ' + limitPagination + ' offset ' + (limitPagination * i);
                    pages.push({'query': i, 'page': (i + 1)});
                }
                response.pages = pages;
                response.pageCount = pagination;

                response.prevPageQuery = jQuery.type(queryPerPage[response.prevPage]) === 'undefined' ? null : queryPerPage[response.prevPage];

                $.each(response.searchHits, function () {
                    this.subtree = findSubtree(this);
                    this.baseUrl = baseUrl;
                });
                let renderData = $(template.render(response));
                resultsContainer.html(renderData);
                if (typeof bootstrap === 'object' && itemsPerRow === 'auto') {
                    new bootstrap.Masonry(renderData[0]);
                }
                resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
                    currentPage = $(this).data('page');
                    $(this).html('<i class="ms-1 loading fa fa-circle-o-notch fa-spin fa-fw"></i>')
                    loadContents();
                    e.preventDefault();
                });
                let applyPagination = function () {
                    resultsContainer.find('.page[data-page_number]').parent().show();
                    resultsContainer.find('.pagination-ellipsis').remove();
                    let displayPages = resultsContainer.find('.page[data-page_number]');
                    let currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
                    let isDesktop = $(window).width() >= 1024;
                    let half = isDesktop ? 3 : 0;
                    let range = isDesktop ? 7 : 1;
                    if (displayPages.length > range + 2) {
                        let rStart = Math.max(2, currentPageNumber - half);
                        let rEnd = Math.min(pagination - 1, currentPageNumber + half);
                        if (rEnd - rStart < range - 1) {
                            if (rStart === 2) rEnd = Math.min(pagination - 1, rStart + range - 1);
                            else rStart = Math.max(2, rEnd - range + 1);
                        }
                        for (i = 2; i < pagination; i++) {
                            if (i < rStart || i > rEnd) {
                                resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                            }
                        }
                        let more = $('<li class="page-item pagination-ellipsis"><span class="page-link">...</span></li>');
                        if (rStart > 2) {
                            resultsContainer.find('.page[data-page_number="' + rStart + '"]').parent().before(more.clone());
                        }
                        if (rEnd < pagination - 1) {
                            resultsContainer.find('.page[data-page_number="' + rEnd + '"]').parent().after(more.clone());
                        }
                    }
                };
                applyPagination();
                $(window).off('resize.listapaginata').on('resize.listapaginata', function () {
                    clearTimeout(window._lpResizeTimer);
                    window._lpResizeTimer = setTimeout(applyPagination, 150);
                });
                if (response.totalCount > 0) {
                    container.removeClass('hide');
                }
                removeFilterLoader();
            });
        };

        loadContents();
    });
});
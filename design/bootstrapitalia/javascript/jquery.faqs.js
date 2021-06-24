$(document).ready(function () {
    $.views.helpers($.opendataTools.helpers);
    $('[data-faq_group]').each(function () {
        let resultsContainer = $(this);
        let userAware = resultsContainer.data('capabilities');
        let subtree = resultsContainer.data('faq_group');
        let classes = ['faq'];
        let currentPage = 0;
        let queryPerPage = [];
        let limitPagination = resultsContainer.data('faq_pagination') || 50;
        let template = $.templates('#tpl-faq-results');
        let spinner = $($.templates('#tpl-faq-spinner').render({}));
        let buildQuery = function () {
            let classQuery = '';
            if (classes.length) {
                classQuery = 'classes [' + classes + ']';
            }
            let query = classQuery + ' subtree [' + subtree + '] and raw[meta_main_node_id_si] !in [' + subtree + ']';
            query += ' sort [priority=>desc,published=>asc]';
            return query;
        };
        let findContents = function (query, cb, context) {
            $.ajax({
                type: 'GET',
                url: userAware ? '/opendata/api/useraware/search/' : '/opendata/api/content/search/',
                data: {q: query},
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    if(data.error_message || data.error_code){
                        console.log(data.error_message + ' (error: '+data.error_code+')');
                    }else{
                        cb.call(context, data);
                    }
                },
                error: function (jqXHR) {
                    console.log(jqXHR.status + ' (error: '+jqXHR.statusText+')');
                }
            });
        };
        let loadContents = function () {
            let baseQuery = buildQuery();
            let paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage * limitPagination;
            resultsContainer.html(spinner);
            findContents(paginatedQuery, function (response) {
                queryPerPage[currentPage] = paginatedQuery;
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
                let renderData = $(template.render(response));
                resultsContainer.html(renderData);
                renderData.find('.page, .nextPage, .prevPage').on('click', function (e) {
                    currentPage = $(this).data('page');
                    if (currentPage >= 0) {
                        loadContents();
                    }
                    e.preventDefault();
                });

                renderData.find("[data-edit]").on('click', function(e){
                    var object = $(this).data('edit');
                    $('#faq-form').opendataFormEdit({
                        'object': object
                    }, {
                        onBeforeCreate: function () {$('#faq-modal').modal('show');},
                        onSuccess: function () {$('#faq-modal').modal('hide');loadContents();}
                    });
                    e.preventDefault();
                });
                renderData.find("[data-remove]").on('click',function(e){
                    var object = $(this).data('remove');
                    $('#faq-form').opendataFormDelete(object, {
                        onBeforeCreate: function () {$('#faq-modal').modal('show');},
                        onSuccess: function () {$('#faq-modal').modal('hide');loadContents();}
                    });
                    e.preventDefault();
                });

                let more = $('<li class="page-item"><span class="page-link">...</span></li');
                let displayPages = resultsContainer.find('.page[data-page_number]');
                let currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
                let length = 7;
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
            });
        };
        resultsContainer.on('faq:refresh', function (){
            loadContents();
        });
        loadContents();
    });
    $("[data-create_faq]").on('click', function(e){
        var parent = $(this).data('create_faq');
        $('#faq-form').opendataFormCreate({
            'parent': parent,
            'class': 'faq',
        }, {
            onBeforeCreate: function () {$('#faq-modal').modal('show');},
            onSuccess: function () {$('#faq-modal').modal('hide');$('[data-faq_group='+parent+']').trigger('faq:refresh');}
        });
        e.preventDefault();
    });
});
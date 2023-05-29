$(document).ready(function () {
    $.views.helpers($.opendataTools.helpers);
    $('[data-faq_group]').each(function () {
        let container = $(this);
        let userAware = container.data('capabilities');
        let subtree = container.data('faq_group');
        let classes = ['faq'];
        let currentPage = 0;
        let queryPerPage = [];
        let limitPagination = container.data('faq_pagination') || 50;
        let resultsContainer = container.find('[data-faq_list]');
        let paginationContainer = container.find('[data-faq_pagination]');
        let template = $.templates('#tpl-faq-results');
        let templatePagination = $.templates('#tpl-faq-pagination');
        let spinner = $($.templates('#tpl-faq-spinner').render({}));
        let buildQuery = function () {
            let classQuery = '';
            if (classes.length) {
                classQuery = 'classes [' + classes + ']';
            }
            let q = container.find('.faqSearchInput').val();
            let query = classQuery + ' subtree [' + subtree + '] and raw[meta_main_node_id_si] !in [' + subtree + ']';
            if (q.length > 0) {
                q = q.replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
                query = 'q = \'' + q + '\' and ' + query;
                query += ' sort [score=>desc]';
            }else{
                query += ' sort [priority=>desc,published=>asc]';
            }

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
            let isFirstLoad = currentPage === 0;
            if (isFirstLoad) {
                resultsContainer.html(spinner);
            }
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
                if (isFirstLoad) {
                    resultsContainer.html('');
                }
                resultsContainer.append(renderData);

                let renderPaginationData = $(templatePagination.render(response));
                paginationContainer.html(renderPaginationData);
                paginationContainer.find('.moreResults').on('click', function (e) {
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
                        onSuccess: function () {$('#faq-modal').modal('hide');currentPage = 0;loadContents();}
                    });
                    e.preventDefault();
                });
                renderData.find("[data-remove]").on('click',function(e){
                    var object = $(this).data('remove');
                    $('#faq-form').opendataFormDelete(object, {
                        onBeforeCreate: function () {$('#faq-modal').modal('show');},
                        onSuccess: function () {$('#faq-modal').modal('hide');currentPage = 0;loadContents();}
                    });
                    e.preventDefault();
                });
            });
        };
        container.on('faq:refresh', function (){
            currentPage = 0;
            loadContents();
        });
        loadContents();

        container.find('.faqSearchSubmit').on('click', function (e){
            currentPage = 0;
            loadContents();
            e.preventDefault();
        });
    });
    $("[data-create_faq]").on('click', function(e){
        var parent = $(this).data('create_faq');
        $('#faq-form').opendataFormCreate({
            'parent': parent,
            'class': 'faq',
        }, {
            onBeforeCreate: function () {$('#faq-modal').modal('show');},
            onSuccess: function () {$('#faq-modal').modal('hide');$('[data-faq_group]').trigger('faq:refresh');}
        });
        e.preventDefault();
    });
});
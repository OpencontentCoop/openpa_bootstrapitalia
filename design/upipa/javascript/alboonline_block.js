moment.locale('it');
;(function ($) {
    $.fn.extend({
        alboOnLine: function (options) {
            this.defaultOptions = {
                buttonClass: 'button',
                selectedButtonClass: 'defaultbutton',
                template: '<table class="table table-striped table-bordered display responsive no-wrap" cellspacing="0" width="100%"></table>'
            };

            var settings = $.extend({}, this.defaultOptions, options);

            return this.each(function () {
                var $this = $(this);

                var fieldsDatatable = $this.find('.table-container').opendataDataTable({
                    "builder": {
                        "query": ''
                    },
                    "table": {
                        "id": 'table-' + $this.attr('id'),
                        "template": settings.template
                    },
                    "datatable": {
                        // 'responsive': true,
                        "autoWidth": false,
                        'dom': "<'row mt-4'<'col-sm-12 col-md-6'i><'col-sm-12 col-md-6'f>><'row'<'col-sm-12'tr>><'row'<'col-sm-12 col-md-5'l><'col-sm-12 col-md-7'p>>",
                        "language": {
                            "decimal": "",
                            "emptyTable": "Non sono attualmente presenti atti in questa sezione",
                            "info": "Vista da _START_ a _END_ di _TOTAL_ elementi",
                            "infoEmpty": "",
                            "infoFiltered": "(filtrati da _MAX_ elementi totali)",
                            "infoPostFix": "",
                            "thousands": ",",
                            "lengthMenu": "Visualizza _MENU_ elementi",
                            "loadingRecords": "Caricamento...",
                            "processing": "Elaborazione...",
                            "search": "Cerca:",
                            "zeroRecords": "La ricerca non ha portato alcun risultato",
                            "paginate": {
                                "first": "Inizio",
                                "last": "Fine",
                                "next": "Successivo",
                                "previous": "Precedente"
                            },
                            "aria": {
                                "sortAscending": ": attiva per ordinare la colonna in ordine crescente",
                                "sortDescending": ": attiva per ordinare la colonna in ordine decrescente"
                            }
                        },
                        "order": [[0, 'desc']],
                        "pageLength": settings.length,
                        "lengthChange": false,
                        "searching": settings.searching,
                        "ajax": {url: settings.url},
                        "columns": settings.columns,
                        "columnDefs": settings.columnDefs
                    }
                }).on('draw.dt', function (e, datatableSettings, json) {
                    if (settings.openInPopup) {
                        $('.alboonline-link a').on('click', function (e) {
                            e.preventDefault();
                            $('#albboonline-content').opendataFormView(
                                {object: $(this).parent().data('open')},
                                {
                                    onBeforeCreate: function(){
                                        $('#albboonline-preview').modal('show')
                                    },
                                }
                            );
                        });
                    }
                }).on('xhr.dt', function (e, datatableSettings, json, xhr) {

                    // esegue una query di faccette escludendo il filtro di group-facet
                    var facetFields = [];
                    var cloneBuilder = $.extend({}, fieldsDatatable.settings.builder);
                    var countVisible = [];
                    $this.find('.group-facets a').each(function () {
                        var field = $(this).data('field');
                        if (!$(this).hasClass(settings.selectedButtonClass)) {
                            $(this).hide();
                        } else {
                            countVisible.push(parseInt($(this).data('facet_value')));
                        }
                        if ($.inArray(field, facetFields) === -1) {
                            facetFields.push(field);
                            cloneBuilder.filters[field] = null;
                        }
                    });
                    if (facetFields.length > 0) {
                        var facetQuery = '';
                        $.each(cloneBuilder.filters, function () {
                            if (this != null && $.isArray(this.value)) {
                                facetQuery += this.field + " " + this.operator + " ['" + this.value.join("','") + "']";
                                facetQuery += ' and ';
                            }
                        });
                        facetQuery += ' facets [' + facetFields.join(',') + '] limit 1';
                        $.get(settings.facets_url + facetQuery, function (facetResponse) {
                            $.each(facetResponse.facets, function () {
                                var name = this.name;
                                var data = this.data;
                                $.each(this.data, function (index, value) {
                                    $this.find('.group-facets a[data-field="' + name + '"][data-facet_value="' + index + '"]').show();
                                    if ($.inArray(parseInt(index), countVisible) === -1) {
                                        countVisible.push(parseInt(index));
                                    }
                                });
                            });
                            console.log(countVisible);
                            if (countVisible.length > 1) {
                                $this.find('.group-facets').show();
                            } else {
                                $this.find('.group-facets').hide();
                            }
                        });
                    }
                }).data('opendataDataTable');

                var setCurrentFilters = function () {
                    $this.find('.facet-navigation').each(function () {
                        var currentFilterName = $(this).find('.' + settings.selectedButtonClass).data('field');
                        var currentFilterOperator = $(this).find('.' + settings.selectedButtonClass).data('operator');
                        var currentFilterValue = $(this).find('.' + settings.selectedButtonClass).data('value');
                        fieldsDatatable.settings.builder.filters[currentFilterName] = {
                            'field': currentFilterName,
                            'operator': currentFilterOperator,
                            'value': currentFilterValue
                        };
                    });
                };
                setCurrentFilters();

                $this.find('.facet-navigation .' + settings.selectedButtonClass).on('click', function (e) {
                    e.preventDefault();
                });
                $this.find('.facet-navigation .' + settings.buttonClass).on('click', function (e) {
                    $(this).parent().find('.' + settings.selectedButtonClass).removeClass(settings.selectedButtonClass);
                    $(this).addClass(settings.selectedButtonClass);
                    setCurrentFilters();
                    fieldsDatatable.loadDataTable();
                    e.preventDefault();
                });
                $('.group-facets').hide();
                fieldsDatatable.loadDataTable();
            });
        }
    });
})(jQuery);

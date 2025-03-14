/**
 * stacktable.js
 * Author & copyright (c) 2012: John Polacek
 * CardTable by: Justin McNally (2015)
 * MIT license
 *
 * Page: http://johnpolacek.github.com/stacktable.js
 * Repo: https://github.com/johnpolacek/stacktable.js/
 *
 * jQuery plugin for stacking tables on small screens
 * Requires jQuery version 1.7 or above
 *
 */
;(function ($) {
    $.fn.cardtable = function (options) {
        var $tables = this,
            defaults = {headIndex: 0},
            settings = $.extend({}, defaults, options),
            headIndex;

        // checking the "headIndex" option presence... or defaults it to 0
        if (options && options.headIndex)
            headIndex = options.headIndex;
        else
            headIndex = 0;

        return $tables.each(function () {
            var $table = $(this);
            if ($table.hasClass('stacktable')) {
                return;
            }
            var table_css = $(this).prop('class');
            var $stacktable = $('<div></div>');
            if (typeof settings.myClass !== 'undefined') $stacktable.addClass(settings.myClass);
            var markup = '';
            var $caption, $topRow, headMarkup, bodyMarkup, tr_class;

            $table.addClass('stacktable large-only');

            $caption = $table.find(">caption").clone();
            $topRow = $table.find('>thead>tr,>tbody>tr,>tfoot>tr,>tr').eq(0);

            // avoid duplication when paginating
            $table.siblings().filter('.small-only').remove();

            // using rowIndex and cellIndex in order to reduce ambiguity
            $table.find('>tbody>tr').each(function () {

                // declaring headMarkup and bodyMarkup, to be used for separately head and body of single records
                headMarkup = '';
                bodyMarkup = '';
                tr_class = $(this).prop('class');
                // for the first row, "headIndex" cell is the head of the table
                // for the other rows, put the "headIndex" cell as the head for that row
                // then iterate through the key/values
                $(this).find('>td,>th').each(function (cellIndex) {
                    if ($(this).html() !== '' && $(this).html() !== $topRow.find('>td,>th').eq(cellIndex).html()) {
                        bodyMarkup += '<tr class="' + tr_class + '">';
                        if ($topRow.find('>td,>th').eq(cellIndex).html()) {
                            bodyMarkup += '<td class="st-key font-weight-bold">' + $topRow.find('>td,>th').eq(cellIndex).html() + '</td>';
                        } else {
                            bodyMarkup += '<td class="st-key"></td>';
                        }
                        bodyMarkup += '<td class="st-val ' + $(this).prop('class') + '">' + $(this).html() + '</td>';
                        bodyMarkup += '</tr>';
                    }
                });

                markup += '<table class=" ' + table_css + ' border stacktable small-only"><tbody>' + headMarkup + bodyMarkup + '</tbody></table>';
            });

            $table.find('>tfoot>tr>td').each(function (rowIndex, value) {
                if ($.trim($(value).text()) !== '') {
                    markup += '<table class="' + table_css + ' border stacktable small-only"><tbody><tr><td>' + $(value).html() + '</td></tr></tbody></table>';
                }
            });

            $stacktable.prepend($caption);
            $stacktable.append($(markup));
            $table.before($stacktable);
        });
    };

    $.fn.stacktable = function (options) {
        var $tables = this,
            defaults = {headIndex: 0, displayHeader: true},
            settings = $.extend({}, defaults, options),
            headIndex;

        // checking the "headIndex" option presence... or defaults it to 0
        if (options && options.headIndex)
            headIndex = options.headIndex;
        else
            headIndex = 0;

        return $tables.each(function () {
            var table_css = $(this).prop('class');
            var $stacktable = $('<table class="' + table_css + ' stacktable small-only"><tbody></tbody></table>');
            if (typeof settings.myClass !== 'undefined') $stacktable.addClass(settings.myClass);
            var markup = '';
            var $table, $caption, $topRow, headMarkup, bodyMarkup, tr_class, displayHeader;

            $table = $(this);
            $table.addClass('stacktable large-only');
            $caption = $table.find(">caption").clone();
            $topRow = $table.find('>thead>tr,>tbody>tr,>tfoot>tr').eq(0);

            displayHeader = $table.data('display-header') === undefined ? settings.displayHeader : $table.data('display-header');

            // using rowIndex and cellIndex in order to reduce ambiguity
            $table.find('>tbody>tr, >thead>tr').each(function (rowIndex) {

                // declaring headMarkup and bodyMarkup, to be used for separately head and body of single records
                headMarkup = '';
                bodyMarkup = '';
                tr_class = $(this).prop('class');

                // for the first row, "headIndex" cell is the head of the table
                if (rowIndex === 0) {
                    // the main heading goes into the markup variable
                    if (displayHeader) {
                        markup += '<tr class=" ' + tr_class + ' "><th class="st-head-row st-head-row-main bg-light" colspan="2">' + $(this).find('>th,>td').eq(headIndex).html() + '</th></tr>';
                    }
                } else {
                    // for the other rows, put the "headIndex" cell as the head for that row
                    // then iterate through the key/values
                    $(this).find('>td,>th').each(function (cellIndex) {
                        if (cellIndex === headIndex) {
                            headMarkup = '<tr class="' + tr_class + '"><th class="st-head-row" colspan="2">' + $(this).html() + '</th></tr>';
                        } else {
                            if ($(this).html() !== '') {
                                bodyMarkup += '<tr class="' + tr_class + '">';
                                if ($topRow.find('>td,>th').eq(cellIndex).html()) {
                                    bodyMarkup += '<td class="st-key">' + $topRow.find('>td,>th').eq(cellIndex).html() + '</td>';
                                } else {
                                    bodyMarkup += '<td class="st-key"></td>';
                                }
                                bodyMarkup += '<td class="st-val ' + $(this).prop('class') + '">' + $(this).html() + '</td>';
                                bodyMarkup += '</tr>';
                            }
                        }
                    });

                    markup += headMarkup + bodyMarkup;
                }
            });

            $stacktable.prepend($caption);
            $stacktable.append($(markup));
            $table.before($stacktable);
        });
    };

    $.fn.stackcolumns = function (options) {
        var $tables = this,
            defaults = {},
            settings = $.extend({}, defaults, options);

        return $tables.each(function () {
            var $table = $(this);
            var $caption = $table.find(">caption").clone();
            var num_cols = $table.find('>thead>tr,>tbody>tr,>tfoot>tr').eq(0).find('>td,>th').length; //first table <tr> must not contain colspans, or add sum(colspan-1) here.
            if (num_cols < 3) //stackcolumns has no effect on tables with less than 3 columns
                return;

            var $stackcolumns = $('<table class="stacktable small-only"></table>');
            if (typeof settings.myClass !== 'undefined') $stackcolumns.addClass(settings.myClass);
            $table.addClass('stacktable large-only');
            var tb = $('<tbody></tbody>');
            var col_i = 1; //col index starts at 0 -> start copy at second column.

            while (col_i < num_cols) {
                $table.find('>thead>tr,>tbody>tr,>tfoot>tr').each(function (index) {
                    var tem = $('<tr></tr>'); // todo opt. copy styles of $this; todo check if parent is thead or tfoot to handle accordingly
                    if (index === 0) tem.addClass("st-head-row st-head-row-main");
                    var first = $(this).find('>td,>th').eq(0).clone().addClass("st-key");
                    var target = col_i;
                    // if colspan apply, recompute target for second cell.
                    if ($(this).find("*[colspan]").length) {
                        var i = 0;
                        $(this).find('>td,>th').each(function () {
                            var cs = $(this).attr("colspan");
                            if (cs) {
                                cs = parseInt(cs, 10);
                                target -= cs - 1;
                                if ((i + cs) > (col_i)) //out of current bounds
                                    target += i + cs - col_i - 1;
                                i += cs;
                            } else {
                                i++;
                            }

                            if (i > col_i)
                                return false; //target is set; break.
                        });
                    }
                    var second = $(this).find('>td,>th').eq(target).clone().addClass("st-val").removeAttr("colspan");
                    tem.append(first, second);
                    tb.append(tem);
                });
                ++col_i;
            }

            $stackcolumns.append($(tb));
            $stackcolumns.prepend($caption);
            $table.before($stackcolumns);
        });
    };

    $.fn.procedureTable = function (){
        var $tables = this;
        return $tables.each(function () {
            let wrapper = $(this)
            let showAll = wrapper.find('[data-procedure-show-all]')
            let hideAll = wrapper.find('[data-procedure-collapse-all]')
            let instances = [];
            let syncAllToggle = function () {
                if (wrapper.find('[data-procedure].show').length === instances.length) {
                    showAll.hide()
                    hideAll.show()
                }
                if (wrapper.find('[data-procedure].show').length === 0) {
                    showAll.show()
                    hideAll.hide()
                }
            }
            wrapper.find('[data-procedure]').each(function () {
                let instance = bootstrap.Collapse.getOrCreateInstance(this, {
                    toggle: false
                });
                this.addEventListener('hidden.bs.collapse', event => {
                    syncAllToggle()
                })
                this.addEventListener('shown.bs.collapse', event => {
                    syncAllToggle()
                })
                this.addEventListener('hide.bs.collapse', event => {
                    let collapse = $(event.target)
                    collapse.prev().find('[data-procedure-show]').show()
                    collapse.prev().find('[data-procedure-collapse]').hide()
                    collapse.parents('.procedure-item').find('.procedure-item-header').removeClass('procedure-item-header-open')
                })
                this.addEventListener('show.bs.collapse', event => {
                    let collapse = $(event.target)
                    collapse.prev().find('[data-procedure-show]').hide()
                    collapse.prev().find('[data-procedure-collapse]').show()
                    collapse.parents('.procedure-item').find('.procedure-item-header').addClass('procedure-item-header-open')
                })
                instances.push(instance);
            })
            wrapper.find('[data-procedure-toggle]').on('click', function (e) {
                e.preventDefault();
                let action;
                if (showAll.is(':visible')) {
                    showAll.hide()
                    hideAll.show()
                    action = 'show'
                } else {
                    showAll.show()
                    hideAll.hide()
                    action = 'hide'
                }
                $.each(instances, function () {
                    if (action === 'show') {
                        this.show()
                    } else {
                        this.hide()
                    }
                })
            })
        });
    };
}(jQuery));
$(document).ready(function () {
    $('table.responsive-stack').each(function () {
        var table = $(this);
        if (table.find('th').length > 0) {
            var parent = $(this).parent();
            if (table.width() > parent.width()) {
                $(this).stacktable();
                parent.find('.large-only').css('display', 'none');
                parent.find('.small-only').css('display', 'table');
            }
        }
    });
    $('table.responsive-card').each(function () {
        var table = $(this);
        if (table.find('th').length > 0) {
            var parent = $(this).parent();
            if (table.width() > parent.width()) {
                $(this).cardtable();
                parent.find('.large-only').css('display', 'none');
                parent.find('.small-only').css('display', 'table');
            }
        }
    });
    $('table.responsive-column').each(function () {
        var table = $(this);
        if (table.find('th').length > 0) {
            var parent = $(this).parent();
            if (table.width() > parent.width()) {
                $(this).stackcolumns();
                parent.find('.large-only').css('display', 'none');
                parent.find('.small-only').css('display', 'table');
            }
        }
    });
    $('.table-procedure-wrapper').procedureTable();
});
function OpenCityFullCalendarInit(baseUrl, language, BlockCalendarEndpoint, CalendarId, CalendarView, MaxEvents) {
    var BlockCalendarBuildQuery = function (calendarId) {
        var container = $('#' + calendarId).parent();
        var topics = container.data('topics').toString();
        var query;
        if (typeof container.data('query') !== 'undefined') {
            query = container.data('query');
        } else {
            var classList = [];
            container.find('.btn-secondary[data-block_calendar_class]').each(function () {
                classList.push($(this).data('block_calendar_class'));
            });
            query = 'classes [' + classList.join(',') + ']';
        }
        if (topics.length > 0) {
            query += ' and raw[submeta_topics___main_node_id____si] in [' + topics + ']';
        }
        return query;
    };
    var BlockCalendarBaseOptions = {
        // plugins: ['interaction', 'dayGrid', 'list'],
        // themeSystem: 'bootstrap5',
        headerToolbar: {
            left: '',
            center: 'title',
            right: 'today'
        },
        footerToolbar: {
            left: '',
            center: 'prev,next',
            right: ''
        },
        locale: language,
        dayMaxEventRows : false,
        dayHeaderFormat: {
            weekday: 'short',
            day: 'numeric',
            omitCommas: true
        },
        eventClick: function (info) {
            window.location.href = info.event.extendedProps.content?.extradata[$.opendataTools.settings('language')]?.urlAlias || baseUrl + 'openpa/object/' + info.event.id;
        },
        displayEventTime: false,
        eventContent: function (info) {
            $(info.el)
                .find('.fc-content, .fc-list-item-title')
                .html(info.event.title)
                .css('cursor', 'pointer');
        },
        events: {
            url: BlockCalendarEndpoint,
            extraParams: function () {
                return {q: BlockCalendarBuildQuery(CalendarId)};
            }
        }
    };
    $('[data-block_calendar_class]').on('click', function (e) {
        var self = $(this);
        var container = self.parents('.block-calendar');
        if (self.hasClass('btn-secondary')) {
            self.removeClass('btn-secondary').addClass('btn-outline-secondary');
        } else {
            container.find('.filter-select').removeClass('btn-secondary').addClass('btn-outline-secondary');
            self.addClass('btn-secondary').removeClass('btn-outline-secondary');
        }
        container.find('.fc').data('fullcalendar').refetchEvents();
        e.preventDefault();
    });
    var calendarEl = document.getElementById(CalendarId);
    var options = {};
    if (calendarEl != null) {
        if (CalendarView === 'month') {
            options = $.extend({}, BlockCalendarBaseOptions, {
                initialView: 'dayGridMonth',
                views: {
                    dayGridMonth: {
                        dayMaxEventRows : true,
                        columnHeaderFormat: {
                            weekday: 'short'
                        }
                    }
                },
                dayHeaderContent: function (arg) {
                    var date = arg.date;
                    return {'html': '<div class="day-title text-uppercase"><span>' + moment(date).format('ddd') + '</span></div>'};
                },
                windowResize: function (view) {
                    var windowWidth = $(window).width();
                    if (windowWidth < 800) {
                        this.setOption('aspectRatio', 0.6);
                        this.changeView('listWeek');
                    } else {
                        this.setOption('aspectRatio', 1.35);
                        this.changeView('dayGridMonth');
                    }
                },
            });
        } else if (CalendarView === 'day_grid') {
            options = $.extend({}, BlockCalendarBaseOptions, {
                initialView: 'dayGridWeek',
                views: {
                    dayGridWeek: {
                        dayMaxEventRows : MaxEvents
                    }
                },
                aspectRatio: 2,
                dayHeaderContent: function (arg) {
                    var date = arg.date;
                    return {'html': '<div class="day-title text-uppercase">' + moment(date).format('D') + '<span> ' + moment(date).format('ddd') + '</span></div>'};
                },
                windowResize: function (view) {
                    var windowWidth = $(window).width();
                    if (windowWidth < 800) {
                        this.setOption('aspectRatio', 0.6);
                        this.changeView('listWeek');
                    } else {
                        this.setOption('aspectRatio', 2);
                        this.changeView('dayGridWeek');
                    }
                },
            });
        } else {
            options = $.extend({}, BlockCalendarBaseOptions, {
                initialView: 'dayGridWeek',
                views: {
                    dayGridWeek: {
                        dayMaxEventRows : true,
                        duration: {days: 4},
                        titleFormat: {year: 'numeric', month: 'long'}
                    }
                },
                dayHeaderContent: function (arg) {
                    var date = arg.date;
                    return {'html': '<div class="day-title">' + moment(date).format('D') + '<span>' + moment(date).format('ddd') + '</span></div>'};
                },
                aspectRatio: 3.4,
                windowResize: function (view) {
                    var windowWidth = $(window).width();
                    if (windowWidth < 800) {
                        this.setOption('aspectRatio', 0.6);
                        this.changeView('listWeek');
                    } else {
                        this.setOption('aspectRatio', 3.4);
                        this.changeView('dayGridWeek');
                    }
                },
            });
        }
    }

    // console.log(baseUrl, language, BlockCalendarEndpoint, CalendarId, CalendarView, MaxEvents, options);

    return new FullCalendar.Calendar(calendarEl, options);
}
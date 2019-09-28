;(function ($, window, document, undefined) {

    /*
    $('#searchModal').on('search_gui_initialized', function (event, searchGui) {
        searchGui.activateSubtree('1');
        searchGui.activateTopic('2');
        searchGui.activateFrom('05/12/1977');
        searchGui.activateTo('05/12/2017');
        searchGui.activateActiveContent();
    });
     */

    'use strict';

    var pluginName = 'searchGui',
        defaults = {
            'spritePath': '/',
            'i18n': {
                search: 'Cerca',
                filters: 'Filtri',
                sections: 'Sezioni',
                remove: 'Elimina'
            }
        };

    function Plugin(element, options) {
        this.settings = $.extend({}, defaults, options);

        this.modalContainer = $(element);
        this.searchHeader = $('.search-gui-header');
        this.searchGui = $('.search-gui');
        this.filtersGui = $('.filters-gui');

        this.toggleSectionSearch = $('#toggleSectionSearch');
        this.toggleGlobalSearch = $('#toggleGlobalSearch');
        this.toggleSearch = $('#toggleSearch');

        this.triggerSubtree = $('.trigger-subtree');
        this.triggerTopic = $('.trigger-topic');
        this.triggerOption = $('.trigger-option');

        this.spritePath = this.settings.spritePath;

        this.allSubtreeToggle = $('a[data-subtree_group="all"]');
        this.allTopicsToggle = $('.search-filter-by-topic a.chip:first');
        this.allOptionsToggle = $('.search-filter-by-option a.chip:first');

        this.allSectionToggle = $('.section-search-form-filters a:first');
        this.subTreeGroupSelector = $('a[data-subtree_group]');

        this.fromDateInput = $('#datepicker_start').datepicker({
            inputFormat: ['dd/MM/yyyy'],
            outputFormat: 'dd/MM/yyyy',
        });
        this.toDateInput = $('#datepicker_end').datepicker({
            inputFormat: ['dd/MM/yyyy'],
            outputFormat: 'dd/MM/yyyy',
        });
        this.activeContentCheck = $('#OnlyActive');

        this.addListeners();
    }

    $.extend(Plugin.prototype, {

        addListeners: function () {
            var plugin = this;

            this.searchHeader.find('button.back-to-search').on('click', function (e) {
                plugin.showSearchGui();
                e.preventDefault();
            });

            this.toggleGlobalSearch.on('click', function (e) {
                plugin.showSearchGui();
                plugin.setGlobalFilterGui();
                plugin.modalContainer.modal();
                e.preventDefault();
            });

            this.toggleSectionSearch.on('click', function (e) {
                var currentSection = $(this).data('section_subtree');
                if (currentSection) {
                    plugin.hideSearchGui();
                    plugin.showFilterGui('filter-by-section');
                    plugin.setSectionFilterGui(currentSection);
                    plugin.modalContainer.modal();
                }
                e.preventDefault();
            });

            this.toggleSearch.on('click', function (e) {
                plugin.toggleGlobalSearch.trigger('click');
                e.preventDefault();
            });

            this.triggerSubtree.on('click', function (e) {
                plugin.showFilterGui('filter-by-section');
                e.preventDefault();
            });

            this.triggerTopic.on('click', function (e) {
                plugin.showFilterGui('filter-by-topic');
                e.preventDefault();
            });

            this.triggerOption.on('click', function (e) {
                plugin.showFilterGui('filter-by-option');
                e.preventDefault();
            });

            this.allSectionToggle.on('click', function (e) {
                var chips = $('.section-search-form-filters a');
                var last = chips.length - 1;
                if (chips.length > 2) {
                    chips.each(function (index) {
                        if (index > 0 && index < last) {
                            $(this).trigger('click');
                        }
                    });
                }
                e.preventDefault();
            });

            this.subTreeGroupSelector.on('click', function (e) {
                var self = $(this);
                var subtree = self.data('subtree_group');
                if (subtree === 'all') {
                    plugin.subTreeGroupSelector.removeClass('selected');
                    $('input[data-subtree]').prop('checked', false).prop('indeterminate', false).each(function () {
                        plugin.onChangeSubtree($(this));
                    });
                } else if (!self.hasClass('selected')) {
                    plugin.allSubtreeToggle.removeClass('selected');
                    $('input[data-subtree="' + subtree + '"], input[data-main_subtree="' + subtree + '"]').prop('checked', true);
                    plugin.onChangeSubtree($('input[data-subtree="' + subtree + '"]'));
                }
                self.addClass('selected');
                e.preventDefault();
            });

            $('input[data-subtree]').on('change', function () {
                var self = $(this);
                plugin.onChangeSubtree(self);
            });

            $('input[data-topic]').on('change', function () {
                var self = $(this);
                plugin.onChangeTopic(self);
            });

            this.allTopicsToggle.on('click', function (e) {
                $('a[data-topic].chip').trigger('click');
                e.preventDefault();
            });

            this.fromDateInput.on('change', function () {
                plugin.onChangeDatePicker();
            });

            this.toDateInput.on('change', function () {
                plugin.onChangeDatePicker();
            });

            this.activeContentCheck.on('change', function () {
                var self = $(this);
                plugin.onChangeActiveContent(self);
            });

            this.allOptionsToggle.on('click', function (e) {
                if (plugin.activeContentCheck.is(':checked')) {
                    plugin.activeContentCheck.trigger('click');
                }
                plugin.fromDateInput.val('');
                plugin.toDateInput.val('').trigger('change');
                e.preventDefault();
            });

            this.modalContainer.trigger('search_gui_initialized', this);
        },

        activateTopic: function(topicId){
            var plugin = this;
            $('input[data-topic="'+topicId+'"]').prop('checked', true).each(function () {
                plugin.onChangeTopic($(this));
            });
        },

        activateSubtree: function(subtreeId){
            var plugin = this;
            $('input[data-subtree="'+subtreeId+'"]').each(function () {
                $(this).prop('checked', true);
                plugin.onChangeSubtree($(this));
            });
        },

        activateActiveContent: function(){
            var plugin = this;
            this.activeContentCheck.prop('checked', true).each(function () {
                plugin.onChangeActiveContent($(this));
            });
        },

        activateFrom: function(value){
            this.fromDateInput.val(value).trigger('change');
        },

        activateTo: function(value){
            this.toDateInput.val(value).trigger('change');
        },

        showSearchGui: function () {
            this.searchGui.removeClass('hide');
            this.filtersGui.addClass('hide');
            this.searchHeader.find('h1').text(plugin.settings.i18n.search);
            this.searchHeader.find('button.close').removeClass('hide');
            this.searchHeader.find('button.back-to-search').addClass('hide');
        },

        hideSearchGui: function () {
            this.searchGui.addClass('hide');
        },

        showFilterGui: function (activeTab) {
            var plugin = this;
            this.filtersGui.find('a.nav-link[href="#' + activeTab + '"]').tab('show');
            this.searchGui.addClass('hide');
            this.filtersGui.removeClass('hide');
            this.searchHeader.find('h1').text(plugin.settings.i18n.filters);
            this.searchHeader.find('button.close').addClass('hide');
            this.searchHeader.find('button.back-to-search').removeClass('hide');
        },

        setGlobalFilterGui: function () {
            var plugin = this;
            $('[data-subtree_group]').removeClass('hide');
            $('input[data-subtree]').parent().removeClass('hide');
            $('a[href="#filter-by-section"]').text(plugin.settings.i18n.sections);
            this.filtersGui.find('.do-search').removeClass('hide');
        },

        setSectionFilterGui: function (currentSubtree) {
            var plugin = this;
            var title = $('input[data-subtree="' + currentSubtree + '"]').next().text();
            $('a[href="#filter-by-section"]').text(title);
            $('#filter-by-section').find('[data-subtree_group]').each(function () {
                var self = $(this);
                var subtree = self.data('subtree_group');
                if (subtree !== currentSubtree) {
                    self.addClass('hide');
                    self.find('input[data-subtree], input[data-main_subtree]').prop('checked', false).each(function () {
                        plugin.onChangeSubtree($(this));
                    });
                }
            }).find('input[data-subtree="' + currentSubtree + '"]').parent().addClass('hide');

            this.searchHeader.find('button.close').removeClass('hide');
            this.searchHeader.find('button.back-to-search').addClass('hide');
            this.filtersGui.find('.do-search').addClass('hide');
        },

        onChangeSubtree: function (self) {
            var plugin = this;
            var subtree = self.data('subtree');
            var mainSubtree = self.data('main_subtree');
            var isChecked = self.is(':checked');
            var allUnchecked = false;
            var subtreeName = $.trim(self.next().text());
            if (typeof mainSubtree === 'undefined') {
                allUnchecked = !isChecked;
                mainSubtree = subtree;
                self.parents('div[data-subtree_group]').find('input[data-main_subtree]').prop('checked', isChecked).each(function () {
                    if(!isChecked){
                        plugin.removeSectionSubtreeChip($(this).data('subtree'));
                    }else{
                        plugin.appendSectionSubtreeChip($(this).data('subtree'), $.trim($(this).next().text()), $(this).data('main_subtree'));
                    }
                });
            } else {
                var allChecked = self.parents('div[data-subtree_group]').find('input[data-main_subtree]:checked').length === self.parents('div[data-subtree_group]').find('input[data-main_subtree]').length;
                allUnchecked = self.parents('div[data-subtree_group]').find('input[data-main_subtree]:checked').length === 0;
                var indeterminate = self.parents('div[data-subtree_group]').find('input[data-main_subtree]:checked').length > 0 && allChecked === false;
                self.parents('div[data-subtree_group]').find('input[data-subtree]:first').prop('indeterminate', indeterminate).prop('checked', allChecked);
            }
            if (isChecked) {
                plugin.allSubtreeToggle.removeClass('selected');
                $('a[data-subtree_group="' + mainSubtree + '"]').addClass('selected');
                plugin.appendSectionSubtreeChip(subtree, subtreeName, self.data('main_subtree'));

            } else {
                plugin.removeSectionSubtreeChip(subtree);
                if (allUnchecked) {
                    $('a[data-subtree_group="' + mainSubtree + '"]').removeClass('selected');
                    if ($('a[data-subtree_group].selected').length === 0) {
                        plugin.allSubtreeToggle.addClass('selected');
                    }
                }
            }
            plugin.refreshSectionChipToggle();
        },

        appendSectionChip: function(element){
            this.toggleSectionSearch.before(element);
            this.toggleSearch.before(element);
        },

        refreshSectionChipToggle: function () {
            var plugin = this;
            if ($('.section-search-form-filters a').length === 2) {
                plugin.allSectionToggle.addClass('selected');
            } else {
                plugin.allSectionToggle.removeClass('selected');
            }
        },

        appendSectionSubtreeChip: function (subtree, subtreeName, mainSubtree) {
            var plugin = this;
            if ($('a[data-subtree="' + subtree + '"].section-chip').length === 0) {
                var button = $('<a href="#" data-subtree="' + subtree + '" class="section-chip chip chip-lg selected"><span class="chip-label">' + subtreeName + '</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">Elimina</span><input type="hidden" name="Subtree[]" value="' + subtree + '" /></a>');
                button.on('click', function (e) {
                    $('input[data-subtree="' + $(this).data('subtree') + '"]').prop('checked', false).each(function () {
                        plugin.onChangeSubtree($(this));
                    });
                    e.preventDefault();
                });
                plugin.toggleSearch.before(button);
                if ($('input[name="SubtreeBoundary"][value="' + mainSubtree + '"]').length > 0) {
                    plugin.toggleSectionSearch.before(button);
                }
            }
        },

        removeSectionSubtreeChip: function (subtree) {
            $('a[data-subtree="' + subtree + '"].section-chip').remove();
        },

        appendTopicChip: function (id, name) {
            var plugin = this;
            var onClick = function (topic) {
                $('input[data-topic="' + topic + '"]').trigger('click');
            };
            var chip = $('<a href="#" data-topic="' + id + '" class="chip chip-simple chip-lg selected"><span class="chip-label">' + name + '</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">Elimina</span></a>');
            chip.on('click', function (e) {
                onClick($(this).data('topic'));
                e.preventDefault();
            });
            plugin.triggerTopic.before(chip);

            var sectionChip = $('<a href="#" data-topic="' + id + '" class="section-chip chip chip-lg selected"><span class="chip-label">' + name + '</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">Elimina</span><input type="hidden" name="Topic[]" value="' + id + '" /></a>');
            sectionChip.on('click', function (e) {
                onClick($(this).data('topic'));
                e.preventDefault();
            });
            plugin.appendSectionChip(sectionChip);

            plugin.refreshTopicChipToggle();
        },

        removeTopicChip: function (id) {
            $('a[data-topic="' + id + '"].chip').remove();
            $('a[data-topic="' + id + '"].section-chip').remove();

            this.refreshTopicChipToggle();
        },

        refreshTopicChipToggle: function () {
            var allUnchecked = $('input[data-topic]:checked').length === 0;
            var allToggle = this.allTopicsToggle;
            if (allUnchecked) {
                allToggle.addClass('selected');
            } else {
                allToggle.removeClass('selected');
            }
            this.refreshSectionChipToggle();
        },

        onChangeTopic: function (self) {
            var isChecked = self.is(':checked');
            var topic = self.data('topic');
            if (isChecked) {
                var topicName = self.next().text();
                this.appendTopicChip(topic, topicName);
            } else {
                this.removeTopicChip(topic);
            }
        },

        refreshOptionChipToggle: function () {
            var start = this.fromDateInput.val();
            var end = this.toDateInput.val();
            var allUnchecked = !this.activeContentCheck.is(':checked') && start === '' && end === '';
            if (allUnchecked) {
                this.allOptionsToggle.addClass('selected');
            } else {
                this.allOptionsToggle.removeClass('selected');
            }
        },

        toggleDateChip: function (text, from, to) {
            var plugin = this;
            var onClick = function () {
                plugin.fromDateInput.val('');
                plugin.toDateInput.val('').trigger('change');
            };
            var chip = $('a[data-datarange].chip');
            var sectionChip = $('a[data-datarange].section-chip');
            if (chip.length > 0) {
                if (text.length === 0) {
                    chip.remove();
                    sectionChip.remove();
                } else {
                    chip.find('span.chip-label').text(text);
                    sectionChip.find('span:first').text(text);
                }
            } else if (text.length > 0) {
                chip = $('<a href="#" data-datarange="1" class="chip chip-simple chip-lg selected"><span class="chip-label">' + text + '</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">'+plugin.settings.i18n.remove+'</span></a>');
                sectionChip = $('<a href="#" data-datarange="1" class="section-chip chip chip-lg selected"><span class="chip-label">' + text + '</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">'+plugin.settings.i18n.remove+'</span></a>');
                if (from.length > 0) {
                    $('<input type="hidden" name="From" value="' + from + '" />').appendTo(sectionChip);
                }
                if (to.length > 0) {
                    $('<input type="hidden" name="To" value="' + to + '" />').appendTo(sectionChip);
                }
                chip.on('click', function (e) {
                    onClick();
                    e.preventDefault();
                });
                $('.trigger-option').before(chip);
                sectionChip.on('click', function (e) {
                    onClick();
                    e.preventDefault();
                });
                plugin.appendSectionChip(sectionChip);
            }
            plugin.refreshSectionChipToggle();
        },

        addActiveContentChip: function () {
            var plugin = this;
            var chip = $('<a href="#" data-only_active="1" class="chip chip-simple chip-lg selected"><span class="chip-label">Contenuti attivi</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">'+plugin.settings.i18n.remove+'</span></a>');
            var sectionChip = $('<a href="#" data-only_active="1" class="section-chip chip chip-lg selected"><span class="chip-label">Contenuti attivi</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">Elimina</span><input type="hidden" name="OnlyActive" value="1" /></a>');
            chip.on('click', function (e) {
                plugin.activeContentCheck.trigger('click');
                e.preventDefault();
            });
            $('.trigger-option').before(chip);
            sectionChip.on('click', function (e) {
                plugin.activeContentCheck.trigger('click');
                e.preventDefault();
            });
            plugin.appendSectionChip(sectionChip);
        },

        removeActiveContentChip: function () {
            $('a[data-only_active].chip').remove();
            $('a[data-only_active].section-chip').remove();
        },

        onChangeDatePicker: function () {
            var start = this.fromDateInput.val();
            var end = this.toDateInput.val();
            var text = '';
            if (start.length > 0) {
                text += 'Da ' + start + ' ';
            }
            if (end.length > 0) {
                text += 'Fino a ' + end;
            }
            this.toggleDateChip(text, start, end);
            this.refreshOptionChipToggle();
        },

        onChangeActiveContent: function (self) {
            var isChecked = self.is(':checked');
            if (isChecked) {
                this.addActiveContentChip();
            } else {
                this.removeActiveContentChip();
            }
            this.refreshOptionChipToggle();
            this.refreshSectionChipToggle();
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


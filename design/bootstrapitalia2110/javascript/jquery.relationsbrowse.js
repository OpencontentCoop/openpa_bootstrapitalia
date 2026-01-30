;(function ($, window, document, undefined) {

    "use strict";

    var pluginName = "relationsbrowse",
        defaults = {
            attributeId: 0,
            subtree: 1,
            classes: false,
            selectionType: 'multiple',
            language: 'ita-IT',
            browsePaginationLimit: 10,
            browseSort: 'name',
            browseOrder: '1',
            allowAllBrowse: false,
            openInSearchMode: false,
            addCloseButton: false,
            initOnCreate: false,
            baseUrl: '/',
            i18n:{
                clickToClose: "Clicca per chiudere la finestra",
                clickToOpenSearch: "Clicca per aprire il motore di ricerca",
                search: "Cerca",
                clickToBrowse: "Clicca per navigare nell'alberatura dei contenuti",
                browse: "Naviga",
                createNew: "Crea nuovo",
                create: "Crea",
                allContents: "Tutti i contenuti",
                clickToBrowseParent: "Clicca per accedere al ramo superiore dell'alberatura",
                noContents: "Nessun contenuto",
                back: "Torna indietro",
                goToPreviousPage: "Vai alla pagina precedente",
                goToNextPage: "Vai alla pagina successiva",
                clickToBrowseChildren: "Clicca per accedere agli elementi contenuti",
                clickToPreview: "Visualizza l'anteprima contenuto",
                preview: "Anteprima",
                closePreview: "Chiudi anteprima",
                addItem: "Aggiungi",
                selectedItems: "Elementi selezionati",
                removeFromSelection: "Rimuovi dalla selezione",
                addToSelection: "Aggiungi alla selezione",
                findByName: 'Cerca per titolo',
                sort: 'Ordinamento',
                order: 'Direzione',
                inChildren: 'nei contenuti figli',
                inTree: 'in tutto il sotto albero',
                published: 'data di pubblicazione',
                modified: 'data di modifica',
                priority: 'priorità',
                name: 'titolo',
                ascending: 'ascendente',
                descending: 'discendente',
                content: 'contenuto',
                contents: 'contenuti',
                page: 'pagina',
                of: 'di',
                hidden: "Nascosto"
            },
            pagination: true,
            searchMode: 'disabled',
        };

    function Plugin(element, options) {
        this.element = element;
        var i18n = $.extend({}, defaults.i18n, options.i18n);
        this.settings = $.extend({}, defaults, options);
        this.settings.i18n = i18n;
        if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            this.settings.baseUrl = UriPrefix + '/';
        }
        this._defaults = defaults;
        this._name = pluginName;
        this.selection = [];
        this.subtreeRootList = [];
        this.browseParameters = {};
        this.rootNode = 'undefined';
        if (this.settings.searchMode === 'disabled'){
            this.settings.openInSearchMode = false
        }
        this.resetBrowseParameters();

        this.isInit = false;
        if(this.settings.initOnCreate){
            this.doInit();
        }
        
        this.init = function(){
            this.doInit();
        };

        this.reset = function(){
            this.resetBrowseParameters();
            this.buildTreeSelect();             
        };
    }

    // Avoid Plugin.prototype conflicts
    $.extend(Plugin.prototype, {
        
        doInit: function (refresh) {
            if (!this.isInit || refresh){
                $(this.element).html('')
                this.browserContainer = $('<div class="card-wrapper card-space"></div>').appendTo($(this.element));
                this.browserPanel = $('<div class="card card-bg no-after"></div>').appendTo($(this.browserContainer));
                this.browserPanelHeading = $('<div class="card-header clearfix" style="padding:15px"></div>').appendTo(this.browserPanel);
                this.browserPanelSearchForm = $('<form class="row gx-2 p-2 bg-100"></form>').appendTo(this.browserPanel);
                this.browserPanelContent = $('<div class="list-wrapper"></div>').appendTo(this.browserPanel);
                if (!this.settings.pagination){
                    this.browserPanelContent.css({'max-height': '780px', 'overflow-y': 'auto'})
                }
                this.browserPanelFooter = $('<div class="card-footer clearfix"></div>').appendTo(this.browserPanel);
                this.buildTreeSelect();
                if (this.settings.openInSearchMode){
                    this.resetBrowseParameters();
                    this.buildSearchSelect();
                    this.searchInput.trigger('keyup');
                }

                if (typeof $.fn.alpaca !== 'undefined') {
                    var RelationsBrowseConnector = Alpaca.Connector.extend({
                        loadAll: function (resources, onSuccess, onError) {
                            var self = this;

                            var resourceUri = self._buildResourceUri();

                            var onConnectSuccess = function () {

                                var loaded = {};

                                var doMerge = function (p, v1, v2) {
                                    loaded[p] = v1;

                                    if (v2) {
                                        if ((typeof (loaded[p]) === "object") && (typeof (v2) === "object")) {
                                            Alpaca.mergeObject(loaded[p], v2);
                                        } else {
                                            loaded[p] = v2;
                                        }
                                    }
                                };

                                self._handleLoadJsonResource(
                                    resourceUri,
                                    function (response) {
                                        doMerge("data", resources.data, response.data);
                                        doMerge("options", resources.options, response.options);
                                        doMerge("schema", resources.schema, response.schema);
                                        doMerge("view", resources.view, response.view);
                                        onSuccess(loaded.data, loaded.options, loaded.schema, loaded.view);
                                    },
                                    function (loadError) {
                                        if (onError && Alpaca.isFunction(onError)) {
                                            onError(loadError);
                                        }
                                    }
                                );
                            };

                            var onConnectError = function (err) {
                                if (onError && Alpaca.isFunction(onError)) {
                                    onError(err);
                                }
                            };

                            self.connect(onConnectSuccess, onConnectError);
                        },
                        _buildResourceUri: function () {
                            var self = this;

                            var prefix = '/';
                            if ($.isFunction($.ez)) {
                                prefix = $.ez.root_url;
                            } else if (self.config.prefix) {
                                prefix = self.config.prefix;
                            }

                            return prefix + "forms/connector/" + self.config.connector + "/?" + $.param(self.config.params);
                        }
                    });
                    Alpaca.registerConnectorClass("relationsbrowse", RelationsBrowseConnector);
                }

                this.isInit = true;
            }
        },   

        resetBrowseParameters: function(){
            this.browseParameters = {
                subtree: this.browseParameters.subtree || this.settings.subtree || 1,
                limit: this.settings.browsePaginationLimit || 25,
                offset: 0,
                sort: this.settings.browseSort || 'priority',
                order: this.settings.browseOrder || 1
            };            
        },

        buildPanelHeader: function(isTree,isSearch){
            var self = this;
            self.browserPanelHeading.html('')
            self.browserPanelSearchForm.html('')

            if (self.settings.addCloseButton) {
                var closeButton = $('<a class="btn btn-xs btn-link pull-right" href="#" title="'+self.settings.i18n.clickToClose+'"><span class="glyphicon glyphicon-remove"></span></a>');
                closeButton.bind('click', function (e) {
                    $(self.element).trigger('relationsbrowse.close', self);
                    e.preventDefault();
                });
                self.browserPanelHeading.append(closeButton);
            }

            if (isTree) {
                if (self.settings.searchMode !== 'disabled') {
                    var searchButton = $('<a class="btn btn-xs btn-primary pull-right" href="#" title="' + self.settings.i18n.clickToOpenSearch + '"><span class="glyphicon glyphicon-search"></span> ' + self.settings.i18n.search + '</a>');
                    searchButton.bind('click', function (e) {
                        self.resetBrowseParameters();
                        self.buildSearchSelect();
                        e.preventDefault();
                    });
                    self.browserPanelHeading.append(searchButton);
                }
                self.browserPanelHeading.append('<a href="#" class="browse-spinner btn btn-xs btn-link pull-right" style="display: none;"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-fw"></i></a>');
                self.fetchBrowseSubtreeRoot(self.browseParameters.subtree, function (rootNode) {
                    var name = $('<h5></h5>');
                    if (typeof rootNode === 'string') {
                        $(name).html(rootNode);
                    } else if (typeof rootNode === 'object') {
                        var itemName = (rootNode.name.length > 50) ? rootNode.name.substring(0, 47) + '...' : rootNode.name;
                        $(name).html(itemName);
                        if (self.settings.subtree === self.browseParameters.subtree) {
                            self.rootNode = rootNode;
                        }
                        if (self.allowUpBrowse(rootNode)) {
                            var back = $('<a class="browse-back mr-2 me-2" href="#" data-node_id="' + rootNode.parent_node_id + '" title="' + self.settings.i18n.clickToBrowseParent + '"><i class="fa fa-arrow-circle-up"></i></a>').prependTo(name);
                            back.bind('click', function (e) {
                                self.browseParameters.subtree = $(this).data('node_id');
                                self.browseParameters.offset = 0
                                self.buildTreeSelect();
                                e.preventDefault();
                            });
                        } else {
                            $(name).html(itemName);
                        }
                    }
                    self.browserPanelHeading.append(name);
                });
                self.buildTreeForm()
            }

            if (isSearch){
                var treeButton = $('<a class="btn btn-xs btn-primary pull-right" href="#" title="'+self.settings.i18n.clickToBrowse+'"><span class="glyphicon glyphicon-th-list"></span> '+self.settings.i18n.browse+'</a>');
                treeButton.bind('click', function(e){
                    self.resetBrowseParameters();
                    self.buildTreeSelect();
                    e.preventDefault();
                });
                self.browserPanelHeading.append(treeButton);

                self.browserPanelHeading.append('<a href="#" class="browse-spinner btn btn-xs btn-link pull-right" style="display: none;"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-fw"></i></a>');
                self.browserPanelHeading.append('<h5>' + self.settings.i18n.search + '</h5>');
                self.fetchBrowseSubtreeRoot(self.browseParameters.subtree, function (rootNode) {
                        if (typeof rootNode === 'string'){
                            self.browserPanelHeading.find('h5').append(' in ' + rootNode);
                        }else if (typeof rootNode === 'object'){
                            var itemName = (rootNode.name.length > 50) ? rootNode.name.substring(0, 47) + '...' : rootNode.name;
                            self.browserPanelHeading.find('h5').append(' in ' + itemName);
                        }
                    });
                self.buildSearchForm()
            }


        },

        buildTreeForm: function () {
            var self = this;

            function generateId(prefix)
            {
                return prefix+Math.random().toString(36).replace(/[^a-z]+/g, '').substr(2, 10);
            }

            var rowInput = $('<div class="col-8"></div>').appendTo(self.browserPanelSearchForm);
            var rowFormGroup = $('<div class="form-group mb-0"></div>').appendTo(rowInput);
            var rowInputForm = $('<div></div>').appendTo(rowFormGroup);
            var textId = generateId('text')
            $('<label style="font-size:16px !important;margin-bottom:0 !important;height:39px;line-height:39px" for="'+textId+'">'+self.settings.i18n.findByName+'</label>').appendTo(rowInputForm);
            var clearButton = $('<a href="#" style="position: absolute;right: 10px;top:47px;"><i class="fa fa-times"></i></a>').on('click', function (e){
                e.preventDefault()
                self.filterNameInput.val('')
                $('[name="depthParam"]').attr('disabled', 'disabled')
                $(this).hide()
                self.browseParameters.offset = 0
                self.doBrowse()
            }).hide()
            self.filterNameInput = $('<input id="'+textId+'" class="form-control" type="text" placeholder="" value=""/>')
              .on('keyup', self._debounce(function(event) {
                  if (self.filterNameInput.val().length > 0){
                      clearButton.show()
                      $('[name="depthParam"]').removeAttr('disabled')
                  } else {
                      clearButton.hide()
                      $('[name="depthParam"]').attr('disabled', 'disabled')
                  }
                  self.browseParameters.offset = 0
                  self.doBrowse()
              }, 500))
              .appendTo(rowInputForm);
            clearButton.appendTo(rowInputForm);

            var defaultDepthId = generateId('depth')
            var defaultDepthWrapper = $('<div class="form-check form-check-inline"><label style="margin-bottom:0 !important;font-weight: normal;font-size: 16px !important;" class="form-check-label" for="'+defaultDepthId+'">'+self.settings.i18n.inChildren+'</label></div>')
              .appendTo(rowFormGroup);
            self.depthOption = $('<input disabled checked class="form-check-input" type="radio" name="depthParam" id="'+defaultDepthId+'">')
              .prependTo(defaultDepthWrapper)
              .on('change', function (e){
                  self.browseParameters.offset = 0
                  self.doBrowse()
              })
            var noDepthId = generateId('nodepth')
            var noDepthWrapper = $('<div class="form-check form-check-inline"><label style="margin-bottom:0 !important;font-weight: normal;font-size: 16px !important;" class="form-check-label" for="'+noDepthId+'">'+self.settings.i18n.inTree+'</label></div>')
              .appendTo(rowFormGroup);
            self.noDepthOption = $('<input disabled class="form-check-input" type="radio" name="depthParam" id="'+noDepthId+'">')
              .prependTo(noDepthWrapper)
              .on('change', function (e){
                  self.browseParameters.offset = 0
                  self.doBrowse()
              })

            var rowSort = $('<div class="col-2"></div>').appendTo(self.browserPanelSearchForm);
            var rowSortFormGroup = $('<div class="form-group mb-0"></div>').appendTo(rowSort);
            var sortId = generateId('sort')
            $('<label style="margin-bottom:0 !important;font-size:16px !important;height:39px;line-height:39px;" for="'+sortId+'">'+self.settings.i18n.sort+'</label>').appendTo(rowSortFormGroup);
            var sortList = [
                {value: 'published', label: self.settings.i18n.published},
                {value: 'modified', label: self.settings.i18n.modified},
                {value: 'priority', label: self.settings.i18n.priority},
                {value: 'name', label: self.settings.i18n.name}
            ]
            self.sortSelect = $('<select id="'+sortId+'" class="form-control"></select>')
              .on('change', function(event) {
                  self.browseParameters.offset = 0
                  self.doBrowse()
                  event.preventDefault();
              })
              .appendTo(rowSortFormGroup);
            $.each(sortList, function (){
                var isSelected = self.browseParameters.sort === this.value ? 'selected="selected"' : ''
                self.sortSelect.append($('<option value="'+this.value+'" '+isSelected+'>'+this.label+'</option>'))
            })

            var rowOrder = $('<div class="col-2"></div>').appendTo(self.browserPanelSearchForm);
            var rowOrderFormGroup = $('<div class="form-group mb-0"></div>').appendTo(rowOrder);
            var orderId = generateId('order')
            $('<label style="margin-bottom:0 !important;font-size:16px !important;height:39px;line-height:39px;" for="'+orderId+'">'+self.settings.i18n.order+'</label>').appendTo(rowOrderFormGroup);
            var orderList = [
                {value: '1', label: self.settings.i18n.ascending},
                {value: '0', label: self.settings.i18n.descending},
            ]
            self.orderSelect = $('<select id="'+orderId+'" class="form-control"></select>')
              .on('change', function(event) {
                  self.browseParameters.offset = 0
                  self.doBrowse()
                  event.preventDefault();
              })
              .appendTo(rowOrderFormGroup);
            $.each(orderList, function (){
                var isSelected = self.browseParameters.order === this.value ? 'selected="selected"' : ''
                self.orderSelect.append($('<option value="'+this.value+'" '+isSelected+'>'+this.label+'</option>'))
            })
        },

        buildSearchForm: function () {
            var self = this;

            var inputGroupButtonContainer = $('<div class="input-group-append"></div>');
            var doSearchButton = $('<button type="button" class="btn btn-info">'+self.settings.i18n.search+'</button>')
              .appendTo(inputGroupButtonContainer);
            var inputGroup = $('<div class="input-group"></div>');
            self.searchInput = $('<input class="form-control" type="text" placeholder="" value=""/>')
              .on('keydown', function(event) {
                  if (event.key === 'Enter') {
                      doSearchButton.trigger('click');
                      event.preventDefault();
                  }
              })
              .appendTo(inputGroup);
            inputGroupButtonContainer.appendTo(inputGroup);
            inputGroup.appendTo(self.browserPanelSearchForm);
            self.searchInput.focus();

            doSearchButton.bind('click', function(e){
                e.preventDefault();
                self.resetBrowseParameters();
                var query = self.buildQuery();
                self.doSearch(query);

            });

            self.searchInput.on('keyup', function (e) {
                if (e.keyCode === 13) {
                    doSearchButton.trigger('click');
                    e.preventDefault();
                }
            });
        },

        showSpinner: function(){
            this.browserContainer.find('.browse-spinner').show();
        },

        hideSpinner: function(){
            this.browserContainer.find('.browse-spinner').hide();
        },

        allowUpBrowse: function(current){
            if(!this.settings.allowAllBrowse){
                if (this.settings.subtree !== current.node_id){
                    return current.url_alias.search(this.rootNode.url_alias) > -1;
                }
                
                return false;
            }

            return true;
        },

        fetchBrowseSubtreeRoot: function(subtree, cb, context){
            var self = this;
            if (subtree > 1){

                if (self.subtreeRootList[subtree]){
                    if ($.isFunction(cb)) {
                        cb.call(context, self.subtreeRootList[subtree]);
                    }
                }else {
                    $.getJSON(self.settings.baseUrl + 'ezjscore/call/ezjscnode::load::' + subtree, function (data) {
                        if (data.error_text === '') {
                            self.subtreeRootList[subtree] = data.content;
                            if ($.isFunction(cb)) {
                                cb.call(context, self.subtreeRootList[subtree]);
                            }
                        } else {
                            alert(data.error_text);
                        }
                    });
                }
            }else{
                if ($.isFunction(cb)) {
                    cb.call(context, self.settings.i18n.allContents);
                }
            }
        },

        buildTreeSelect: function () {
            var self = this;

            self.buildPanelHeader(true, false);
            self.browserPanelContent.html('')
            self.browserPanelFooter.html('')

            self.doBrowse()
        },

        _debounce: function(func, wait, immediate) {
            var timeout;
            return function () {
                var context = this, args = arguments;
                var later = function () {
                    timeout = null;
                    if (!immediate) func.apply(context, args);
                };
                var callNow = immediate && !timeout;
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
                if (callNow) func.apply(context, args);
            };
        },

        doBrowse: function (){
            var self = this;
            self.showSpinner();
            var nameFilter = self.filterNameInput.val() || '';
            self.browseParameters.sort = self.sortSelect.val() || self.browseParameters.sort;
            self.browseParameters.order = self.orderSelect.val() || self.browseParameters.order;
            var depthParam = ''
            if (nameFilter.length && self.noDepthOption.is(':checked')){
                depthParam = '1'
            }
            var requestParams = [
                self.browseParameters.subtree,
                self.browseParameters.limit,
                self.browseParameters.offset,
                self.browseParameters.sort,
                self.browseParameters.order,
                nameFilter,
                depthParam,
                $.isArray(self.settings.classes) && self.settings.classes.length > 0 ? this.settings.classes.join(',')+'::1' : ''
            ]
            $.getJSON(self.settings.baseUrl + 'ezjscore/call/ezjscbrowse::subtree::'+requestParams.join('::'), function(data){
                if (self.settings.pagination) {
                    self.browserPanelContent.html('')
                }
                self.browserPanelFooter.html('')

                if (data.error_text === ''){
                    if (data.content.list.length > 0){
                        var list = $('<ul class="list-group" style="margin-bottom:0"></ul>');
                        var page = self.settings.i18n.page + ' ' + data.content.current_page  + ' ' + self.settings.i18n.of + ' ' + data.content.pages
                        if (data.content.total_count === 1){
                            $('<li class="list-group-item text-center py-1">1 '+self.settings.i18n.content+'</li>').appendTo(list);
                        }else{
                            $('<li class="list-group-item text-center py-1">'+data.content.total_count+' '+self.settings.i18n.contents+' - ' + page + '</li>').appendTo(list);
                        }
                        $.each(data.content.list, function(){

                            var item = {
                                contentobject_id: this.contentobject_id,
                                node_id: this.node_id,
                                name: this.name,
                                class_name: this.class_name,
                                class_identifier: this.class_identifier,
                                is_container: this.is_container,
                                thumbnail_url: this.thumbnail_url,
                                is_visible: !this.contentobject_state.includes('privacy/private') && this.section_id === 1
                            };

                            var listItem = self.makeListItem(item);
                            listItem.appendTo(list);
                        });
                        list.appendTo(self.browserPanelContent);
                    }else{
                        var nullContent = $('<div class="card-body">'+self.settings.i18n.noContents+' </div>');
                        var goBack = $('<a href="#"><small>'+self.settings.i18n.back+'</small></a>');
                        goBack.bind('click', function(e){
                            e.preventDefault();
                            if (self.browserPanelHeading.find('.browse-back').length > 0) {
                                self.browserPanelHeading.find('.browse-back').trigger('click');
                            } else {
                                self.browseParameters.subtree = 1;
                                self.browseParameters.offset = 0
                                self.buildTreeSelect();
                            }
                        }).appendTo(nullContent);
                        self.browserPanelContent.html('')
                        self.browserPanelContent.append(nullContent);
                    }

                    if(self.settings.pagination && data.content.offset > 0){
                        var prevPaginationOffset = self.browseParameters.offset - self.browseParameters.limit;
                        var prevButton = $('<a href="#" class="pull-left" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.goToPreviousPage+'"><span class="glyphicon glyphicon-chevron-left"></span></a>')
                          .bind('click', function(e){
                              self.browseParameters.offset = prevPaginationOffset;
                              self.doBrowse();
                              e.preventDefault();
                          })
                          .appendTo(self.browserPanelFooter);
                        if (self.settings.useTooltip) prevButton.tooltip();
                    }

                    if(data.content.total_count > data.content.list.length + self.browseParameters.offset){
                        var nextPaginationOffset = self.browseParameters.offset + self.browseParameters.limit;
                        var nextButton = $('<a href="#" class="pull-right" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.goToNextPage+'"><span class="glyphicon glyphicon-chevron-right"></span></a>')
                          .bind('click', function(e){
                              self.browseParameters.offset = nextPaginationOffset;
                              self.doBrowse();
                              e.preventDefault();
                          })
                          .appendTo(self.browserPanelFooter);
                        if (self.settings.useTooltip) nextButton.tooltip();
                    }

                }else{
                    alert(data.error_text);
                }
                self.hideSpinner();
            });
        },

        buildSearchSelect: function () {  
            var self = this;  

            self.buildPanelHeader(false, true);
            self.browserPanelContent.html('')
            self.browserPanelFooter.html('')
        },

        buildQuery: function(){
            var searchText = this.searchInput.val();
            searchText = searchText.replace(/'/g, "\\'");
            var subtreeQuery;
            if (this.browserContainer.find('#search-all-'+this.settings.attributeId).is(':checked')){
                subtreeQuery = " and subtree [1]";
            }else {
                subtreeQuery = " and subtree [" + this.browseParameters.subtree + "]";
            }
            var classesQuery = '';
            if ($.isArray(this.settings.classes) && this.settings.classes.length > 0){
                classesQuery = " and classes ["+this.settings.classes.join(',')+"]";
            }
            return "q = '"+searchText+"'"+subtreeQuery+classesQuery+" limit "+this.browseParameters.limit+" offset " +this.browseParameters.offset; 
        },

        doSearch: function(query, panelContent, panelFooter){
            var self = this; 

            var detectError = function(response,jqXHR){
                self.hideSpinner();
                if(response.error_message || response.error_code){
                    alert(response.error_message);
                    return true;
                }
                return false;
            };

            panelContent.html('');
            panelFooter.html('').hide();

            self.showSpinner();
            $.ajax({
                type: "GET",
                url: self.settings.baseUrl + 'opendata/api/content/search/',
                data: {q: encodeURIComponent(query)},
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data,textStatus,jqXHR) {
                    if (!detectError(data,jqXHR)){
                        if(data.totalCount > 0){
                            var list = $('<ul class="list-group" style="margin-bottom:0"></ul>');
                            $.each(data.searchHits, function(){                            
                                var name = typeof this.metadata.name[self.settings.language] != 'undefined' ? 
                                    this.metadata.name[self.settings.language] : 
                                    this.metadata.name[Object.keys(this.metadata.name)[0]];
                                var thumbnail = false;
                                var data = typeof this.data[self.settings.language] != 'undefined' ?
                                    this.data[self.settings.language] :
                                    this.data[Object.keys(this.data)[0]];

                                if (data.hasOwnProperty('image')) {
                                    if (data.image) {
                                        thumbnail = data.image.url;
                                    }
                                }
                                var item = {
                                    contentobject_id: this.metadata.id,
                                    node_id: this.metadata.mainNodeId,
                                    name: name,
                                    class_name: this.metadata.classIdentifier, //@todo
                                    class_identifier: this.metadata.classIdentifier,
                                    is_container: false,
                                    thumbnail_url: thumbnail
                                };

                                var listItem = self.makeListItem(item);
                                listItem.appendTo(list);                            
                            });
                            list.appendTo(panelContent);
                        }else{
                            panelContent.html($('<div class="card-body">Nessun contenuto</div>'));
                        }

                        if(self.browseParameters.offset > 0){
                            var prevPaginationOffset = self.browseParameters.offset - self.browseParameters.limit;
                            var prevButton = $('<a href="#" class="pull-left" title="'+self.settings.i18n.goToPreviousPage+'"><span class="glyphicon glyphicon-chevron-left"></span></a>')
                                .bind('click', function(e){                                    
                                    self.browseParameters.offset = prevPaginationOffset;
                                    var query = self.buildQuery();
                                    self.doSearch(query, panelContent, panelFooter);
                                    e.preventDefault();
                                })
                                .appendTo(panelFooter);
                            panelFooter.show();                            
                        }

                        if(data.nextPageQuery){                            
                            var nextButton = $('<a href="#" class="pull-right" title="'+self.settings.i18n.goToNextPage+'"><span class="glyphicon glyphicon-chevron-right"></span></a>')
                                .bind('click', function(e){                                    
                                    self.browseParameters.offset += self.browseParameters.limit;
                                    self.doSearch(data.nextPageQuery, panelContent, panelFooter);
                                    e.preventDefault();
                                })
                                .appendTo(panelFooter);
                            panelFooter.show();                          
                        }
                    }
                    self.hideSpinner();
                },
                error: function (jqXHR) {
                    var error = {
                        error_code: jqXHR.status,
                        error_message: jqXHR.statusText
                    };
                    detectError(error,jqXHR);
                }
            }); 
        },

        showStatusString: function(item) {
          return item.is_visible ? '' : this.settings.i18n.hidden;
        },

        makeListItem: function(item){        
            var self = this;

            var name;
            var lineHeightStyle = item.thumbnail_url ? 'height: 80px;' : '';
            if (item.is_container){
                name = $('<div style="'+lineHeightStyle+'"><a data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.clickToBrowseChildren+'" href="#" data-node_id="'+item.node_id+'" class="fw-semibold"> '+item.name+ '</a> <div class="badge rounded-pill bg-secondary ms-1">'+this.showStatusString(item)+'</div><br> <small>' +item.class_name + '</small></div>');
                name.children('a:first').bind('click', function(e){
                    self.browseParameters.subtree = $(this).data('node_id');
                    self.browseParameters.offset = 0;
                    self.buildTreeSelect();
                    e.preventDefault();
                });
            }else{
                name = $('<div style="'+lineHeightStyle+'"><span data-node_id="'+item.node_id+'" class="fw-semibold" style="max-width: 50%;"> '+item.name+ '</span> <div class="badge rounded-pill bg-secondary ms-1">'+this.showStatusString(item)+'</div><br> <small>' +item.class_name + '</small></div>');
            }

            var listItem = $('<li class="list-group-item"></li>');
            if (typeof $.fn.alpaca != 'undefined') {
                var detail = $('<a href="#" data-object_id="' + item.contentobject_id + '" class="btn btn-xs btn-info pull-right" title="'+self.settings.i18n.clickToPreview+'"<small class="fw-normal ms-1">'+self.settings.i18n.preview+'</small></a>');
                detail.bind('click', function (e) {
                    var objectId = $(this).data('object_id');
                    var previewOuter = $('<div class="card-wrapper card-space"></div>');
                    var previewWrapper = $('<div class="card card-bg no-after"></div>').appendTo(previewOuter);
                    var previewContainer = $('<div class="card-body"></div>').appendTo(previewWrapper);

                    var closePreviewButton = $('<a class="btn btn-xs btn-info pull-right" href="#">'+self.settings.i18n.closePreview+'</a>');
                    closePreviewButton.bind('click', function (e) {
                        self.browserContainer.show();
                        previewOuter.remove();
                        e.preventDefault();
                    }).prependTo(previewContainer);

                    self.browserContainer.hide();
                    previewOuter.insertBefore(self.browserContainer);

                    var d = new Date();
                    previewContainer.alpaca('destroy').alpaca({
                        'connector':{
                            'id': 'relationsbrowse',
                            'config': {
                                'connector': 'default',
                                'params': {
                                    'view': 'display',
                                    'object': objectId,
                                    'nocache': d.getTime()
                                }
                            }
                        }
                    });
                    e.preventDefault();
                });
                listItem.append(detail);
            }
            var input = '';
            if (self.isSelectable(item)){
                if (!self.isInSelection(item)){
                    input = $('<a href="#"  title="'+self.settings.i18n.addToSelection+'" class="btn btn-xs btn-success pull-right mr-2 me-2" data-selection="'+item.contentobject_id+'"><small>'+self.settings.i18n.addItem+'</small></a>');
                    input.data('item', item);
                    input.bind('click', function(e){
                        e.preventDefault();
                        var thisItem = $(this);
                        thisItem.html('<i class="fa fa-circle-o-notch fa-spin"></i>')
                        self.appendToSelection(thisItem.data('item'), function () {
                            thisItem.remove();
                        });
                    });
                }
            }
            listItem.append(input);
            if (item.thumbnail_url){
                listItem.append('<img src="'+item.thumbnail_url+'" style="object-fit: contain;width: 80px;height: 80px;margin-right: 10px;float:left" />');
            }
            listItem.append(name);


            return listItem;
        },  

        appendToSelection: function (item, cb, context){
            var self = this;
            if (!self.isInSelection(item)) {
                var priority = parseInt(self.browserContainer.parent().prev().find('input[name^="ContentObjectAttribute_priority"]:last-child').val()) || 0;
                priority++;
                $.ez('ezjsctemplate::relation_list_row::'+item.contentobject_id+'::'+self.settings.attributeId+'::'+priority+'::?ContentType=json', false, function(content){
                    if (content.error_text.length) {
                        alert(content.error_text);
                    }else{
                        var table = self.browserContainer.parents( ".ezcca-edit-datatype-ezobjectrelationlist" ).find('table').show().removeClass('hide');
                        table.find('tr.hide').before(content.content);
                        table.find('.ezobject-relation-remove-button').removeClass('hide');
                    }
                    if ($.isFunction(cb)) {
                        cb.call(context);
                    }
                });
                self.selection.push(item);
                $(self.element).trigger('relationbrowse.change', self, self.selection)
            }
        },

        isInSelection: function (item){
            for(var i in this.selection){
                if(this.selection[i].contentobject_id === item.contentobject_id){
                    return true;
                }
            } 

            return false;
        },

        isSelectable: function (item){            
            if ($.isArray(this.settings.classes) && this.settings.classes.length > 0){
                return $.inArray( item.class_identifier, this.settings.classes ) > -1;
            }

            return true;
        },

        setSelection: function(selection) {
            this.selection = selection;
            this.doInit(true)
        }
    });

    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" +
                    pluginName, new Plugin(this, options));
            }
        });
    };

})(jQuery, window, document);

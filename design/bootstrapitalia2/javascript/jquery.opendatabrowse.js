;(function ($, window, document, undefined) {

    "use strict";

    var pluginName = "opendataBrowse",
        defaults = {            
            subtree: 1,
            classes: false,
            selectionType: 'multiple',
            language: 'ita-IT',
            browsePaginationLimit: 10,
            browseSort: 'published',
            browseOrder: '0',
            allowAllBrowse: true,
            openInSearchMode: false,
            addCloseButton: false,
            addCreateButton: false,
            createSettings: {
                'connector': 'default',
                'options': {}
            },
            initOnCreate: true,
            useTooltip: false,
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
                store: "Salva",
                storeLoading: "Salvataggio in corso..."
            }
        };

    function Plugin(element, options) {
        this.element = element;
        this.settings = $.extend({}, defaults, options);
        if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            this.settings.baseUrl = UriPrefix + '/';
        }
        this._defaults = defaults;
        this._name = pluginName;
        this.iconStyle = 'line-height: 1.5;display:table-cell;padding-right:5px;';
        this.selection = [];
        this.subtreeRootList = [];
        this.browseParameters = {};
        this.rootNode = 'undefined';
        if (this.settings.classes === false || typeof $.fn.alpaca === 'undefined'){
            this.settings.addCreateButton = false;
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
            this.emptySelection();            
            this.resetBrowseParameters();
            this.buildTreeSelect();             
        };
    }

    // Avoid Plugin.prototype conflicts
    $.extend(Plugin.prototype, {
        
        doInit: function () {            
            if (!this.isInit){
                this.browserContainer = $('<div class="card-wrapper card-space"></div>').appendTo($(this.element));
                this.selectionContainer = $('<div class="card-wrapper card-space"></div>').appendTo($(this.element));
                this.buildTreeSelect();
                if (this.settings.openInSearchMode){
                    this.resetBrowseParameters();
                    this.buildSearchSelect();
                    this.searchInput.trigger('keyup');
                }

                if (typeof $.fn.alpaca !== 'undefined') {
                    var OpenContentOcopendataInBrowseConnector = Alpaca.Connector.extend({
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
                    Alpaca.registerConnectorClass("opendataforminbrowse", OpenContentOcopendataInBrowseConnector);
                }

                this.isInit = true;
            }
        },   

        resetBrowseParameters: function(){
            this.browseParameters = {
                subtree: this.settings.subtree || 1,
                limit: this.settings.browsePaginationLimit || 25,
                offset: 0,
                sort: this.settings.browseSort || 'priority',
                order: this.settings.browseOrder || 1
            };            
        },

        buildPanelHeader: function(panel,isTree,isSearch,isCreate){
            var self = this;
            var panelHeading = $('<div class="card-header clearfix" style="padding:15px"></div>').appendTo(panel);

            if (self.settings.addCloseButton) {
                var closeButton = $('<a class="btn btn-xs btn-link pull-right" href="#" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.clickToClose+'"><span class="glyphicon glyphicon-remove"></span></a>');
                if (self.settings.useTooltip) closeButton.tooltip();
                closeButton.bind('click', function (e) {
                    if (isCreate){
                        if (self.settings.openInSearchMode){
                            self.resetBrowseParameters();
                            self.buildSearchSelect();
                            self.searchInput.trigger('keyup');
                        }else{
                            self.resetBrowseParameters();
                            self.buildTreeSelect();
                        }
                    }
                    $(self.element).trigger('opendata.browse.close', self);
                    e.preventDefault();
                });
                panelHeading.append(closeButton);
            }

            if (isTree || isCreate) {
                var searchButton = $('<a class="btn btn-xs btn-primary pull-right mr-2 me-2" href="#" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.clickToOpenSearch+'"><span class="glyphicon glyphicon-search"></span> '+self.settings.i18n.search+'</a>');
                if (self.settings.useTooltip) searchButton.tooltip();
                searchButton.bind('click', function (e) {
                    self.resetBrowseParameters();
                    self.buildSearchSelect();
                    e.preventDefault();
                });
                panelHeading.append(searchButton);
            }

            if (isSearch || isCreate){
                var treeButton = $('<a class="btn btn-xs btn-primary pull-right mr-2 me-2" href="#" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.clickToBrowse+'"><span class="glyphicon glyphicon-th-list"></span> '+self.settings.i18n.browse+'</a>');
                if (self.settings.useTooltip){
                    treeButton.tooltip();
                }
                treeButton.bind('click', function(e){
                    self.resetBrowseParameters();
                    self.buildTreeSelect();
                    e.preventDefault();
                });
                panelHeading.append(treeButton);
            }

            if (self.settings.addCreateButton === true && !isCreate) {
                var detectError = function(response,jqXHR){
                    if(response.error_message || response.error_code){
                        console.log(response.error_message);
                        return true;
                    }
                    return false;
                };
                var createButtonGroup = $('<div class="dropdown pull-right mr-2 me-2"></div>');
                createButtonGroup.append($('<button type="button" class="btn btn-xs btn-link dropdown-toggle" data-bs-toggle="dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><span class="glyphicon glyphicon-plus"></span> '+self.settings.i18n.create+'</button>'));
                var list = $('<div class="dropdown-menu"></div>');
                $.each(self.settings.classes, function(){
                    var classIdentifier = this;
                    var listItem = $('<li></li>');
                    $.ajax({
                        type: "GET",
                        url: self.settings.baseUrl + 'opendata/api/classes/'+classIdentifier,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response,textStatus,jqXHR) {
                            if (!detectError(response,jqXHR)){
                                var className = self.getTranslation(response.name);
                                $('<a class="dropdown-item" href="#">'+className+'</a>')
                                    .bind('click', function (e) {                                        
                                        self.buildCreateForm(classIdentifier);
                                        e.preventDefault();
                                    })
                                    .appendTo(listItem);
                                listItem.appendTo(list);
                            }
                        },
                        error: function (jqXHR) {
                            var error = {
                                error_code: jqXHR.status,
                                error_message: jqXHR.statusText
                            };
                            detectError(error,jqXHR);
                            $('<a href="#">'+classIdentifier+'</a>')
                                .bind('click', function (e) {
                                    self.buildCreateForm(classIdentifier);
                                    e.preventDefault();
                                })
                                .appendTo(listItem);
                            listItem.appendTo(list);
                        }
                    });
                });
                createButtonGroup.append(list);
                panelHeading.append(createButtonGroup);
            }

            panelHeading.append('<a href="#" class="browse-spinner btn btn-xs btn-link pull-right" style="display: none;"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-fw"></i></a>');

            return panelHeading;
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
                    console.log(current.path_identification_string.search(this.rootNode.path_identification_string));
                    return current.path_identification_string.search(this.rootNode.path_identification_string) > -1;
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
                    $.getJSON(self.settings.baseUrl + 'ezjscore/call/ezjscbrowse::load::' + subtree, function (data) {
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

            $(this.browserContainer).html('');
            var panel = $('<div class="card card-bg no-after"></div>').appendTo($(this.browserContainer));
            var panelHeading = self.buildPanelHeader(panel, true, false, false);
            self.fetchBrowseSubtreeRoot(self.browseParameters.subtree, function (rootNode) {
                var name = $('<h5></h5>');
                if (typeof rootNode === 'string'){
                    $(name).html(rootNode);
                }else if (typeof rootNode === 'object'){
                    var itemName = (rootNode.name.length > 50) ? rootNode.name.substring(0, 47) + '...' : rootNode.name;
                    if (self.settings.subtree === self.browseParameters.subtree) {
                        self.rootNode = rootNode;
                    }
                    if (self.allowUpBrowse(rootNode)) {
                        var back = $('<a class="browse-back" href="#" data-node_id="' + rootNode.parent_node_id + '" title="'+self.settings.i18n.clickToBrowseParent+'">' + itemName + '</a>').prependTo(name);
                        back.bind('click', function (e) {
                            self.browseParameters.subtree = $(this).data('node_id');
                            self.buildTreeSelect();
                            e.preventDefault();
                        });
                    } else {
                        $(name).html(itemName);
                    }
                }
                panelHeading.append(name);
            });
            var panelContent = $('<div class="list-wrapper"></div>').appendTo(panel);
            var panelFooter = $('<div class="card-footer clearfix"></div>');

            self.showSpinner();
            $.getJSON(self.settings.baseUrl + 'ezjscore/call/ezjscbrowse::subtree::'+self.browseParameters.subtree+'::'+self.browseParameters.limit+'::'+self.browseParameters.offset+'::'+self.browseParameters.sort+'::'+self.browseParameters.order, function(data){
                if (data.error_text === ''){
                    if (data.content.list.length > 0){
                        var list = $('<ul class="list-group" style="margin-bottom:0"></ul>');
                        
                        $.each(data.content.list, function(){                            
                            
                            var item = {
                                contentobject_id: this.contentobject_id,
                                node_id: this.node_id,
                                name: this.name,
                                class_name: this.class_name,
                                class_identifier: this.class_identifier,
                                is_container: this.is_container,
                                thumbnail_url: this.thumbnail_url
                            };

                            var listItem = self.makeListItem(item);
                            listItem.appendTo(list);                            
                        });
                        list.appendTo(panelContent);

                    }else{
                        var nullContent = $('<div class="card-body">'+self.settings.i18n.noContents+' </div>');
                        var goBack = $('<a href="#"><small>'+self.settings.i18n.back+'</small></a>');
                        goBack.bind('click', function(e){
                            panelHeading.find('.browse-back').trigger('click');
                            e.preventDefault();
                        }).appendTo(nullContent);
                        panelContent.append(nullContent);
                    }

                    if(data.content.offset > 0){
                        var prevPaginationOffset = self.browseParameters.offset - self.browseParameters.limit;
                        var prevButton = $('<a href="#" class="pull-left" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.goToPreviousPage+'"><span class="glyphicon glyphicon-chevron-left"></span></a>')
                            .bind('click', function(e){
                                self.browseParameters.offset = prevPaginationOffset;
                                self.buildTreeSelect();
                                e.preventDefault();
                            })
                            .appendTo(panelFooter);
                        if (self.settings.useTooltip) prevButton.tooltip();    
                        panelFooter.appendTo(panel);
                    }

                    if(data.content.total_count > data.content.list.length + self.browseParameters.offset){
                        var nextPaginationOffset = self.browseParameters.offset + self.browseParameters.limit;
                        var nextButton = $('<a href="#" class="pull-right" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.goToNextPage+'"><span class="glyphicon glyphicon-chevron-right"></span></a>')
                            .bind('click', function(e){
                                self.browseParameters.offset = nextPaginationOffset;
                                self.buildTreeSelect();
                                e.preventDefault();
                            })
                            .appendTo(panelFooter);
                        if (self.settings.useTooltip) nextButton.tooltip();
                        panelFooter.appendTo(panel);
                    }

                }else{
                    alert(data.error_text);
                }
                self.hideSpinner();
            });             
        },
        
        buildSearchSelect: function () {  
            var self = this;  
            $(this.browserContainer).html('');
            var panel = $('<div class="card card-bg no-after"></div>').appendTo($(this.browserContainer));
            var panelHeading = self.buildPanelHeader(panel, false, true, false);
            panelHeading.append('<h5>'+self.settings.i18n.search+'</h5>');
            self.fetchBrowseSubtreeRoot(self.browseParameters.subtree, function (rootNode) {
                if (typeof rootNode === 'string'){
                    panelHeading.find('h5').append(' in ' + rootNode);
                }else if (typeof rootNode === 'object'){
                    var itemName = (rootNode.name.length > 50) ? rootNode.name.substring(0, 47) + '...' : rootNode.name;
                    panelHeading.find('h5').append(' in ' + itemName);
                }
            });

            var inputGroup = $('<div class="input-group"></div>');
            this.searchInput = $('<input class="form-control" type="text" placeholder="" value=""/>').appendTo(inputGroup);
            var inputGroupButtonContainer = $('<div class="input-group-append"></div>');
            var searchButton = $('<button type="button" class="btn btn-info">'+self.settings.i18n.search+'</button>').appendTo(inputGroupButtonContainer);
            inputGroupButtonContainer.appendTo(inputGroup);
            inputGroup.appendTo(panel);
            this.searchInput.focus();

            var panelContent = $('<div class="list-wrapper"></div>').appendTo(panel);
            var panelFooter = $('<div class="card-footer clearfix"></div>').hide().appendTo(panel);

            searchButton.bind('click', function(e){
                e.preventDefault();
                self.resetBrowseParameters();
                var query = self.buildQuery();
                self.doSearch(query, panelContent, panelFooter);
                
            });

            this.searchInput.on('keyup', function (e) {
                if (e.keyCode === 13) {
                    searchButton.trigger('click');
                    e.preventDefault();
                }
            });
        },

        buildCreateForm: function(classIdentifier){
            var self = this;
            $(this.browserContainer).html('');
            var panel = $('<div class="card card-bg no-after"></div>').appendTo($(this.browserContainer));
            var panelHeading = self.buildPanelHeader(panel, false, false, true);
            panelHeading.append('<h5">'+self.settings.i18n.createNew+'</h5>');

            var params = {
                class: classIdentifier
            };
            if (self.settings.subtree !== 1){
                params.parent = self.settings.subtree;
            }

            var d = new Date();
            params.nocache= d.getTime();

            var options = $.extend(true, {
                'connector':{
                    'id': 'opendataforminbrowse',
                    'config': {
                        'connector': self.settings.createSettings.connector,
                        'params': params
                    }
                },
                'options': {
                    'form': {
                        'buttons': {
                            'sub-submit': { //avoid recursion in disableSubmitButton
                                'click': function () {
                                    this.refreshValidationState(true);
                                    if (this.isValid(true)) {
                                        hideButtons();
                                        var promise = this.ajaxSubmit();
                                        promise.done(function (response) {
                                            if (response.error) {
                                                alert(response.error);
                                                showButtons();
                                            } else {

                                                var name = self.getTranslation(response.content.metadata.name);

                                                var item = {
                                                    contentobject_id: response.content.metadata.id,
                                                    node_id: response.content.metadata.mainNodeId,
                                                    name: name,
                                                    class_name: response.content.metadata.classIdentifier, //@todo
                                                    class_identifier: response.content.metadata.classIdentifier
                                                };
                                                self.appendToSelection(item);

                                                if (self.settings.openInSearchMode){
                                                    self.resetBrowseParameters();
                                                    self.buildSearchSelect();
                                                    self.searchInput.trigger('keyup');
                                                }else{
                                                    self.resetBrowseParameters();
                                                    self.buildTreeSelect();
                                                }
                                            }
                                        });
                                        promise.fail(function (error) {
                                            alert(error);
                                            showButtons();
                                        });
                                    }
                                },
                                'id': 'sub-form-submit',
                                'value': 'Salva',
                                'styles': 'btn btn-success pull-right'
                            }
                        }
                    }
                }
            }, self.settings.createSettings.options);

            var hideButtons = function () {
                $.each(options.options.form.buttons, function(){
                    var button = $('#'+this.id);
                    button.data('original-text', button.text());
                    button.text('Salvataggio in corso....');
                    button.attr('disabled', 'disabled');
                });
            };
            var showButtons = function () {
                $.each(options.options.form.buttons, function(){
                    var button = $('#'+this.id);
                    button.text(button.data('original-text'));
                    button.attr('disabled', false);
                });
            };

            $('<div class="card-body clearfix" style="padding: 20px"></div>')
                .alpaca('destroy').alpaca(options)
                .appendTo(panel);

            $('<div class="card-footer clearfix"></div>').hide().appendTo(panel);
        },

        buildQuery: function(){
            var searchText = this.searchInput.val();
            searchText = searchText.replace(/'/g, "\\'");
            var subtreeQuery = " and subtree ["+this.browseParameters.subtree+"]";
            var classesQuery = '';
            if ($.isArray(this.settings.classes) && this.settings.classes.length > 0){
                classesQuery = " and classes ["+this.settings.classes.join(',')+"]";
            }
            return "q = '"+searchText+"'"+subtreeQuery+classesQuery+" limit "+this.browseParameters.limit+" offset " +this.browseParameters.offset; 
        },

        getTranslation: function (item) {
            var self = this;
            return typeof item[self.settings.language] != 'undefined' ?
              item[self.settings.language] :
              item[Object.keys(item)[0]];
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
                                var thumbnail = false;
                                var data = self.getTranslation(this.data);
                                if (data.hasOwnProperty('image')) {
                                    if (data.image.hasOwnProperty('url')) {
                                        thumbnail = data.image.url;
                                    } else if (data.image.length > 0) {
                                        let imageId = data.image[0].id || null;
                                        if (imageId) {
                                            thumbnail = '/image/view/' + imageId + '/small';
                                        }
                                    }
                                }
                                var item = {
                                    contentobject_id: this.metadata.id,
                                    node_id: this.metadata.mainNodeId,
                                    name: self.getTranslation(this.metadata.name),
                                    class_name: self.getTranslation(this.metadata.classDefinition.name),
                                    class_identifier: this.metadata.classIdentifier,
                                    is_container: false,
                                    thumbnail_url: thumbnail
                                };
                                var listItem = self.makeListItem(item);
                                listItem.appendTo(list);                            
                            });
                            list.appendTo(panelContent);
                        }else{
                            panelContent.html($('<div class="card-body">'+self.settings.i18n.noContents+' </div>'));
                        }

                        if(self.browseParameters.offset > 0){
                            var prevPaginationOffset = self.browseParameters.offset - self.browseParameters.limit;
                            var prevButton = $('<a href="#" class="pull-left" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.goToPreviousPage+'"><span class="glyphicon glyphicon-chevron-left"></span></a>')
                                .bind('click', function(e){                                    
                                    self.browseParameters.offset = prevPaginationOffset;
                                    var query = self.buildQuery();
                                    self.doSearch(query, panelContent, panelFooter);
                                    e.preventDefault();
                                })
                                .appendTo(panelFooter);
                            if (self.settings.useTooltip) prevButton.tooltip();                                    
                            panelFooter.show();                            
                        }

                        if(data.nextPageQuery){                            
                            var nextButton = $('<a href="#" class="pull-right" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.goToNextPage+'"><span class="glyphicon glyphicon-chevron-right"></span></a>')
                                .bind('click', function(e){                                    
                                    self.browseParameters.offset += self.browseParameters.limit;
                                    self.doSearch(data.nextPageQuery, panelContent, panelFooter);
                                    e.preventDefault();
                                })
                                .appendTo(panelFooter);  
                            if (self.settings.useTooltip) nextButton.tooltip();    
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

        makeListItem: function(item){        
            var self = this;
            var name;
            var lineHeightStyle = item.thumbnail_url ? 'height: 80px;' : '';
            if (item.is_container){
                name = $('<a data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.clickToBrowseChildren+'" href="#" data-node_id="'+item.node_id+'" style="float:left;'+lineHeightStyle+'"> '+item.name+ ' <small>' +item.class_name + '</small></a>');
                if (self.settings.useTooltip) name.tooltip();
                name.bind('click', function(e){
                    self.browseParameters.subtree = $(this).data('node_id');
                    self.browseParameters.offset = 0;
                    self.buildTreeSelect();
                    e.preventDefault();
                });
            }else{
                name = $('<span data-node_id="'+item.node_id+'" style="float:left;max-width: 50%;'+lineHeightStyle+'"> '+item.name+ ' <small>' +item.class_name + '</small></span>');
            }
            var listItem = $('<li class="list-group-item"></li>');
            if (typeof $.fn.alpaca != 'undefined') {
                var detail = $('<a href="#" data-object_id="' + item.contentobject_id + '" style="display:table-cell;" class="btn btn-xs btn-info pull-right" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.clickToPreview+'"><small>'+self.settings.i18n.preview+'</small></a>');
                if (self.settings.useTooltip) detail.tooltip();
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
                            'id': 'opendataforminbrowse',
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
                        self.appendToSelection(thisItem.data('item'), function () {
                            thisItem.hide();
                        });
                    });
                }
            }
            if (self.settings.useTooltip) input.tooltip();
            listItem.append(input);
            if (item.thumbnail_url){
                listItem.append('<img src="'+item.thumbnail_url+'" style="object-fit: contain;width: 80px;height: 80px;margin-right: 10px;float:left" />');
            }
            listItem.append(name);


            return listItem;
        },  

        emptySelection: function () {
            if (this.settings.selectionType !== 'multiple') {
                var self = this;
                $.each(this.selection, function () {
                    self.removeFromSelection(this);
                });
            }
            this.selection = [];
            this.refreshSelection();
        },      

        appendToSelection: function (item, cb, context){
            if (!this.isInSelection(item)) {
                if (this.settings.selectionType !== 'multiple') {
                    this.emptySelection();
                }
                this.selection.push(item);
                if ($.isFunction(cb)) {
                    cb.call(context);
                }
                this.refreshSelection();
            }
        },

        refreshSelection: function(){
            var self = this;
            this.selectionContainer.html('');
            if (this.selection.length > 0){
                var panel = $('<div class="card card-bg no-after border-primary mt-2 mb-2"></div>').appendTo($(this.selectionContainer));
                $('<div class="card-header text-white bg-primary" style="padding: 15px"><h5>'+self.settings.i18n.selectedItems+'</h5></div>').appendTo(panel);
                var panelContent = $('<div class="list-wrapper"></div>').appendTo(panel);
                var list = $('<ul class="list-group" style="margin-bottom:0"></ul>');
                
                $.each(this.selection, function(){
                    var name = '<span style="display: table-cell;">' + this.name + ' <small>' +this.class_name + '</small></span>';
                    var listItem = $('<li class="list-group-item"></li>');                        
                    var input = $('<span class="glyphicon glyphicon-remove pull-left" data-bs-toggle="tooltip" data-toggle="tooltip" title="'+self.settings.i18n.removeFromSelection+'" style="cursor:pointer;'+self.iconStyle+'"></span>');
                    input.data('item', this);
                    input.bind('click', function(e){
                        self.removeFromSelection($(this).data('item'));
                        $(self.browserContainer).find('[data-selection="'+$(this).data('item').contentobject_id+'"]').show();
                        $(this).closest('li').remove();
                        self.refreshSelection();
                    });
                    if (self.settings.useTooltip) input.tooltip();
                    listItem.append(input);
                    listItem.append(name);                
                    listItem.appendTo(list);
                    
                });
                list.appendTo(panelContent);  
                var panelFooter = $('<div class="card-footer bg-transparent clearfix"></div>').appendTo(panel);

                $('<button class="btn btn-success pull-right">Procedi</button>')
                    .bind('click', function(e){
                        e.preventDefault();                    
                        $(self.element).trigger('opendata.browse.select', self);
                    })
                    .appendTo(panelFooter);
            }                
        },

        removeFromSelection: function (item){
            for(var i in this.selection){
                if(this.selection[i].contentobject_id === item.contentobject_id){
                    this.selection.splice(i,1);
                    $(this.browserContainer).find('[data-selection="' + item.contentobject_id + '"]').show();
                    break;
                }
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

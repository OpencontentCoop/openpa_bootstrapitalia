// bug in DateTime field?
Alpaca.defaultDateFormat = "DD/MM/YYYY";
Alpaca.defaultTimeFormat = "HH:mm";

//// bug in Tag field?
//Array.prototype.toLowerCase = function () {
//    var i = this.length;
//    while (--i >= 0) {
//        if (typeof this[i] === "string") {
//            this[i] = this[i].toLowerCase();
//        }
//    }
//    return this;
//};

var OpenContentOcopendataConnector = Alpaca.Connector.extend({
    loadAll: function (resources, onSuccess, onError){
        var self = this;   
        
        var resourceUri = self._buildResourceUri();
        
        var onConnectSuccess = function() {
            
            var loaded = {};

            var doMerge = function(p, v1, v2){
                loaded[p] = v1;

                if (v2){
                    if ((typeof(loaded[p]) === "object") && (typeof(v2) === "object")){
                        Alpaca.mergeObject(loaded[p], v2);
                    }else{
                        loaded[p] = v2;
                    }
                }
            };

            self._handleLoadJsonResource(
                resourceUri, 
                function(response){
                    doMerge("data", resources.data, response.data);
                    doMerge("options", resources.options, response.options);
                    doMerge("schema", resources.schema, response.schema);
                    doMerge("view", resources.view, response.view);                    
                    onSuccess(loaded.data, loaded.options, loaded.schema, loaded.view);
                }, 
                function (loadError){
                    if (onError && Alpaca.isFunction(onError)){
                        onError(loadError);
                    }
                }
            );
        };        

        var onConnectError  = function(err) {
            if (onError && Alpaca.isFunction(onError)) {
                onError(err);
            }
        };

        self.connect(onConnectSuccess, onConnectError); 
    },    
    _buildResourceUri: function(){
        var self = this; 

        var prefix = '/';
        if ($.isFunction($.ez)){
            prefix = $.ez.root_url;
        }else if(self.config.prefix){
            prefix = self.config.prefix;
        }

        return prefix+"forms/connector/" + self.config.connector + "/?" + $.param(self.config.params);
    }
});
Alpaca.registerConnectorClass("opendataform", OpenContentOcopendataConnector);

;(function(defaults, $, window, document, undefined) {
    'use strict';
    $.extend({
        opendataFormSetup: function(options) {
            return $.extend(defaults, options);
        }
    }).fn.extend({

        opendataForm: function(params, options) {

            options = $.extend({}, defaults, options);

            var tokenNode = document.getElementById('ezxform_token_js');
            if ( tokenNode ){
                Alpaca.CSRF_TOKEN = tokenNode.getAttribute('title');
            }

            if (options.nocache) {
                var d = new Date();
                params.nocache = d.getTime();
            }

            return $(this).each(function() {
                var hideButtons = function() {
                    $.each(alpacaOptions.options.form.buttons, function() {
                        var button = $('#' + this.id);
                        button.data('original-text', button.text());
                        button.text(options.i18n.storeLoading);
                        button.attr('disabled', 'disabled');
                    });
                };
                var showButtons = function() {
                    $.each(alpacaOptions.options.form.buttons, function() {
                        var button = $('#' + this.id);
                        button.text(button.data('original-text'));
                        button.attr('disabled', false);
                    });
                };

                var alpacaOptions = $.extend(true, {
                    "connector":{
                        "id": "opendataform",
                        "config": {
                            "connector": options.connector,
                            "params": params
                        }
                    },
                    "options": {
                        "form": {
                            "buttons": {
                                "submit": {
                                    "click": function() {
                                        var self = this;
                                        this.refreshValidationState(true);
                                        if (this.isValid(true)) {
                                            hideButtons();
                                            var promise = this.ajaxSubmit();
                                            promise.done(function(data) {
                                                if (data.error) {
                                                    if ($.isFunction(options.onError)) {
                                                        options.onError(data, self, this);
                                                    }
                                                    showButtons();
                                                } else {
                                                    if ($.isFunction(options.onSuccess)) {
                                                        options.onSuccess(data, self, this);
                                                        showButtons();
                                                    }
                                                }
                                            });
                                            promise.fail(function(error) {
                                                if ($.isFunction(options.onError)) {
                                                    options.onError(error, self, this);
                                                }
                                                showButtons();
                                            });
                                        }
                                    },
                                    'id': "save-"+options.connector+"button",
                                    "value": options.i18n.store,
                                    "styles": "btn btn-lg btn-success pull-right"
                                }
                            }
                        }
                    }
                }, options.alpaca);

                if (params.view && params.view === 'display') {
                    $.each(alpacaOptions.options.form.buttons, function() {
                        alpacaOptions.options.form.buttons.styles += ' hide';
                    })
                }

                if ($.isFunction(options.onBeforeCreate)) {
                    options.onBeforeCreate();
                }
                $(this).find('input, select').on('keydown', function (e) {
                    if (e.keyCode === 13)
                        e.preventDefault();
                });
                $(this).alpaca('destroy').html('').addClass('clearfix').alpaca(alpacaOptions);

            });
        },

        opendataFormEdit: function(params, options) {
            
            if (jQuery.type(params.class) === 'undefined' && jQuery.type(params.object) === 'undefined') {
                throw new Error('Missing class/object parameter');
            }

            return $(this).opendataForm(params, options);
        },

        opendataFormCreate: function(params, options) {

            if (jQuery.type(params.class) === 'undefined') {
                throw new Error('Missing class parameter');
            }

            return $(this).opendataForm(params, options);
        },

        opendataFormManageLocation: function(params, options) {

            if (jQuery.type(params.source) === 'undefined' && jQuery.type(params.destination) === 'undefined') {
                throw new Error('Missing source/destination parameter');
            }
            options = $.extend({}, defaults, options);
            options.connector = 'manage-location';

            return $(this).opendataForm(params, options);
        },

        opendataFormView: function(params, options) {

            options = $.extend({}, defaults, options);

            if (jQuery.type(params) === 'string' || jQuery.type(params) === 'number') {
                params = {
                    object: params
                };
            }

            if (jQuery.type(params.object) === 'undefined') {
                throw new Error('Missing object parameter');
            }

            if (options.nocache) {
                var d = new Date();
                params.nocache = d.getTime();
            }

            params.view = 'display';

            return $(this).each(function() {

                var alpacaOptions = $.extend(true, {                    
                    "connector":{
                        "id": "opendataform",
                        "config": {
                            "connector": options.connector,
                            "params": params
                        }
                    },
                    "options": {
                        "form": {
                            "buttons": {
                                "submit": {
                                    "click": function() {},
                                    "id": '',
                                    "value": "",
                                    "styles": "hide"
                                }
                            }
                        }
                    }
                }, options.alpaca);

                if ($.isFunction(options.onBeforeCreate)) {
                    options.onBeforeCreate();
                }
                $(this).alpaca('destroy').alpaca(alpacaOptions);
            });
        },

        opendataFormDelete: function(params, options) {

            options = $.extend({}, defaults, options);

            if (jQuery.type(params) === 'string' || jQuery.type(params) === 'number') {
                params = {
                    object: params
                };
            }

            if (jQuery.type(params.object) === 'undefined') {
                throw new Error('Missing object parameter');
            }

            var tokenNode = document.getElementById('ezxform_token_js');
            if ( tokenNode ){
                Alpaca.CSRF_TOKEN = tokenNode.getAttribute('title');
            }

            if (options.nocache) {
                var d = new Date();
                params.nocache = d.getTime();
            }

            params.view = 'display';

            return $(this).each(function() {

                var hideButtons = function() {
                    $.each(alpacaOptions.options.form.buttons, function() {
                        var button = $('#' + this.id);
                        button.data('original-text', button.text());
                        button.text(options.i18n.storeLoading);
                        button.attr('disabled', 'disabled');
                    });
                };
                var showButtons = function() {
                    $.each(alpacaOptions.options.form.buttons, function() {
                        var button = $('#' + this.id);
                        button.text(button.data('original-text'));
                        button.attr('disabled', false);
                    });
                };

                var alpacaOptions = $.extend(true, {
                    "connector":{
                        "id": "opendataform",
                        "config": {
                            "connector": 'delete-object',
                            "params": params
                        }
                    },
                    "options": {
                        "form": {
                            "buttons": {
                                "reset": {
                                    "click": function () {
                                        if ($.isFunction(options.onSuccess)) {
                                            options.onSuccess();
                                        }
                                        self.css('background', 'transparent');
                                    },
                                    "value": options.i18n.cancelDelete,
                                    "styles": "btn btn-lg btn-danger pull-left"
                                },
                                "submit": {
                                    "click": function () {
                                        var self = this;
                                        this.refreshValidationState(true);
                                        if (this.isValid(true)) {
                                            hideButtons();
                                            var promise = this.ajaxSubmit();
                                            promise.done(function (data) {
                                                if ($.isFunction(options.onSuccess)) {
                                                    options.onSuccess(data, self, this);
                                                }                                                    
                                            });
                                            promise.fail(function (error) {
                                                if ($.isFunction(options.onError)) {
                                                    options.onError(error, self, this);
                                                }
                                                showButtons();
                                            });
                                        }
                                    },
                                    'id': "confirm-remove-"+params.object+"button",
                                    "value": options.i18n.confirmDelete,
                                    "styles": "btn btn-lg btn-success pull-right"
                                }
                            }
                        }
                    }
                }, options.alpaca);

                if ($.isFunction(options.onBeforeCreate)) {
                    options.onBeforeCreate();
                }
                $(this).find('input, select').on('keydown', function (e) {
                    if (e.keyCode === 13)
                        e.preventDefault();
                });
                $(this).alpaca('destroy').alpaca(alpacaOptions);
            });
        },
    });
})({
    nocache: true,
    onSuccess: null,
    onError: function(data) {
        alert(data.error);
    },
    onBeforeCreate: null,
    alpaca: null,
    connector: 'default',
    i18n: {
        'store': 'Salva',
        'storeLoading': 'Salvataggio in corso...',
        'cancelDelete': 'Annulla eliminazione',
        'confirmDelete': 'Conferma eliminazione'

    }
}, jQuery, window, document);

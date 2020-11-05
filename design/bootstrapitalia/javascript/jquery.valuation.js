$(document).ready(function () {

    Alpaca.registerConnectorClass('valuation', Alpaca.Connector.extend({
        loadAll: function (resources, onSuccess, onError){
            var self = this;
            var resourceUri = self._buildResourceUri();
            var onConnectSuccess = function() {
                var loaded = {};
                var doMerge = function(p, v1, v2){
                    loaded[p] = v1;
                    if (v2){
                        if ((typeof(loaded[p]) === 'object') && (typeof(v2) === 'object')){
                            Alpaca.mergeObject(loaded[p], v2);
                        }else{
                            loaded[p] = v2;
                        }
                    }
                };
                self._handleLoadJsonResource(
                    resourceUri,
                    function(response){
                        doMerge('data', resources.data, response.data);
                        doMerge('options', resources.options, response.options);
                        doMerge('schema', resources.schema, response.schema);
                        doMerge('view', resources.view, response.view);
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
            return prefix+'valuation/' + self.config.connector + '/?' + $.param(self.config.params);
        }
    }));

    let container = $('.it-footer-valuation');
    let feedbackInput = container.find('.feedback-input');
    let feedbackThanks = container.find('.feedback-thanks');
    let feedbackSurvey = container.find('.feedback-survey');
    container.find('[data-feedback="yes"]').on('click', function (e) {
        feedbackInput.addClass('hide');
        feedbackThanks.removeClass('hide');
        let sitekey = $(this).data('sitekey');
        grecaptcha.ready(function() {
            grecaptcha.execute(sitekey, {action: 'submit'}).then(function(token) {
                var prefix = '/';
                if ($.isFunction($.ez)){
                    prefix = $.ez.root_url;
                }
                $.get(prefix+'valuation/send/', {
                    'page': ModuleResultUri+location.search,
                    'token': token
                }, function (data) {
                });
            });
        });

        e.preventDefault();
    });
    container.find('[data-feedback="no"]').on('click', function (e) {
        feedbackInput.addClass('hide');
        let i18n = feedbackSurvey.data();
        let sitekey = $(this).data('sitekey');
        feedbackSurvey.removeClass('hide');
        grecaptcha.ready(function() {
            grecaptcha.execute(sitekey, {action: 'submit'}).then(function(token) {
                feedbackSurvey.find('form').opendataForm({
                    'page': ModuleResultUri+location.search,
                    'token': token
                }, {
                    'connector': 'form',
                    'alpaca': {
                        'connector':{
                            'id': 'valuation'
                        },
                        'options': {
                            'form': {
                                'buttons': null
                            }
                        },
                        'view': {
                            'styles':{
                                'button': 'btn btn-outline-dark btn-sm text-uppercase bg-white rounded-0'
                            },
                            'wizard': {
                                'buttons': {
                                    'previous': {
                                        'align': 'left',
                                        'title': i18n.previous,
                                        'click': function() {
                                            this.form.ajaxSubmit();
                                        }
                                    },
                                    'next': {
                                        'align': 'right',
                                        'title': i18n.next,
                                        'click': function() {
                                            this.form.ajaxSubmit();
                                        }
                                    },
                                    'submit': {
                                        'align': 'right',
                                        'title': i18n.submit,
                                        'click': function() {
                                            feedbackSurvey.addClass('hide');
                                            feedbackThanks.removeClass('hide');
                                            this.form.ajaxSubmit();
                                        }
                                    }
                                }
                            }
                        }

                    }
                });
            });
        });
        e.preventDefault();
    });
    container.find('[data-close]').on('click', function (e) {
        feedbackInput.removeClass('hide');
        feedbackSurvey.addClass('hide');
        e.preventDefault();
    });
    container.find('form').on('submit', function (e) {
        feedbackInput.addClass('hide');
        feedbackSurvey.addClass('hide');
        feedbackThanks.removeClass('hide');
        e.preventDefault();
    });
});
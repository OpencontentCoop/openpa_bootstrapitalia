(function ($, window, document, undefined) {
    'use strict';
    var pluginName = 'simplifiedPlaceGui',
        defaults = {
            'placeClassIdentifier': 'place',
            'placeGeoIdentifier': 'has_address',
            'i18n': {
                search: 'search',
                noResults: 'noResults',
                myLocation: 'myLocation',
                store: 'store',
                cancel: 'cancel',
                storeLoading: 'storeLoading',
                cancelDelete: 'cancelDelete',
                confirmDelete: 'confirmDelete'
            }
        };

    function Plugin(element, options) {

        this.settings = $.extend({}, defaults, options);
        this.container = $(element);

        this.mapId = 'map-' + this.container.data('simplified_place_gui');
        this.myLocationButton = $('<a href="#" title="' + this.settings.i18n.myLocation + '"><i class="fa fa-map-marker"></i></a>');
        this.geocoder = L.Control.Geocoder.nominatim();
        this.marker = new L.Marker(new L.LatLng(0, 0), {
            icon: new L.MakiMarkers.icon({icon: "circle-stroked", color: "#f00", size: "l"}),
            draggable: true
        }).bindPopup('');
        this.storeButton = this.container.find('[data-store_place_gui]');
        this.selectorWrapper = this.container.find('select[data-place_selection_wrapper]');
        this.helperTexts = this.container.find('[data-helper-texts]');
        this.editWindow = this.container.find('[data-window]');

        this.markers = L.featureGroup();
        this.init();
    }

    $.extend(Plugin.prototype, {
        init: function () {
            var plugin = this;

            plugin.container.find('input').val('');
            plugin.map = new L.Map(this.mapId, {loadingControl: true, closePopupOnClick: false}).setView(new L.LatLng(0, 0), 1);
            L.Control.geocoder({
                collapsed: false,
                placeholder: plugin.settings.i18n.search,
                errorMessage: plugin.settings.i18n.noResults,
                suggestMinLength: 5,
                defaultMarkGeocode: false
            }).on('markgeocode', function (e) {
                plugin.setMarker(e.geocode.center, e.geocode);
                L.DomEvent.stop(e);
            }).addTo(plugin.map);
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(plugin.map);

            plugin.markers.addTo(plugin.map);
            plugin.displaySelectedMarkers();
            plugin.selectorWrapper.chosen({width: '100%'}).on('change', function (e) {
                plugin.displaySelectedMarkers();
            });

            var myLocationWrapper = $('<div class="leaflet-bar leaflet-control"></div>').append(plugin.myLocationButton);
            plugin.container.find('.leaflet-bottom.leaflet-left').append(myLocationWrapper);

            plugin.container.find('.leaflet-control-geocoder-form input').css('height', 'auto');

            plugin.marker.on('dragend', function (event) {
                var target = event.target.getLatLng();
                plugin.map.loadingControl.addLoader('lc');
                plugin.geocoder.reverse(target, 60000000, function (data) {
                    plugin.map.loadingControl.removeLoader('lc');
                    if (data.length) {
                        plugin.setMarker(target, data[0]);
                    } else {
                        plugin.setMarker(target);
                    }
                });
            }).on('click', function (event) {
                plugin.setMarker(event.target.getLatLng());
            });

            plugin.myLocationButton.on('click', function (e) {
                plugin.map.loadingControl.addLoader('lc');
                plugin.map.locate({setView: true, watch: false})
                    .on('locationfound', function (e) {
                        plugin.map.loadingControl.removeLoader('lc');
                        var target = new L.LatLng(e.latitude, e.longitude);
                        plugin.geocoder.reverse(target, 60000000, function (data) {
                            if (data.length) {
                                plugin.setMarker(target, data[0]);
                            } else {
                                plugin.setMarker(target);
                            }
                        });
                        plugin.map.off('locationfound');
                    })
                    .on('locationerror', function (e) {
                        plugin.map.loadingControl.removeLoader('lc');
                        alert(e.message);
                        plugin.map.off('locationerror');
                    });
                e.preventDefault();
            });
        },

        displaySelectedMarkers: function () {
            var plugin = this;
            plugin.map.removeLayer(plugin.marker);
            plugin.markers.clearLayers();
            plugin.selectorWrapper.find('option:selected').each(function () {
                if ($(this).data('lat') && $(this).data('lng')) {
                    plugin.markers.addLayer(
                        new L.Marker(
                            new L.LatLng($(this).data('lat'), $(this).data('lng')),
                            {icon: new L.MakiMarkers.icon({icon: "star", color: "f00", size: "l"})}
                        ).on('click', function (e) {
                            //plugin.setMarker(e.latlng);
                        })
                    );
                }
            });
            if (plugin.markers.getLayers().length > 0) {
                plugin.map.fitBounds(plugin.markers.getBounds());
            }
        },

        selectPlace: function (data, latLng) {
            var plugin = this;
            plugin.selectorWrapper.find('[data-new_place_select]').append('<option data-lng="'+latLng.lng+'" data-lat="'+latLng.lat+'" value="' + data.metadata.id + '" selected="selected">' + data.metadata.name['ita-IT'] + '</option>');
            plugin.selectorWrapper.trigger("chosen:updated").trigger('change');
        },

        setMarker: function (latLng, data) {
            var plugin = this;

            plugin.markers.clearLayers();
            plugin.selectorWrapper.val('').trigger("chosen:updated");

            var helperText = '<p>' + plugin.helperTexts.find('[data-candrag]').html() + '</p>';
            var confirmButton = '<p class="text-center"><a data-lat="' + latLng.lat + '" data-lng="' + latLng.lng + '" id="add-place-' + plugin.mapId + '" href="#" class="btn btn-info btn-xs text-white text-center">' + plugin.helperTexts.find('[data-confirm]').html() + '</a></p>';
            plugin.map.setView(latLng, 18);
            plugin.marker
                .setLatLng(latLng)
                .addTo(plugin.map)
                .setPopupContent(helperText + confirmButton)
                .openPopup();

            $('#add-place-' + plugin.mapId).on('click', function (e) {
                var self = $(this);
                self.html('<i class="fa fa-circle-o-notch fa-spin"></i>');
                var latLng = new L.LatLng(self.data('lat'), self.data('lng'));
                plugin.findNearPlaces(latLng, function (places, latLng) {
                    plugin.map.removeLayer(plugin.marker);
                    if (places.length === 0) {
                        plugin.openCreateWindow(latLng, data);
                    } else {
                        plugin.openSelectWidow(latLng, data, places);
                    }
                    $('#add-place-' + plugin.mapId).off('click');
                });
                e.preventDefault();
            });

            return false;
        },

        openCreateWindow: function (latLng, data) {
            var plugin = this;
            plugin.editWindow.html('');

            var container = $('<form class="p-2"></form>').appendTo(plugin.editWindow);
            container.opendataFormCreate({
                    class: plugin.settings.class,
                    parent: plugin.settings.parent,
                    lat: latLng.lat,
                    lon: latLng.lng,
                },
                {
                    connector: 'add_place',
                    onBeforeCreate: function () {
                        container.parent().show();
                    },
                    onSuccess: function (data) {
                        plugin.selectPlace(data.content, latLng);
                        plugin.editWindow.hide();
                    },
                    i18n: plugin.settings.i18n,
                    alpaca: {
                        'options': {
                            'form': {
                                'buttons': {
                                    'submit': {
                                        'styles': 'btn btn-sm btn-success pull-right'
                                    },
                                    'reset': {
                                        'click': function () {
                                            container.parent().hide();
                                            container.remove();
                                        },
                                        'id': 'reset-button',
                                        'value': plugin.settings.i18n.cancel,
                                        'styles': 'btn btn-sm btn-dark pull-left'
                                    }
                                }
                            }
                        }
                    }
                }
            );
        },

        openSelectWidow: function (latLng, data, places) {
            console.log(latLng, data, places);
        },

        findNearPlaces: function (latLng, cb, context) {
            var places = [];
            if ($.isFunction(cb)) {
                cb.call(context, places, latLng);
            }
        }
    });
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, 'plugin_' + pluginName)) {
                $.data(this, 'plugin_' + pluginName, new Plugin(this, options));
            }
            $(this).removeClass('hide').data('plugin_' + pluginName);
        });
    };
})(jQuery, window, document);

$(document).ready(function () {
    // Corregge l'altezza del masonry quando si espande o si nasconde un elemento al suo interno
    $('.card-text .collapse').on('shown.bs.collapse hidden.bs.collapse', function (){
        function fixMasonryHeight(masonry) {
          const height = masonry.style.height;
          masonry.style.minHeight = height;
        }

        let wrapper = $(this).parents('[data-bs-toggle="masonry"]');
        if (wrapper.length > 0) {
            bootstrap.Masonry.getOrCreateInstance(wrapper[0]).dispose()
            let m = bootstrap.Masonry.getOrCreateInstance(wrapper[0])
            const masonry = wrapper[0];
            fixMasonryHeight(masonry);
            m._masonry.on('layoutComplete', function() {
              fixMasonryHeight(masonry);
            });
        }
    });
    $('[data-shared_link]').each(function () {
        let element = $(this);
        let link = new URL(element.attr('href'));
        let view = element.data('shared_link_view');
        let container = $('[data-object_id="'+element.data('shared_link')+'"].shared_link-'+view);
        let wrapper = container.parents('[data-bs-toggle="masonry"]');
        function loadRemoteView(objectId){
            let remoteApi = link.protocol + '//' + link.hostname + '/api/opendata/v2/content/read/' + objectId + '?view=' + view;
            $.ajax({
                type: "GET",
                url: remoteApi,
                dataType: 'jsonp',
                cache:true,
                success: function (response,textStatus,jqXHR) {
                    if (response.extradata){
                        let extradata = $.opendataTools.helpers.i18n(response.extradata, 'view');
                        if (extradata.length > 0) {
                            var data = $(extradata);
                            data.find('a').each(function() {
                                $(this).attr('target','_blank');
                            });
                            container.replaceWith(data);
                            if (wrapper.length > 0) {
                                bootstrap.Masonry.getOrCreateInstance(wrapper[0]).dispose()
                                bootstrap.Masonry.getOrCreateInstance(wrapper[0])
                            }
                        }
                    }
                },
                error: function (jqXHR) {
                    let error = {
                        error_code: jqXHR.status,
                        error_message: jqXHR.statusText
                    };
                    console.log(error,jqXHR);
                }
            });
        }
        if (link.pathname.startsWith('/openpa/object/')){
            loadRemoteView(link.pathname.replace('/openpa/object/', ''));

        }else if (link.pathname.startsWith('/content/view/full/')){
            let nodeId = link.pathname.replace('/content/view/full/', '');
            $.ajax({
                type: "GET",
                url: link.protocol+'//'+link.hostname+'/api/opendata/v2/content/search/select-fields [metadata.id] and raw[meta_node_id_si] = '+nodeId+' limit 1',
                dataType: 'jsonp',
                cache:true,
                success: function (response,textStatus,jqXHR) {
                    if (response.length > 0) {
                        loadRemoteView(response[0]);
                    }
                },
                error: function (jqXHR) {
                    let error = {
                        error_code: jqXHR.status,
                        error_message: jqXHR.statusText
                    };
                    console.log(error,jqXHR);
                }
            });
        }
    });
});

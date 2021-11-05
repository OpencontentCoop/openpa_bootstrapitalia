$(document).ready(function () {
    $('[data-shared_link]').each(function () {
        let element = $(this);
        let link = new URL(element.attr('href'));
        let view = element.data('shared_link_view');
        let container = $('[data-object_id="'+element.data('shared_link')+'"].shared_link-'+view);
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
                            container.replaceWith(extradata);
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

{if and(
    fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' )),
    $current_user.is_logged_in,
    array('edit', 'browse')|contains($ui_context)|not()
)}
    <script>{literal}
    $(document).ready(function(){
        $('#toolbar').load($.ez.url+'call/openpaajax::loadWebsiteToolbar::{/literal}{if is_set($module_result.content_info.node_id)}{$module_result.content_info.node_id|int()}{else}0{/if}{literal}', null, function(response){
            $('body').addClass('fixed-wt');
            //load chosen in class list
            $("#ezwt-create").chosen({width:"300px !important"});
            $('#toolbar').trigger('ezwt-loaded');
            {/literal}{if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}{literal}
            window.announcekit = (window.announcekit || { queue: [], on: function(n, x) { window.announcekit.queue.push([n, x]); }, push: function(x) { window.announcekit.queue.push(x); } });
            window.announcekit.push({
                "widget": "https://announcekit.app/widgets/v2/{/literal}{openpaini('GeneralSettings', 'AnnounceKit')}{literal}",
                "selector": ".announcekit-widget",
                "name": "announcekit",
                "lang": "it"
            })
            window.announcekit.on("widget-unread", function({ widget, unread }) {
                var badge = $('#announce-news .badge');
                if (unread === 0) badge.hide();
                else badge.show().html(unread);
            })
            $('#announce-news').on('click', function (e) {
                announcekit.widget$announcekit.open();
                e.preventDefault();
            });
            {/literal}{/if}{literal}
        });
    });
    {/literal}</script>
    {if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}
    <script async src="https://cdn.announcekit.app/widget-v2.js"></script>
    {/if}
{/if}
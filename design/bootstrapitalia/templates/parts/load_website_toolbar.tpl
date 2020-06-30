{if $current_user.is_logged_in}
    <script>{literal}
    $(document).ready(function(){
        $('#toolbar').load($.ez.url+'call/openpaajax::loadWebsiteToolbar::{/literal}{$node.node_id}{literal}', null, function(response){
            $('body').addClass('fixed-wt');
            //load chosen in class list
            $("#ezwt-create").chosen({width:"200px"});
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
    <style>
        #announce-news .badge {ldelim}
            display: inline-block;
            background-color: #a66300;
            border-radius: 50%;
            color: #fff;
            padding: 0.5em 0.75em;
            position: relative;
        {rdelim}
        #announce-news .pulsate::before {ldelim}
            content: '';
            display: block;
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            animation: pulse 1s ease infinite;
            border-radius: 50%;
            border: 4px double #ea8c00;
        {rdelim}
        @keyframes pulse {ldelim}
            0% {ldelim}
                transform: scale(1);
                opacity: 1;
            {rdelim}
            60% {ldelim}
                transform: scale(1.3);
                opacity: 0.4;
            {rdelim}
            100% {ldelim}
                transform: scale(1.4);
                opacity: 0;
            {rdelim}
        {rdelim}
    </style>
    {/if}
{/if}
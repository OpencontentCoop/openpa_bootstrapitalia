{if $current_user.is_logged_in}
    <script>{literal}
    $(document).ready(function(){
        $('#toolbar').load($.ez.url+'call/openpaajax::loadWebsiteToolbar::{/literal}{$node.node_id}{literal}', null, function(response){
            $('body').addClass('fixed-wt');
            //load chosen in class list
            $("#ezwt-create").chosen({width:"200px"});
            $('#toolbar').trigger('ezwt-loaded');
        });
    });
    {/literal}</script>
{/if}
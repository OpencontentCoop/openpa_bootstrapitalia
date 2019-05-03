{if $current_user.is_logged_in}
    <script>{literal}
    $(document).ready(function(){
        $('#toolbar').load($.ez.url+'call/openpaajax::loadWebsiteToolbar::{/literal}{$node.node_id}{literal}', null, function(response){
            $('body').addClass('fixed-wt');
            //load chosen in class list
            $("#ezwt-create").chosen({width:"200px"});
            //load editor tools button
            var $editorTools = $(".editor_tools");
            if ( $editorTools.length > 0 ){
                var help = $("#ezwt-help");
                if ( help.data('show-editor') == 0 ){
                    $editorTools.hide();
                }else{
                    $editorTools.show();
                }
                help.removeClass('hide').on( 'click', function(e){
                    $editorTools.toggle();
                    $.ez.setPreference( 'show_editor', $editorTools.is(':hidden') === false ? 1 : 0 );
                    e.preventDefault();
                });
            }
        });
    });
    {/literal}</script>
{/if}
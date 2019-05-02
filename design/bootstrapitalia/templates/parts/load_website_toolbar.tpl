{if $current_user.is_logged_in}
    <script>{literal}
    $(document).ready(function(){
        $('#toolbar').load($.ez.url+'call/openpaajax::loadWebsiteToolbar::{/literal}{$node.node_id}{literal}', null, function(response){
            //load chosen in class list
            $("#ezwt-create").chosen({width:"250px"});
            //load editor tootl button
            var $editorTools = $(".editor_tools");
            if ( $editorTools.length > 0 ){
                var help = $("#ezwt-help");
                if ( help.data('show-editor') == 0 ) $editorTools.hide();
                help.removeClass('hide').find( 'a').on( 'click', function(e){
                    $editorTools.toggle();
                    $.ez.setPreference( 'show_editor', $editorTools.is(':hidden') == false ? 1 : 0 );
                    e.preventDefault();
                });
            }
            //floating toolbar
            var body = document.body, ezwt = document.getElementById( 'ezwt-content' );
            if ( !ezwt ) return;
            if ( body.className.indexOf('ie6') !== -1 ) return;
            if ( body.className )
                body.className += ' floating-wt';
            else
                body.className = 'floating-wt';
            //body.style.paddingTop = ezwt.offsetHeight + 'px';
        });
    });
    {/literal}</script>
{/if}
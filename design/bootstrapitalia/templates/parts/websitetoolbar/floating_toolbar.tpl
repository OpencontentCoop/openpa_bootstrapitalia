{* Move toolbar to top of page using classes and css (see websitetoolbar.tpl) *}
{literal}
<script type="text/javascript">
<!--
(function()
{
    var body = document.body, ezwt = document.getElementById( 'ezwt' );
    if ( !ezwt ) return;

    if ( body.className )
        body.className += ' floating-wt';
    else
        body.className = 'floating-wt';
})();
//-->
</script>
{/literal}

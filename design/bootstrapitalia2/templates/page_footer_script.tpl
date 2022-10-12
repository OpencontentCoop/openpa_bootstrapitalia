{if fetch('user','current_user').is_logged_in|not()}
{ezscript(array(
    'chosen.jquery.js',
    'jquery.opendataDataTable.js',
    'stacktable.js',
    'jsrender.js',
    'jquery.faqs.js',
    'jquery.sharedlink.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap4.min.js',
    'jquery.blueimp-gallery.min.js'
))}
{/if}
<script>window.__PUBLIC_PATH__ = "{'fonts'|ezdesign( 'no' )}"</script>
<script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )}"></script>

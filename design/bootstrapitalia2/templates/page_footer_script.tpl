<script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )}"></script>
<script>window.__PUBLIC_PATH__ = "{'fonts'|ezdesign( 'no' )}";bootstrap.loadFonts()</script>

{if fetch('user','current_user').is_logged_in|not()}
{ezscript_load()}
{/if}
{ezcss(array('common.css'))}
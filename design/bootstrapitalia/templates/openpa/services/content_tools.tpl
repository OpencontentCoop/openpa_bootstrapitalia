{if fetch(user, current_user).is_logged_in}
<div id="editor_tools" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Informazioni per l'editor</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">×</span>
                </button>
            </div>
            <div class="modal-body">
            {debug-accumulator id=editor_tools name=editor_tools}
            {include uri="design:openpa/services/tools/info.tpl"}
            {/debug-accumulator}
            </div>
        </div>
    </div>
</div>
{/if}
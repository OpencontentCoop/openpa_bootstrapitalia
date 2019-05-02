{if fetch(user, current_user).is_logged_in}
<div id="editor_tools" class="card-wrapper card-space editor_tools">
    <div class="card card-bg border-bottom-card">
        <div class="card-body">
            <h4 class="card-title"><i class="fa fa-info-circle"></i> Informazioni per l'editor</h4>
            {debug-accumulator id=editor_tools name=editor_tools}
            {include uri="design:openpa/services/tools/info.tpl"}
            {/debug-accumulator}
        </div>
    </div>
</div>
{/if}
{if and( openpaini('GeneralSettings', 'ShowFooterNotes', 'disabled')|eq('enabled'), $pagedata.footer.notes )}
<div class="row">
    <div class="col-12 footer-items-wrapper footer-notes">
        {attribute_view_gui attribute=$pagedata.footer.notes}
    </div>
</div>
{/if}

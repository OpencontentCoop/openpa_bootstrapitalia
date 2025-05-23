<div class="modal fade" tabindex="-1" role="dialog" id="infoModal" aria-labelledby="infoModalTitle">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title h4" id="infoModalTitle">{attribute_view_gui attribute=$infobox.data_map.name}</h2>
                <button class="btn-close" type="button" data-bs-dismiss="modal" aria-label="Chiudi finestra modale">
                    {display_icon('it-close', 'svg', 'icon')}
                </button>
            </div>
            <div class="modal-body">
                <div class="richtext-wrapper">{attribute_view_gui attribute=$infobox.data_map.description}</div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-primary btn-sm" data-bs-dismiss="modal" type="button">{$infobox.data_map.location.data_text|wash()}</button>
            </div>
        </div>
    </div>
</div>
<script>
  $(document).ready(function(){ldelim}
    var infoModal = new bootstrap.Modal(document.getElementById('infoModal'));
    infoModal.show()
      {rdelim})
</script>
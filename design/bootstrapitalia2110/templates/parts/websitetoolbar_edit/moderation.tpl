<li>
    <div class="form-check form-check-group pb-0 my-0 border-0" style="box-shadow:none">
        <div class="toggles">
            <label for="ModerationStatus" class="mb-0 font-weight-normal" style="max-width: 100px;">
                <input type="checkbox" data-id="{$content_object.id}" id="ModerationStatus"
                       value="1"{if $content_object.state_identifier_array|contains('moderation/waiting')} checked="checked"{/if}>
                <span class="lever" style="float:none;display: inline-block;margin-bottom: 5px;"></span>
                <span class="toolbar-label"
                      style="font-size: .65em;">{'Nascondi contenuto'|i18n( 'bootstrapitalia' )}</span>
            </label>
        </div>
    </div>
</li>
<script>{literal}
  $(document).ready(function () {
    $('#ModerationStatus').on('change', function (e) {
      let self = $(this)
      let id = self.data('id');
      let checked = self.is(':checked')
      let status = checked ? 'waiting' : 'skipped'
      $.ajax({
        type: 'GET',
        url: '/bootstrapitalia/set-moderation/' + status + '/' + id,
        data: {format: 'json'},
        success: function (response) {
          if (response.status === 'error') {
            self.prop('checked', !checked);
          }
        },
        error: function () {
          self.prop('checked', !checked);
        }
      });
    });
  });
    {/literal}</script>

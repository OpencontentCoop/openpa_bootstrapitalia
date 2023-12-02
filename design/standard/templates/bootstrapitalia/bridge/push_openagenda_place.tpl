<h2>
    <a href="{$place.main_node.url|ezurl(no)}">{$place.name|wash()}</a>
    <i class="fa fa-arrow-right"></i>
    <a href="{$openageda_url}">OpenAgenda</a>
</h2>
<div class="alert alert-danger"{if $error|eq(false())} style="display:none"{/if}>{$error|wash()}</div>
{if $error|eq(false())}
<div class="row">
    <div class="col-11">
        <div class="progress" style="margin-top:5px;height:20px">
            <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
        </div>
    </div>
    <div class="col-1">
        <i class="spinner fa fa-circle-o-notch fa-spin fa-2x fa-fw"></i>
    </div>
</div>

<script>
  var payloads = {$payloads_count};
  var placeId = "{$place.id}";
  {literal}
  $(document).ready(function () {
    var pushPlace = function () {
      $.getJSON('/bootstrapitalia/bridge/push-openagenda-place/' + placeId + '/?push=1', function (data) {
        console.log(data);
        if (data.error) {
          $('.alert-danger').text(data.error).show();
          $('.progress').hide();
          $('.spinner').hide();
        } else if (data.payloads > 0) {
          console.log(
            100 - parseInt(data.payloads * 100 / payloads)
          );
          $('.progress-bar').css('width', (100 - parseInt(data.payloads * 100 / payloads)) + '%');
          pushPlace()
        } else {
          $('.progress-bar').css('width', '100%');
          $('.spinner').removeClass('fa-circle-o-notch fa-spin').addClass('fa-check')
        }
      })
    }
    $('.progress-bar').css('width', '10%');
    pushPlace();
  })
  {/literal}
</script>
{/if}
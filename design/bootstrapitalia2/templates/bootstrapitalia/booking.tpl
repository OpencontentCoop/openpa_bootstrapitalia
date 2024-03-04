{if $offices|count()|eq(0)}
{include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-heading pb-3 pb-lg-4">
                <div class="alert alert-danger">
                    <p class="lead m-0">Servizio momentaneamente non disponibile</p>
                </div>
            </div>
        </div>
    </div>
</div>

{else}
<div data-booking>
    {include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
    {include uri='design:bootstrapitalia/booking/page_title.tpl'}
    {include uri='design:bootstrapitalia/booking/steps.tpl'}

    <div id="stepper-loading" class="text-center my-5">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    </div>
    {foreach $steps as $index => $step}
        {include uri=concat('design:bootstrapitalia/booking/steps/', $step.id, '.tpl') step=$step hide=true()}
    {/foreach}
    {include uri='design:bootstrapitalia/booking/feedback.tpl'}
    {include uri='design:bootstrapitalia/booking/error.tpl'}
</div>
<style>
    .no-availabilities {ldelim}
        position: absolute;
        left: 0;
        top: 0;
        margin: 0;
        background: #fff;
        width: 100%;
        height: 100%;
    {rdelim}
    .freeze:after {ldelim}
      content: " ";
        position: absolute;
        left: 0;
        top: 0;
        margin: 0;
        background: #ddd;
        opacity: 0.6;
        width: 100%;
        height: 100%;
    {rdelim}
</style>

<script>
  $(document).ready(function () {ldelim}
    $('[data-booking]').opencityBooking({ldelim}
      storageKey: "{$page_key|wash()}",
      tokenUrl: "{$pal|user_token_url()}",
      profileUrl: "{$pal|user_profile_url()}",
      prefix: UriPrefix,
      debug: false,
      useCalendarFilter: {$use_calendar_filter}
    {rdelim})
  {rdelim})
</script>
{*{ezscript(array('jquery.booking.js'))}*}
<script src={"javascript/jquery.booking.js"|ezdesign}></script>
{/if}
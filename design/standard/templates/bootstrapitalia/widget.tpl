{ezpagedata_set( 'has_container', true() )}
<div class="container mb-3">
    <h1 class="mb-5">Builtin widgets</h1>
    <div class="row text-center">
        {foreach $list as $builtin}
        <div class="col">
            <a href="{concat('/bootstrapitalia/widget/', $builtin.identifier)|ezurl(no)}"
               class="btn btn-xl btn-primary">{$builtin.label|i18n('bootstrapitalia/footer')}</a>
        </div>
        {/foreach}
    </div>
</div>

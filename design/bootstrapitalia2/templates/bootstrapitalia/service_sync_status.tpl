{ezpagedata_set( 'has_container', true() )}
<section class="container">
    <div class="row my-5">
        <div class="col">
            <h2>{$service.name|wash()}</h2>

            <dl class="row">
            {foreach $info as $key => $value}
                <dt class="col-sm-3 text-end">{$key|wash()}</dt>
                <dd class="col-sm-9">{if is_set($value[0])}{foreach $value as $item}{$item|wash()}{delimiter}<br />{/delimiter}{/foreach}{else}{$value|wash()}{/if}</dd>
            {/foreach}
            </dl>
            {if count($errors)}
            <div class="alert alert-warning richtext-wrapper">
                <h5>Issues:</h5>
                <ol>
                {foreach $errors as $key => $value}
                    <li class="mb-3">
                        {$value.message|wash()}
                        {if $value.topic|eq('sync')}
                            <p class="m-0"><span class="badge bg-primary">locale</span> {$value.locale|wash()}</p>
                            <p class="m-0"><span class="badge bg-info">remote</span> {$value.remote|wash()}</p>
                        {/if}
                    </li>
                {/foreach}
                </ol>
            </div>
            {/if}
        </div>
    </div>
</section>
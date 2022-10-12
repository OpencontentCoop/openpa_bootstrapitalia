{if $error}
    <div class="message-error">
        <p>{$error}</p>
    </div>
{else}
<div class="p-3 u-padding-all-xl">
    <h2 data-uri="{$uri|wash()}">{$uri|wash()}</h2>
    <div class="row mt-5 Grid Grid--withGutter u-margin-top-xl">
        <div class="col-md-3 Grid-cell u-md-size1of4 u-lg-size1of6">
            <ul class="nav nav-pills">
                {foreach $output_format_list as $name => $value}
                    {if array('png', 'gif', 'svg')|contains($value)}{skip}{/if} {*@todo*}
                    <li role="presentation"
                        class="nav-item w-100 u-margin-bottom-l">
                        <a class="text-decoration-none nav-link{if $value|eq('turtle')} active{/if}"
                           data-value="{$value}"
                           data-ext="{if $value|eq('turtle')}ttl{elseif $value|eq('ntriples')}n3{elseif $value|eq('rdfxml')}rdf{else}{$value}{/if}"
                           data-header="{$header_format_list[$name][0]}"
                           data-available_headers="{$header_format_list[$name]|implode(',')}"
                           href="#">
                            {$name|wash()}
                        </a>
                    </li>
                {/foreach}
            </ul>
        </div>
        <div class="col-md-9 Grid-cell u-md-size3of4 u-lg-size5of6">
            <p class="currenturi pb-2" style="display: none;">
                Direct url: <a target="_blank" href="{$uri}">{$uri|wash()}</a>
            </p>
            <pre class="response" style="display: none;font-size: .8em;background:#eee;padding: 5px 10px;border-radius: 5px;"></pre>
            <div class="spinner text-center">
                <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
            </div>
        </div>
    </div>
</div>
{/if}

<script>
    {literal}
    $(document).ready(function () {
        var loadData = function () {
            var activePill = $('.nav-pills a.active');
            var preContainer = $('pre.response');
            var spinner = $('div.spinner');
            var currentUriContainer = $('p.currenturi');
            preContainer.hide();
            currentUriContainer.hide();
            spinner.show();
            var uri = $('[data-uri]').data('uri');
            var header = activePill.data('header');
            var ext = activePill.data('ext');
            var request = $.ajax({
                url: uri,
                method: "GET",
                data: {encode: true},
                headers: {
                    Accept: header
                },
                success: function (response) {
                    try {
                        var json = JSON.parse(response);
                        response = JSON.stringify(json, undefined, 2);
                    } catch (e) {
                        //console.log(e);
                    }
                    spinner.hide();
                    var currentUri = uri+'.'+ext;
                    currentUriContainer.find('a').attr('href', currentUri).html(currentUri);
                    currentUriContainer.show();
                    preContainer.html(response).show();
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log(textStatus);
                }
            });
        };
        $('.nav-pills a').on('click', function (e) {
            $('.nav-pills a.active').removeClass('active').css('font-weight', 'normal');
            $(this).addClass('active').css('font-weight', 'bold');
            e.preventDefault();
            loadData();
        });
        $('.nav-pills a.active').css('font-weight', 'bold');
        loadData();
    });
    {/literal}
</script>
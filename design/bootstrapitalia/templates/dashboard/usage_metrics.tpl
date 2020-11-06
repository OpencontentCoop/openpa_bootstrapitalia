<div class="my-3 p-3 bg-white rounded shadow-sm">
    <h4 class="border-bottom border-gray pb-2 mb-0">Servizi attivi</h4>
    <div data-metric="usage_metrics"></div>
</div>
{literal}
    <script>
        $(document).ready(function () {
            var usageMetricsContainer = $('[data-metric="usage_metrics"]');
            $.getJSON('/openpa/data/usage_metrics/OpenCity', function (data) {
                var wrapper = $('<ul class="list-unstyled"></ul>');
                $('<li><a href="//' + data.service_url + '" title="' + data.service_name + '"><strong>' + data.service_name + '</strong></a></li>').appendTo(wrapper);
                $.each(data.usage_metrics, function () {
                    $('<li>' + this.name + ': ' + ' ' + this.value + '</li>').appendTo(wrapper);
                });
                wrapper.appendTo(usageMetricsContainer);
            });
        });
    </script>
{/literal}
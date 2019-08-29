{ezscript_require(array('highcharts.js'))}

<h6>Enti pubblici vigilati</h6>
<div class="load-grah" data-remote="367f45c867601ef7e8a3d2c125b287ca"
     style="min-width: 310px; height: 1000px; margin: 0 auto"></div>

<h6>Società partecipate</h6>
<div class="load-grah" data-remote="1b7517be4dde8b70eaf65f69e5c46311"
     style="min-width: 310px; height: 1000px; margin: 0 auto"></div>

<h6>Enti di diritto privato controllati</h6>
<div class="load-grah" data-remote="b8ba159b3f102091f5f2c41ef32c190b"
     style="min-width: 310px; height: 1000px; margin: 0 auto"></div>

<script>
  {literal}
  $(function () {
    $('.load-grah').each(function () {
      var $container = $(this);
      var $prev = $container.prev();
      var remote = $(this).data('remote');
      $.getJSON("/openpa/data/partecipazioni/?remote="+remote, function (response) {
        var enti = [];
        var series = [];
        var length = $.map(response.enti, function (n, i) {
          return i;
        }).length;
        var countData = $.map(response.series, function (n, i) {
          return n.reduce(function(a, b) { return a + b; }, 0);
        }).reduce(function(a, b) { return a + b; }, 0);
        if (typeof response.enti != 'undefined' && length > 0 && countData > 0) {
          $.each(response.enti, function (i, v) {
            enti.push(v)
          });
          $.each(response.series, function (i, v) {
            series.push({name: i, data: v});
          });
          $container.highcharts({
            chart: {
              type: 'bar'
            },
            title: {
              text: ''
            },
            xAxis: {
              categories: enti,
              title: {
                text: null
              }
            },
            yAxis: {
              min: 0,
              max: 100,
              title: {
                text: $prev.text(),
                align: 'high'
              },
              labels: {
                overflow: 'justify'
              }
            },
            tooltip: {
              valueSuffix: ' %'
            },
            plotOptions: {
              bar: {
                dataLabels: {
                  enabled: true
                }
              }
            },
            legend: {
              borderWidth: 1,
              backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
              shadow: true
            },
            credits: {
              enabled: false
            },
            series: series
          });
        } else {
          $prev.hide();
          $container.hide();
        }
      });
    });
  });
  {/literal}
</script>

{def $attribute_content = $attribute.content}
{if is_set($id_prefix)|not()}
    {def $id_prefix = rand( 0, $attribute.id )}
{/if}

{def $element_id = concat($id_prefix, $attribute.id)}

{if $attribute_content.data_source_is_valid}
    <div id="chart-render_{$element_id}" 
         {if is_set($width)}style="width:{$width}"{/if}
         data-url="{concat('/occhart/data/', $attribute.id, '/', $attribute.version)|ezurl(no)}"
         data-config='{$attribute_content.config_string}'
         {if is_set($ratio)}data-ratio="{$ratio}"{/if}
         {if and(is_set($show_title), $show_title|eq(false()))}data-hidetitle="1"{/if}
         {if and(is_set($responsive), $responsive|eq(true()))}data-responsive="1"{/if}
         {if and(is_set($show_legend), $show_legend|eq(false()))}data-hidelegend="1"{/if}
         {if and(is_set($show_export), $show_export|eq(false()))}data-hideexport="1"{/if}>
        <p class="text-center mt-5"><i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw text-black"></i></p>
    </div>

    {run-once}
    {ezscript_require(array(
        'ezjsc::jquery',
        'ec.min.js',
        'highcharts/highcharts.js',
        'highcharts/highcharts-3d.js',
        'highcharts/highcharts-more.js',
        'highcharts/modules/funnel.js',
        'highcharts/modules/heatmap.js',
        'highcharts/modules/solid-gauge.js',
        'highcharts/modules/treemap.js',
        'highcharts/modules/boost.js',
        'highcharts/modules/exporting.js',
        'highcharts/modules/no-data-to-display.js',
        'jquery.occhart.js'
    ))}
    {ezcss_require(array(
        'ec.css',
        'highcharts/highcharts.css'
    ))}
    {/run-once}

    <script>{literal}
        $(document).ready(function(){
            $('#chart-render_{/literal}{$element_id}{literal}').occhart();
        });
    {/literal}</script>
{/if}
{undef $attribute_content}
{set_defaults(hash('image_class', 'large', 'view_variation', ''))}

{def $chart = false()}
{foreach $node.data_map as $identifier => $attribute}
    {if and($attribute.data_type_string|eq('opendatadataset'), $attribute.has_content, $attribute.content.views|contains('chart'))}
        {set $chart = $attribute}
        {ezscript_require(array(
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
        {break}
    {/if}
{/foreach}

<div class="it-grid-item-wrapper it-grid-item-overlay {$node|access_style}">
    <a class="" title="{$node.name|wash()}" {if $view_variation|eq('gallery')}data-gallery href={$node|attribute('image').content.reference.url|ezroot}{else}href="{$openpa.content_link.full_link}"{/if}>
        <div class="img-responsive-wrapper{if $chart|not()} bg-dark{/if}">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {if $chart}
                        <div id="chart-render_{$chart.id}" style="min-height:400px"
                             data-url="{concat('/customexport/dataset-', $chart.contentclass_attribute_identifier, '-',$chart.contentobject_id)|ezurl(no)}/"
                             data-config='{$chart.content.settings.chart}'
                             data-ratio="16:9"
                             data-responsive="1"
                             data-hidelegend="1"
                             data-hideexport="1">
                            <p class="text-center mt-5"><i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw text-black"></i></p>
                        </div>
                        <script>{literal}
                            $(document).ready(function(){
                                $('#chart-render_{/literal}{$chart.id}{literal}').occhart();
                            });
                        {/literal}</script>
                    {elseif $node|has_attribute('image')}
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
                    {else}
                        <div class="bg-dark" style="width:{rand(300,400)}px;height:{rand(300,400)}px"></div>
                    {/if}
                </div>
            </div>
        </div>
        {if $chart|not()}
        <span class="it-griditem-text-wrapper">
            <h3>{$node.name|wash()}</h3>
        </span>
        {/if}
    </a>
</div>
{unset_defaults(array('image_class', 'view_variation'))}
{ezpagedata_set( 'has_container', true() )}

<div class="container mb-3">
    <h2>Impostazioni Tema</h2>
    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

    {if count($theme_list)}
        <form method="post" action="{'bootstrapitalia/theme'|ezurl(no)}" class="form">
            <div class="row">
                <div class="col-8 col-md-6">
                    <div class="form-group">
                        <label for="theme">Tema</label>
                        <select id="theme" class="Form-input u-color-black form-control" name="Theme">
                            {foreach $theme_list as $item}
                                <option value="{$item|wash()}"{if $current_base_theme|eq($item)} selected="selected"{/if}>{$item|wash()}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="form-group form-check">
                        <input id="use_light_slim"
                               class="form-check-input"
                               type="checkbox"
                               name="use_light_slim"
                               {if $use_light_slim}checked="checked"{/if}
                               value="1" />
                        <label class="form-check-label" for="use_light_slim">
                            Slim header in versione chiara
                        </label>
                    </div>
                    <div class="form-group form-check">
                        <input id="use_light_center"
                               class="form-check-input"
                               type="checkbox"
                               name="use_light_center"
                               {if $use_light_center}checked="checked"{/if}
                               value="1" />
                        <label class="form-check-label" for="use_light_center">
                            Header center in versione chiara
                        </label>
                    </div>
                    <div class="form-group form-check">
                        <input id="use_light_navbar"
                               class="form-check-input"
                               type="checkbox"
                               name="use_light_navbar"
                               {if $use_light_navbar}checked="checked"{/if}
                               value="1" />
                        <label class="form-check-label" for="use_light_navbar">
                            Header nav in versione chiara
                        </label>
                    </div>
                </div>
                <div class="col-12 col-md-6 mt-2">
                    <div class="px-2">
                        <div id="theme-preview" class="border">
                            <div id="preview-service" class="w-100 border-bottom position-relative" style="height: 20px"><code style="font-size: 9px;position:absolute">Slim header</code></div>
                            <div id="preview-header" class="w-100 border-bottom position-relative" style="height: 40px"><code style="font-size: 9px;position:absolute">Header center</code></div>
                            <div id="preview-main_menu" class="w-100 border-bottom position-relative" style="height: 15px"><code style="font-size: 9px;position:absolute">Header nav</code></div>
                            <div id="preview-main" class="w-100" style="height: 200px"></div>
                            <div id="preview-footer_main" class="w-100" style="height: 50px"></div>
                            <div id="preview-footer" class="w-100" style="height: 15px"></div>
                        </div>
                    </div>
                </div>
                <div class="col-12 text-right mt-3">
                    <input type="submit" class="btn btn-success" name="StoreTheme" value="Salva"/>
                </div>
            </div>
        </form>
    {/if}
</div>

<script>{literal}
    $(document).ready(function(){
        var showThemePreview = function (){
            var base = $('#theme').val();
            var useLightSlim = $('#use_light_slim').is(':checked');
            var useLightCenter = $('#use_light_center').is(':checked');
            var useLightNavbar = $('#use_light_navbar').is(':checked');
            var identifier = base;
            if (useLightSlim){
                identifier += '::light_slim';
            }
            if (useLightCenter){
                identifier += '::light_center';
            }
            if (useLightNavbar){
                identifier += '::light_navbar';
            }
            $.getJSON('/openpa/data/theme?identifier='+identifier, function (response){
                $.each(response.colors, function (id, value){
                    $('#theme-preview #preview-'+id).css('background', value);
                });
            })
        }
        $.each(['theme', 'use_light_slim', 'use_light_center', 'use_light_navbar'], function (){
            $('#'+this).on('change', function (){
                showThemePreview();
            });
        })
        showThemePreview();
    })
{/literal}</script>


{literal}<style>.box{width: 100%; height: 100px; text-align: center}</style>{/literal}
<div class="container pt-5 mt-5 hide">
    <h3>Palette</h3>
    <div class="row">
        <div class="col-2 mb-2"><div class="primary-bg box"></div>primary</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="primary-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="primary-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="primary-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="primary-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="primary-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="primary-bg-a6 box"></div>a6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="primary-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="primary-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="primary-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="primary-bg-a10 box"></div>a10</div>
        <div class="col mb-2"><div class="primary-bg-a11 box"></div>a11</div>
        <div class="col mb-2"><div class="primary-bg-a12 box"></div>a12</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="primary-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="primary-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="primary-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="primary-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="primary-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="primary-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="primary-bg-b7 box"></div>b7</div>
        <div class="col mb-2"><div class="primary-bg-b8 box"></div>b8</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="primary-bg-c1 box"></div>c1</div>
        <div class="col mb-2"><div class="primary-bg-c2 box"></div>c2</div>
        <div class="col mb-2"><div class="primary-bg-c3 box"></div>c3</div>
        <div class="col mb-2"><div class="primary-bg-c4 box"></div>c4</div>
        <div class="col mb-2"><div class="primary-bg-c5 box"></div>c5</div>
        <div class="col mb-2"><div class="primary-bg-c6 box"></div>c6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="primary-bg-c7 box"></div> c7</div>
        <div class="col mb-2"><div class="primary-bg-c8 box"></div> c8</div>
        <div class="col mb-2"><div class="primary-bg-c9 box"></div> c9</div>
        <div class="col mb-2"><div class="primary-bg-c10 box"></div>c10</div>
        <div class="col mb-2"><div class="primary-bg-c11 box"></div>c11</div>
        <div class="col mb-2"><div class="primary-bg-c12 box"></div>c12</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="analogue-1-bg box"></div>analogue-1</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="analogue-1-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="analogue-1-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="analogue-1-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="analogue-1-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="analogue-1-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="analogue-1-bg-a6 box"></div>a6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="analogue-1-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="analogue-1-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="analogue-1-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="analogue-1-bg-a10 box"></div>a10</div>
        <div class="col mb-2"><div class="analogue-1-bg-a11 box"></div>a11</div>
        <div class="col mb-2"><div class="analogue-1-bg-a12 box"></div>a12</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="analogue-1-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="analogue-1-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="analogue-1-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="analogue-1-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="analogue-1-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="analogue-1-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="analogue-1-bg-b7 box"></div>b7</div>
        <div class="col mb-2"><div class="analogue-1-bg-b8 box"></div>b8</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="analogue-2-bg box"></div>analogue-2</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="analogue-2-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="analogue-2-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="analogue-2-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="analogue-2-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="analogue-2-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="analogue-2-bg-a6 box"></div>a6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="analogue-2-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="analogue-2-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="analogue-2-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="analogue-2-bg-a10 box"></div>a10</div>
        <div class="col mb-2"><div class="analogue-2-bg-a11 box"></div>a11</div>
        <div class="col mb-2"><div class="analogue-2-bg-a12 box"></div>a12</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="analogue-2-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="analogue-2-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="analogue-2-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="analogue-2-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="analogue-2-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="analogue-2-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="analogue-2-bg-b7 box"></div>b7</div>
        <div class="col mb-2"><div class="analogue-2-bg-b8 box"></div>b8</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="complementary-1-bg box"></div>complementary-1</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="complementary-1-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="complementary-1-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="complementary-1-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="complementary-1-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="complementary-1-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="complementary-1-bg-a6 box"></div>a6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="complementary-1-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="complementary-1-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="complementary-1-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="complementary-1-bg-a10 box"></div>a10</div>
        <div class="col mb-2"><div class="complementary-1-bg-a11 box"></div>a11</div>
        <div class="col mb-2"><div class="complementary-1-bg-a12 box"></div>a12</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="complementary-1-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="complementary-1-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="complementary-1-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="complementary-1-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="complementary-1-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="complementary-1-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="complementary-1-bg-b7 box"></div>b7</div>
        <div class="col mb-2"><div class="complementary-1-bg-b8 box"></div>b8</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="complementary-2-bg box"></div>complementary-2</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="complementary-2-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="complementary-2-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="complementary-2-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="complementary-2-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="complementary-2-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="complementary-2-bg-a6 box"></div>a6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="complementary-2-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="complementary-2-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="complementary-2-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="complementary-2-bg-a10 box"></div>a10</div>
        <div class="col mb-2"><div class="complementary-2-bg-a11 box"></div>a11</div>
        <div class="col mb-2"><div class="complementary-2-bg-a12 box"></div>a12</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="complementary-2-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="complementary-2-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="complementary-2-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="complementary-2-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="complementary-2-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="complementary-2-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="complementary-2-bg-b7 box"></div>b7</div>
        <div class="col mb-2"><div class="complementary-2-bg-b8 box"></div>b8</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="complementary-3-bg box"></div>complementary-3</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="complementary-3-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="complementary-3-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="complementary-3-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="complementary-3-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="complementary-3-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="complementary-3-bg-a6 box"></div>a6</div>
        <div class="w-100"></div>
        <div class="col mb-2"><div class="complementary-3-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="complementary-3-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="complementary-3-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="complementary-3-bg-a10 box"></div>a10</div>
        <div class="col mb-2"><div class="complementary-3-bg-a11 box"></div>a11</div>
        <div class="col mb-2"><div class="complementary-3-bg-a12 box"></div>a12</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="complementary-3-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="complementary-3-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="complementary-3-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="complementary-3-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="complementary-3-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="complementary-3-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="complementary-3-bg-b7 box"></div>b7</div>
        <div class="col mb-2"><div class="complementary-3-bg-b8 box"></div>b8</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="neutral-1-bg box"></div>neutral-1</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="neutral-1-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="neutral-1-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="neutral-1-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="neutral-1-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="neutral-1-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="neutral-1-bg-a6 box"></div>a6</div>
        <div class="col mb-2"><div class="neutral-1-bg-a7 box"></div>a7</div>
        <div class="col mb-2"><div class="neutral-1-bg-a8 box"></div>a8</div>
        <div class="col mb-2"><div class="neutral-1-bg-a9 box"></div>a9</div>
        <div class="col mb-2"><div class="neutral-1-bg-a10 box"></div>a10</div>
    </div>

    <div class="row mt-5">
        <div class="col-2 mb-2"><div class="neutral-2-bg box"></div>neutral-2</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="neutral-2-bg-a1 box"></div>a1</div>
        <div class="col mb-2"><div class="neutral-2-bg-a2 box"></div>a2</div>
        <div class="col mb-2"><div class="neutral-2-bg-a3 box"></div>a3</div>
        <div class="col mb-2"><div class="neutral-2-bg-a4 box"></div>a4</div>
        <div class="col mb-2"><div class="neutral-2-bg-a5 box"></div>a5</div>
        <div class="col mb-2"><div class="neutral-2-bg-a6 box"></div>a6</div>
        <div class="col mb-2"><div class="neutral-2-bg-a7 box"></div>a7</div>
    </div>
    <div class="row">
        <div class="col mb-2"><div class="neutral-2-bg-b1 box"></div>b1</div>
        <div class="col mb-2"><div class="neutral-2-bg-b2 box"></div>b2</div>
        <div class="col mb-2"><div class="neutral-2-bg-b3 box"></div>b3</div>
        <div class="col mb-2"><div class="neutral-2-bg-b4 box"></div>b4</div>
        <div class="col mb-2"><div class="neutral-2-bg-b5 box"></div>b5</div>
        <div class="col mb-2"><div class="neutral-2-bg-b6 box"></div>b6</div>
        <div class="col mb-2"><div class="neutral-2-bg-b7 box"></div>b7</div>
    </div>
</div>
<div class="container">
    <h2>Impostazioni Tema</h2>
    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

    {if count($theme_list)}
        <form method="post" action="{'bootstrapitalia/theme'|ezurl(no)}" class="form">
            <div class="row">
                <div class="col-md-6 col-md-offset-3">
                    <select id="theme" class="Form-input u-color-black form-control" name="Theme" placeholder="">
                        {foreach $theme_list as $item}
                            <option value="{$item|wash()}"{if $current_theme|eq($item)} selected="selected"{/if}>{$item|wash()}</option>
                        {/foreach}
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="submit" class="btn btn-success" name="StoreTheme" value="Salva"/>
                </div>
        </form>
    {/if}

</div>


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
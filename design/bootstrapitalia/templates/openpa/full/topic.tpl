{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path',false() )}
{def $homepage = fetch('openpa', 'homepage')}

<div class="it-hero-wrapper it-wrapped-container">
    {if $node|has_attribute('image')}
        <div class="img-responsive-wrapper">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {attribute_view_gui attribute=$node|attribute('image') image_class=reference}
                </div>
            </div>
        </div>
    {/if}

    <div class="container">
        <div class="row">
            <div class="col-12 px-lg-5">
                <div class="it-hero-card it-hero-bottom-overlapping px-2 px-lg-5 py-2 py-lg-5 rounded shadow">
                    <div class="container">
                        <div class="row">
                            <div class="col">
                                <nav class="breadcrumb-container" aria-label="breadcrumb">
                                    <ol class="breadcrumb">
                                        <li class="breadcrumb-item">
                                            <a href="{'/'|ezurl(no)}">{$homepage.name|wash()}</a>
                                        </li>
                                        <li class="breadcrumb-item">
                                            <a href="{$node.parent.url_alias|ezurl(no)}">{$node.parent.name|wash()}</a>
                                        </li>
                                        <li class="breadcrumb-item active" aria-current="page">
                                            {$node.name|wash()}
                                        </li>
                                    </ol>
                                </nav>   
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-6">
                                <h1>{$node.name|wash()}</h1>
                                {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            </div>         
                            <div class="col-lg-4 offset-lg-2">
                            </div>
                        </div>                    
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>    

{if $node|has_attribute('layout')}
    {attribute_view_gui attribute=$node|attribute('layout')}
{else}
    <div style="min-height:100px"></div>
{/if}
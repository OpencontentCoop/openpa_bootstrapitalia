<div class="container" id="main-container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-breadcrumbs" role="navigation">
                <nav class="breadcrumb-container" aria-label="breadcrumb">
                    <ol class="breadcrumb p-0" data-element="breadcrumb">
                        <li class="breadcrumb-item"><a href="{'/'|ezurl(no)}">Home</a><span class="separator">/</span></li>
                        {if $service}
                            <li class="breadcrumb-item"><a href="{$service.main_node.parent.url_alias|ezurl(no)}">{$service.main_node.parent.name|wash()}</a><span class="separator">/</span></li>
                            <li class="breadcrumb-item"><a href="{$service.main_node.url_alias|ezurl(no)}">{$service.name|wash()}</a><span class="separator">/</span></li>
                        {/if}
                        <li class="breadcrumb-item active" aria-current="page">Prenotazione appuntamento</li>
                    </ol>
                </nav>
            </div>
        </div>
    </div>
</div>
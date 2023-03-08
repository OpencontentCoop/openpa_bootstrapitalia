{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}
{ezpagedata_set( 'show_path', false() )}

<div class="container" id="main-container">
    <div class="row">
        <div class="col-12 col-lg-10 offset-lg-1">
            <div class="cmp-breadcrumbs" role="navigation">
                <nav class="breadcrumb-container" aria-label="breadcrumb">
                    <ol class="breadcrumb p-0" data-element="breadcrumb">
                        <li class="breadcrumb-item"><a href="#">Home</a><span class="separator">/</span></li>
                        <li class="breadcrumb-item active" aria-current="page">{openpaini('AccessPage', 'Title', 'Accedi')|wash()}</li>
                    </ol>
                </nav>
            </div>
            <div class="cmp-heading pb-3 pb-lg-4">
                <h1 class="title-xxxlarge">{openpaini('AccessPage', 'Title', 'Accedi')|wash()}</h1>
                <p class="subtitle-small">{openpaini('AccessPage', 'Intro', 'Per accedere al sito e ai suoi servizi, utilizza una delle seguenti modalità.')|wash()}</p>
            </div>
        </div>
    </div>

    <hr class="d-none d-lg-block mt-0 mb-4">

    <div class="row">
        <div class="col-12 col-lg-8 offset-lg-2">

            {if $has_spid_access}
            <div class="cmp-text-button mt-3">
                <h2 class="title-xxlarge mb-0">{openpaini('AccessPage', 'SpidAccess_Title', 'SPID')|wash()}</h2>
                <div class="text-wrapper">
                    <p class="subtitle-small mb-3">{openpaini('AccessPage', 'SpidAccess_Intro', 'Accedi con SPID, il sistema Pubblico di Identità Digitale.')|simpletags|autolink}</p>
                </div>
                <div class="button-wrapper mb-2">
                    <button type="button" class="btn btn-icon btn-re square" href="{$spid_access_link}" onclick="location.href = '{$spid_access_link}';">
                        <img src="{'images/assets/spid.svg'|ezdesign( 'no' )}" alt="{openpaini('AccessPage', 'SpidAccess_ButtonText', 'Entra con SPID')|wash()}" class="me-2">
                        <span class="">{openpaini('AccessPage', 'SpidAccess_ButtonText', 'Entra con SPID')|wash()}</span>
                    </button>
                </div>
                <a class="simple-link" href="{openpaini('AccessPage', 'SpidAccess_HelpLink', 'https://www.spid.gov.it/cos-e-spid/come-attivare-spid/')|wash()}">{openpaini('AccessPage', 'SpidAccess_HelpText', 'Come attivare SPID')|wash()}</a>
            </div>
            {/if}

            {if $has_cie_access}
            <div class="cmp-text-button">
                <h2 class="title-xxlarge mb-0">{openpaini('AccessPage', 'CieAccess_Title', 'CIE')|wash()}</h2>
                <div class="text-wrapper">
                    <p class="subtitle-small mb-3">{openpaini('AccessPage', 'CieAccess_Intro', 'Accedi con la tua Carta d’Identità Elettronica.')|simpletags|autolink}</p>
                </div>
                <div class="button-wrapper mb-2">
                    <button type="button" class="btn btn-icon btn-re square" href="{$cie_access_link}" onclick="location.href = '{$cie_access_link}';">
                        <img src="{'images/assets/cie.svg'|ezdesign( 'no' )}" alt="{openpaini('AccessPage', 'CieAccess_ButtonText', 'Entra con CIE')|wash()} class="me-2">
                        <span class="">{openpaini('AccessPage', 'CieAccess_ButtonText', 'Entra con CIE')|wash()}</span>
                    </button>
                </div>
                <a class="simple-link" href="{openpaini('AccessPage', 'CieAccess_HelpLink', 'https://www.cartaidentita.interno.gov.it/argomenti/richiesta-cie/"')|wash()}">{openpaini('AccessPage', 'CieAccess_HelpText', 'Come richiedere CIE')|wash()}</a>
            </div>
            {/if}

            {if $others|count()}
            <div class="cmp-text-button">
                <h2 class="title-xxlarge mb-0">{openpaini('AccessPage', 'Others_Title', 'Altre utenze')|wash()}</h2>
                <div class="text-wrapper">
                    <p class="subtitle-small mb-3">{openpaini('AccessPage', 'Others_Intro', 'In alternativa puoi utilizzare le seguenti modalità.')|simpletags|autolink}</p>
                </div>
                <div class="button-wrapper d-md-flex">
                    {foreach $others as $item}
                        {if is_set($others_access_links[$item])}
                        <button type="button" href="{$others_access_links[$item]}" onclick="location.href = '{$others_access_links[$item]}';" class="btn btn-outline-primary btn-re pr-md-4 bg-white">
                            <span class="">{openpaini('AccessPage', concat($item, '_Title'), 'Accedi')|wash()}</span>
                        </button>
                        {/if}
                    {/foreach}
                </div>
            </div>
            {/if}

        </div>

    </div>
</div>
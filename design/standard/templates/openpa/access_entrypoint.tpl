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
                        <li class="breadcrumb-item active" aria-current="page">{openpaini('AccessPage', 'Title', 'Sign in')|i18n('bootstrapitalia/signin')|wash()}</li>
                    </ol>
                </nav>
            </div>
            <div class="cmp-heading pb-3 pb-lg-4">
                <h1 class="title-xxxlarge">{openpaini('AccessPage', 'Title', 'Sign in')|i18n('bootstrapitalia/signin')|wash()}</h1>
                <p class="subtitle-small">{openpaini('AccessPage', 'Intro', 'To access the site and its services, use one of the following methods.')|i18n('bootstrapitalia/signin')|wash()}</p>
            </div>
        </div>
    </div>

    <hr class="d-none d-lg-block mt-0 mb-4">

    <div class="row">
        <div class="col-12 col-lg-8 offset-lg-2">

            {if $has_spid_access}
            <div class="cmp-text-button mt-3">
                <h2 class="title-xxlarge mb-0">{$spid_title|wash()}</h2>
                <div class="text-wrapper">
                    <p class="subtitle-small mb-3">{$spid_subtitle|simpletags|autolink}</p>
                </div>
                <div class="button-wrapper mb-2">
                    <button type="button" class="btn btn-icon btn-re square" href="{$spid_access_link}" onclick="location.href = '{$spid_access_link}';">
                        <img src="{'images/assets/spid.svg'|ezdesign( 'no' )}" alt="{$spid_button_text|wash()}" class="me-2">
                        <span class="">{$spid_button_text|wash()}</span>
                    </button>
                </div>
                {if $show_spid_link}
                <a class="simple-link" href="{openpaini('AccessPage', 'SpidAccess_HelpLink', 'https://www.spid.gov.it/cos-e-spid/come-attivare-spid/')|wash()}">{openpaini('AccessPage', 'SpidAccess_HelpText', 'How to activate SPID?')|i18n('bootstrapitalia/signin')|wash()}</a>
                {/if}
            </div>
            {/if}

            {if $has_cie_access}
            <div class="cmp-text-button">
                <h2 class="title-xxlarge mb-0">{openpaini('AccessPage', 'CieAccess_Title', 'CIE')|wash()}</h2>
                <div class="text-wrapper">
                    <p class="subtitle-small mb-3">{openpaini('AccessPage', 'CieAccess_Intro', 'Log in with your Electronic Identity Card.')|i18n('bootstrapitalia/signin')|simpletags|autolink}</p>
                </div>
                <div class="button-wrapper mb-2">
                    <button type="button" class="btn btn-icon btn-re square" href="{$cie_access_link}" onclick="location.href = '{$cie_access_link}';">
                        <img src="{'images/assets/cie.svg'|ezdesign( 'no' )}" alt="{openpaini('AccessPage', 'CieAccess_ButtonText', 'Log in with CIE')|i18n('bootstrapitalia/signin')|wash()} class="me-2">
                        <span class="">{openpaini('AccessPage', 'CieAccess_ButtonText', 'Log in with CIE')|i18n('bootstrapitalia/signin')|wash()}</span>
                    </button>
                </div>
                <a class="simple-link" href="{openpaini('AccessPage', 'CieAccess_HelpLink', 'https://www.cartaidentita.interno.gov.it/argomenti/richiesta-cie/"')|wash()}">{openpaini('AccessPage', 'CieAccess_HelpText', 'How to request CIE?')|i18n('bootstrapitalia/signin')|wash()}</a>
            </div>
            {/if}

            {if $others|count()}
            <div class="cmp-text-button">
                <h2 class="title-xxlarge mb-0">{openpaini('AccessPage', 'Others_Title', 'Other types')|i18n('bootstrapitalia/signin')|wash()}</h2>
                <div class="text-wrapper">
                    <p class="subtitle-small mb-3">{openpaini('AccessPage', 'Others_Intro', 'Alternatively you can use the following methods.')|i18n('bootstrapitalia/signin')|simpletags|autolink}</p>
                </div>
                <div class="button-wrapper d-md-flex">
                    {foreach $others as $item}
                        {if is_set($others_access_links[$item])}
                        <button type="button" href="{$others_access_links[$item]}" onclick="location.href = '{$others_access_links[$item]}';" class="btn btn-outline-primary btn-re pr-md-4 bg-white">
                            <span class="">{openpaini('AccessPage', concat($item, '_Title'), 'Sign in')|i18n('bootstrapitalia/signin')|wash()}</span>
                        </button>
                        {/if}
                    {/foreach}
                </div>
            </div>
            {/if}

        </div>

    </div>
</div>
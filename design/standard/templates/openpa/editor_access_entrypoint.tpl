{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}
{ezpagedata_set( 'show_path', true() )}

<div class="container" id="main-container">
    <div class="row">
        <div class="col-12 col-lg-10 offset-lg-1">
            <div class="cmp-heading pb-3 pb-lg-4">
                <h1 class="title-xxxlarge">{openpaini('AccessPage', 'EditorAccessTitle', 'Access reserved only for staff')|i18n('bootstrapitalia/signin')|wash()}</h1>
                <p class="subtitle-small">{openpaini('AccessPage', 'EditorAccessIntro', '')|i18n('bootstrapitalia/signin')|wash()}</p>
            </div>
        </div>
    </div>

    <hr class="d-none d-lg-block mt-0 mb-4">

    <div class="row">
        <div class="col-12 col-lg-8 offset-lg-2">
            <div class="cmp-text-button">
                <div class="button-wrapper d-md-flex">
                    {foreach $access_list as $item}
                        {if is_set($access_links[$item])}
                            <button type="button" href="{$access_links[$item]}"
                                    onclick="location.href = '{$access_links[$item]}';"
                                    class="btn btn-outline-primary btn-re pr-md-4 bg-white">
                                <span class="">{openpaini('AccessPage', concat($item, '_Title'), 'Sign in')|i18n('bootstrapitalia/signin')|wash()}</span>
                            </button>
                        {/if}
                    {/foreach}
                </div>
            </div>
        </div>
    </div>

</div>
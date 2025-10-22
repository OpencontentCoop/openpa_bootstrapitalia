<div class="modal fade search-modal" id="search-modal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content perfect-scrollbar">
            <div class="modal-body">
                <form action="{'content/search'|ezurl(no)}" method="get">
                        <div class="modal-title">
                            <button class="search-link d-md-none" type="button" data-bs-toggle="modal"
                                    data-bs-target="#search-modal"
                                    aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">
                                <svg class="icon icon-md" role="presentation" focusable="false">
                                    <use href="{'images/svg/sprites.svg'|ezdesign( 'no' )}#it-arrow-left"></use>
                                </svg>
                            </button>
                            <h2>{'Search'|i18n('openpa/search')}</h2>
                            <button class="search-link d-none d-md-block" type="button"
                                    data-bs-toggle="modal"
                                    data-bs-target="#search-modal"
                                    aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">
                                <svg class="icon icon-md" role="presentation" focusable="false">
                                    <use href="{'images/svg/sprites.svg'|ezdesign( 'no' )}#it-close-big"></use>
                                </svg>
                            </button>
                        </div>
                        <div class="form-group autocomplete-wrapper">
                            <label for="main-search-input" class="sr-only">{'Search in all content'|i18n('design/admin/pagelayout')}</label>
                            <input type="search" class="autocomplete ps-5 oc-placeholder" placeholder="{'Search in the site'|i18n( 'bootstrapitalia' )}"
                                   id="main-search-input" name="SearchText" data-bs-autocomplete="[]">
                            <span class="autocomplete-icon" role="presentation" focusable="false">
                                {display_icon('it-search', 'svg', 'icon')}
                            </span>
                            <button type="submit" class="btn btn-primary">
                                <span class="">{'Search'|i18n('openpa/search')}</span>
                            </button>
                        </div>
                        {*<div class="row variable-gutters">
                            <div class="col-lg-5">
                                <div class="searches-list-wrapper">
                                    <div class="other-link-title">FORSE STAVI CERCANDO</div>
                                    <ul class="searches-list" role="list">
                                        <li role="listitem">
                                            <a href="#">Rilascio Carta Identità Elettronica (CIE)</a>
                                        </li>
                                        <li role="listitem">
                                            <a href="#">Cambio di residenza</a>
                                        </li>
                                        <li role="listitem">
                                            <a href="#">Tributi online</a>
                                        </li>
                                        <li role="listitem">
                                            <a href="#">Prenotazione appuntamenti</a>
                                        </li>
                                        <li role="listitem">
                                            <a href="#">Rilascio tessera elettorale</a>
                                        </li>
                                        <li role="listitem">
                                            <a href="#">Voucher connettività</a>
                                        </li>
                                    </ul><!-- /searches-list -->
                                </div><!-- /searches-list-wrapper -->
                            </div>
                        </div>*}
                </form>
            </div>
        </div>
    </div>
</div>

{* https://github.com/blueimp/Gallery vedi atom/gallery.tpl *}
<div id="blueimp-gallery" class="blueimp-gallery blueimp-gallery-controls">
    <div class="slides"></div>
    <h3 class="title"><span class="sr-only">gallery</span></h3>
    <a class="prev" href="#" title="{'Previous'|i18n('design/iphone/full/image')}" aria-label="{'Previous'|i18n('design/iphone/full/image')}">‹</a>
    <a class="next" href="#" title="{'Next'|i18n('design/iphone/full/image')}" aria-label="{'Next'|i18n('design/iphone/full/image')}">›</a>
    <a class="close" href="#" title="{'Close'|i18n('bootstrapitalia')}" aria-label="{'Close'|i18n('bootstrapitalia')}">×</a>
    <a class="play-pause" href="#" title="play/pause" aria-label="play/pause"></a>
    <ol class="indicator"></ol>
</div>

{literal}
    <script>
      $(document).on('shown.bs.modal', '.modal', function() {
        $('#main-search-input').focus();
      });
    </script>
{/literal}
<div class="modal fade search-modal" id="search-modal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content perfect-scrollbar">
            <div class="modal-body">
                <form action="{'content/search'|ezurl(no)}" method="get">
                    <div class="container">
                        <div class="row variable-gutters">
                            <div class="col">
                                <div class="modal-title">
                                    <button class="search-link d-md-none" type="button" data-bs-toggle="modal"
                                            data-bs-target="#search-modal"
                                            aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">
                                        <svg class="icon icon-md">
                                            <use href="{'images/svg/sprites.svg'|ezdesign( 'no' )}#it-arrow-left"></use>
                                        </svg>
                                    </button>
                                    <h2>Cerca</h2>
                                    <button class="search-link d-none d-md-block" type="button"
                                            data-bs-toggle="modal"
                                            data-bs-target="#search-modal"
                                            aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">
                                        <svg class="icon icon-md">
                                            <use href="{'images/svg/sprites.svg'|ezdesign( 'no' )}#it-close-big"></use>
                                        </svg>
                                    </button>
                                </div>
                                <div class="form-group autocomplete-wrapper">
                                    <label for="autocomplete-two" class="visually-hidden">{'Search in all content'|i18n('design/admin/pagelayout')}</label>
                                    <input type="search" class="autocomplete ps-5" placeholder="Cerca nel sito"
                                           id="autocomplete-two" name="SearchText" data-bs-autocomplete="[]">
                                    <span class="autocomplete-icon" aria-hidden="true">
                                        {display_icon('it-search', 'svg', 'icon')}
                                    </span>
                                    <button type="submit" class="btn btn-primary">
                                        <span class="">{'Search'|i18n('openpa/search')}</span>
                                    </button>
                                </div>
                            </div>
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
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

{* https://github.com/blueimp/Gallery vedi atom/gallery.tpl *}
<div id="blueimp-gallery" class="blueimp-gallery blueimp-gallery-controls">
    <div class="slides"></div>
    <h3 class="title"><span class="sr-only">gallery</span></h3>
    <a class="prev">‹</a>
    <a class="next">›</a>
    <a class="close">×</a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
</div>
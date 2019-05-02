<div class="modal fade" tabindex="-1" role="dialog" id="searchModal">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form class="Form" action="{"/content/search"|ezurl(no)}">
                <div class="modal-header-fullsrc">
                    <div class="container">
                        <div class="row">
                            <div class="col-sm-1">
                                <button type="button" class="close h1" aria-label="Chiudi filtri di ricerca" aria-hidden="true" data-dismiss="modal">
                                    <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-arrow-left"></use></svg>
                                </button>
                            </div>
                            <div class="col-sm-11">
                                <h1 class="modal-title" id="searchModalTitle">Cerca</h1>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-body-search">
                    <div class="container">
                        <div class="row" aria-hidden="false">
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="form-group">
                                    <label class="sr-only active">Cerca</label>
                                    <input type="search"
                                           id="cerca-txt"
                                           name="cercatxt"
                                           placeholder="Cerca informazioni, persone, servizi"
                                           aria-label="Cerca informazioni, persone, servizi" />
                                    <svg class="icon ico-prefix"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-search"></use></svg>
                                </div>
                                <div class="form-filtro">
                                    <a href="#" class="btn btn-primary btn-sm btn-filtro" >Tutto</a>
                                    <a href="#" class="btn btn-outline-primary btn-sm btn-filtro"><svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-pa"></use></svg> Amministrazione</a>
                                    <a href="#" class="btn btn-outline-primary btn-sm btn-filtro"><svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-settings"></use></svg> Servizi</a>
                                    <a href="#" class="btn btn-outline-primary btn-sm btn-filtro"><svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-calendar"></use></svg> Novità</a>
                                    <a href="#" class="btn btn-outline-primary btn-sm btn-filtro"><svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-file"></use></svg> Documenti</a>
                                    <a href="#" class="btn btn-outline-primary btn-sm btn-filtro" aria-label="Filtra per categorie">...</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
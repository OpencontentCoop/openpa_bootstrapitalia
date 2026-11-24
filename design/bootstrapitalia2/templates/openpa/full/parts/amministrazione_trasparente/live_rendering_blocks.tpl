{* Rendering live (DataTables lato client) per gli schemi ANAC con un
   fornitore registrato in LiveRenderingRegistry - vedi
   classes/services/content_trasparenza.php, getLiveRenderingBlocks().

   A differenza di children_table_fields.tpl (che usa opendataDataTable,
   un involucro legato per forza alla REST API generica /opendata/api/datatable/search
   - lo stesso percorso che mostra il placeholder "(calculated)" per i campi
   openparole, vedi office_manager), qui si inizializza la libreria DataTables
   standard direttamente, in modalita' client-side (serverSide: false, dati
   gia' in memoria): i dati arrivano gia' calcolati e appiattiti lato PHP
   (responsabile gia' risolto, non il placeholder), incorporati in un blocco
   <script type="application/json"> separato dal blocco di inizializzazione -
   nessun dato, nemmeno quello gia' reso sicuro da toSafeJson()
   (JSON_HEX_TAG/AMP/APOS/QUOT), finisce mai interpolato dentro codice
   JavaScript eseguibile. *}

{def $current_language = ezini('RegionalSettings', 'Locale')}

{* Troncamento con espansione per le colonne "Competenze" (testo libero
   spesso lungo diversi paragrafi, vedi #503) - 3 righe di default via
   line-clamp, bottone "Mostra tutto"/"Mostra meno" per non perdere il dato,
   solo compattarlo. Vedi script sotto per il toggle (delega di evento,
   necessaria perche' DataTables re-crea le celle a ogni pagina/ordinamento). *}
<style>
{literal}
.live-rendering-clamp{display:-webkit-box;-webkit-box-orient:vertical;-webkit-line-clamp:5;overflow:hidden}
.live-rendering-clamp.is-expanded{display:block;-webkit-line-clamp:unset;overflow:visible}
div[id^="live-rendering-"][id$="_wrapper"]{font-size:0.9rem}
table[id^="live-rendering-"] th{white-space:nowrap}
.live-rendering-toggle:focus:not(:focus-visible){box-shadow:none;outline:none}
{/literal}
</style>

{foreach $live_rendering.blocks as $block}
<section class="mt-5 mb-4 anchor-offset">
    {* art.31-oiv/art.31-or: il titolo dello schema ANAC coincide con l'H1
       della pagina stessa (es. "Organismi indipendenti di valutazione...")
       - mostrarlo di nuovo qui sopra la tabella è un doppione visivo,
       segnalato da Federica Taraboi su cms#525. Per gli altri schemi
       (es. art.13-op/art.13-oa) il titolo aggiunge informazione reale
       ("Uffici degli organi di...") e resta. *}
    {if not(or($block.schema|eq('art.31-oiv'), $block.schema|eq('art.31-or')))}
    <h3 class="h4" id="live-rendering-{$block.dom_id}-title">{$block.title|wash()}</h3>
    {/if}
    <script type="application/json" id="live-rendering-{$block.dom_id}-data">{$block.rows_json}</script>
    {if or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
    {* Stesso stile del filtro "Filtra per fase" dei Bandi di gara
       (children_table_fields.tpl): form-group m-0 + form-label p-0 m-0 +
       form-control sul select, invece del form-select "nudo" usato prima -
       richiesto da Marco per uniformita' con le altre pagine di trasparenza. *}
    {* accessible-autocomplete: stessa libreria gia' usata da
       opendata_remote_gui.tpl/ricerca_luoghi.tpl/search_people_by_role.tpl
       (jquery.opendata_remote_gui.js) per i filtri a faccette - richiesto da
       Marco per uniformare i 3 select Tipologia/Ufficio/Anno a quel pattern
       gia' funzionante. ezscript_require/ezcss_require (non un <script>/
       <link> diretto) e' il modo con cui quelle pagine la includono: vanno
       nella cache combinata delle risorse di pagina, non ricaricati/duplicati
       se il blocco si ripete (qui per le due tabelle art.23-org/
       art.23-altra-tipologia sulla stessa pagina "Provvedimenti"). *}
    {ezscript_require(array('accessible-autocomplete.min.js'))}
    {ezcss_require(array('accessible-autocomplete.min.css'))}
    <div class="mb-5">
        <div class="row g-3 mb-3 live-rendering-art23-filters" data-dom-id="{$block.dom_id}">
            <div class="col-md-4">
                <div class="form-group m-0">
                    <label class="form-label p-0 m-0" for="live-rendering-{$block.dom_id}-filter-denominazione">{'Type'|i18n('bootstrapitalia/anac_export')}</label>
                    <select class="form-control" id="live-rendering-{$block.dom_id}-filter-denominazione">
                        <option value="">{'All'|i18n('bootstrapitalia/anac_export')}</option>
                    </select>
                </div>
            </div>
            <div class="col-md-4">
                <div class="form-group m-0">
                    <label class="form-label p-0 m-0" for="live-rendering-{$block.dom_id}-filter-struttura">{'Office'|i18n('bootstrapitalia/anac_export')}</label>
                    <select class="form-control" id="live-rendering-{$block.dom_id}-filter-struttura">
                        <option value="">{'All'|i18n('bootstrapitalia/anac_export')}</option>
                    </select>
                </div>
            </div>
            <div class="col-md-4">
                <div class="form-group m-0">
                    <label class="form-label p-0 m-0" for="live-rendering-{$block.dom_id}-filter-anno">{'Year'|i18n('bootstrapitalia/anac_export')}</label>
                    <select class="form-control" id="live-rendering-{$block.dom_id}-filter-anno">
                        <option value="">{'All'|i18n('bootstrapitalia/anac_export')}</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="row g-3 live-rendering-art23-filters" data-dom-id="{$block.dom_id}">
            <div class="col-md-3">
                <div class="form-group m-0">
                    <label class="form-label p-0 m-0" for="live-rendering-{$block.dom_id}-filter-data-da">{'From'|i18n('bootstrapitalia/anac_export')}</label>
                    <input type="date" class="form-control" id="live-rendering-{$block.dom_id}-filter-data-da">
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group m-0">
                    <label class="form-label p-0 m-0" for="live-rendering-{$block.dom_id}-filter-data-a">{'To'|i18n('bootstrapitalia/anac_export')}</label>
                    <input type="date" class="form-control" id="live-rendering-{$block.dom_id}-filter-data-a">
                </div>
            </div>
        </div>
    </div>
    {/if}
    <table id="live-rendering-{$block.dom_id}-table" class="table table-striped display" style="width:100%">
        <thead>
            {if $block.schema|eq('art.13-rif')}
            <tr>
                <th>{'Name'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Phone'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Email'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Certified email'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
            {elseif or($block.schema|eq('art.31-oiv'), $block.schema|eq('art.31-or'))}
            <tr>
                <th>{'Document type'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Publication date'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Document'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
            {elseif or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
            <tr>
                <th>{'Date'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Act number'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Type'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Subject'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
            {else}
            <tr>
                <th>{'Body'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{$block.column_labels.competenze|wash()} ({'organ'|i18n('bootstrapitalia/anac_export')})</th>
                <th>{'Office'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Type'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{$block.column_labels.competenze|wash()} ({'office'|i18n('bootstrapitalia/anac_export')})</th>
                <th>{$block.column_labels.responsabile|wash()}</th>
                <th>{'Phone'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Email'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
            {/if}
        </thead>
    </table>
</section>
{/foreach}

<script type="text/javascript" language="javascript" class="init">
$(document).ready(function () {ldelim}
    function readEmbeddedRows(elementId) {ldelim}
        var el = document.getElementById(elementId);
        if (!el) {ldelim} return []; {rdelim}
        try {ldelim}
            return JSON.parse(el.textContent);
        {rdelim} catch (e) {ldelim}
            return [];
        {rdelim}
    {rdelim}

    var datatableLanguageUrl = "{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}";

    var TRUNCATABLE_TEXT_THRESHOLD = 200;

    function renderTruncatableText(data, type) {ldelim}
        if (type !== 'display') {ldelim} return data; {rdelim}
        var textDiv = document.createElement('div');
        textDiv.textContent = data;
        if (!data || data.length <= TRUNCATABLE_TEXT_THRESHOLD) {ldelim}
            return textDiv.innerHTML;
        {rdelim}
        return '<div class="live-rendering-clamp">' + textDiv.innerHTML + '</div>' +
            '<button type="button" class="btn btn-link btn-xs p-0 text-decoration-underline live-rendering-toggle">' +
            "{'Show all'|i18n('bootstrapitalia/anac_export')|wash()}" +
            '</button>';
    {rdelim}

    $(document).on('click', '.live-rendering-toggle', function () {ldelim}
        var $button = $(this);
        var $text = $button.prev('.live-rendering-clamp');
        var expanded = $text.toggleClass('is-expanded').hasClass('is-expanded');
        $button.text(expanded
            ? "{'Show less'|i18n('bootstrapitalia/anac_export')|wash()}"
            : "{'Show all'|i18n('bootstrapitalia/anac_export')|wash()}");
    {rdelim});

    {foreach $live_rendering.blocks as $block}
    $('#live-rendering-{$block.dom_id}-table').DataTable({ldelim}
        data: readEmbeddedRows('live-rendering-{$block.dom_id}-data'),
        serverSide: false,
        scrollX: true,
        pageLength: 10,
        lengthMenu: [10, 20, 25, 50, 100],
        language: {ldelim} url: datatableLanguageUrl {rdelim},
        drawCallback: function () {ldelim}
            var pages = this.api().page.info().pages;
            var $paginate = $(this.api().table().container()).find('.dataTables_paginate');
            $paginate.toggle(pages > 1);
            // DataTables marca la pagina corrente con la classe Bootstrap
            // ".page-item.active", ma il CSS di Bootstrap Italia (piu'
            // specifico: ".pagination .page-item .page-link", 3 classi
            // contro le 2 di ".page-item.active .page-link") la sovrascrive
            // e stila invece in base all'attributo aria-current sul
            // <a class="page-link"> - senza impostarlo la pagina corrente
            // non si distingue affatto dalle altre (segnalato da Marco,
            // capita su ogni tabella live-rendering, non solo art.23).
            $paginate.find('.page-link').removeAttr('aria-current');
            $paginate.find('.page-item.active .page-link').attr('aria-current', 'page');
        {rdelim},
        {if $block.schema|eq('art.13-rif')}
        columns: [
            {ldelim} data: 'denominazione' {rdelim},
            {ldelim} data: 'telefono' {rdelim},
            {ldelim} data: 'email' {rdelim},
            {ldelim} data: 'pec' {rdelim}
        ]
        {elseif or($block.schema|eq('art.31-oiv'), $block.schema|eq('art.31-or'))}
        columns: [
            {ldelim} data: 'tipo' {rdelim},
            {ldelim} data: 'data' {rdelim},
            {ldelim} data: 'documento', render: function (data, type, row) {ldelim}
                if (type !== 'display' || !row.url) {ldelim} return data; {rdelim}
                var div = document.createElement('div');
                div.textContent = data;
                var a = document.createElement('a');
                a.href = row.url;
                a.innerHTML = div.innerHTML;
                return a.outerHTML;
            {rdelim} {rdelim}
        ]
        {elseif or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
        columns: [
            {ldelim} data: 'data', render: function (data, type, row) {ldelim}
                if (type === 'sort' || type === 'type') {ldelim} return row.dataTimestamp || 0; {rdelim}
                return data;
            {rdelim} {rdelim},
            {ldelim} data: 'numero' {rdelim},
            {ldelim} data: 'denominazione' {rdelim},
            {ldelim} data: 'oggetto', render: function (data, type, row) {ldelim}
                if (type !== 'display' || !row.url) {ldelim} return data; {rdelim}
                var div = document.createElement('div');
                div.textContent = data;
                var a = document.createElement('a');
                a.href = row.url;
                a.innerHTML = div.innerHTML;
                return a.outerHTML;
            {rdelim} {rdelim},
            {ldelim} data: 'strutturaResponsabile' {rdelim}
        ],
        order: [[0, 'desc']]
        {else}
        columns: [
            {ldelim} data: 'organo' {rdelim},
            {ldelim} data: 'competenzeOrgano', render: renderTruncatableText {rdelim},
            {ldelim} data: 'denominazione', render: function (data, type, row) {ldelim}
                if (type !== 'display' || !row.url) {ldelim} return data; {rdelim}
                var div = document.createElement('div');
                div.textContent = data;
                var a = document.createElement('a');
                a.href = row.url;
                a.innerHTML = div.innerHTML;
                return a.outerHTML;
            {rdelim} {rdelim},
            {ldelim} data: 'tipologia' {rdelim},
            {ldelim} data: 'competenze', render: renderTruncatableText {rdelim},
            {ldelim} data: 'nominativo' {rdelim},
            {ldelim} data: 'telefono' {rdelim},
            {ldelim} data: 'email' {rdelim}
        ]
        {/if}
    {rdelim});
    {/foreach}

    var art23PeriodoInputs = {ldelim}{rdelim};
    var art23AnnoFilters = {ldelim}{rdelim};
    var art23StrutturaFilters = {ldelim}{rdelim};

    $.fn.dataTable.ext.search.push(function (settings, searchData, index, rowData) {ldelim}
        var tableId = settings.nTable.id;

        var anno = art23AnnoFilters[tableId];
        if (anno && String(rowData.anno) !== anno) {ldelim} return false; {rdelim}

        // Filtro per id di organizzazione (non sulla stringa visualizzata
        // strutturaResponsabile): un documento con piu' organizzazioni
        // collegate deve comparire filtrando per UNA SOLA di esse - trovato
        // dalla review finale whole-branch (spec §2.1, unitaOrganizzativaId).
        var strutturaId = art23StrutturaFilters[tableId];
        if (strutturaId) {ldelim}
            var organizzazioni = rowData.organizzazioni || [];
            var match = organizzazioni.some(function (org) {ldelim}
                return String(org.id) === strutturaId;
            {rdelim});
            if (!match) {ldelim} return false; {rdelim}
        {rdelim}

        var range = art23PeriodoInputs[tableId];
        if (range) {ldelim}
            var fromValue = range.from.val();
            var toValue = range.to.val();
            if (fromValue || toValue) {ldelim}
                var from = fromValue ? (new Date(fromValue)).getTime() / 1000 : null;
                var to = toValue ? ((new Date(toValue)).getTime() / 1000 + 86399) : null;
                // Stessa data mostrata in colonna "Data" (act_date/data_di_firma,
                // con fallback a publication_start_time solo se le prime due
                // mancano - vedi PageProvvedimentiProvider::flattenRows()), non
                // la finestra di pubblicazione del Documento: altrimenti una riga
                // con "Data" fuori dall'intervallo scelto compariva comunque,
                // confondendo chi usa il filtro (richiesto da Marco).
                var data = rowData.dataTimestamp || 0;
                if (from !== null && data < from) {ldelim} return false; {rdelim}
                if (to !== null && data > to) {ldelim} return false; {rdelim}
            {rdelim}
        {rdelim}

        return true;
    {rdelim});

    function populateArt23Filter($select, rows, field) {ldelim}
        var values = [];
        rows.forEach(function (row) {ldelim}
            if (row[field] && values.indexOf(row[field]) === -1) {ldelim} values.push(row[field]); {rdelim}
        {rdelim});
        values.sort();
        values.forEach(function (value) {ldelim}
            $select.append($('<option></option>').attr('value', value).text(value));
        {rdelim});
    {rdelim}

    // A differenza di populateArt23Filter() (un valore testuale per riga),
    // 'organizzazioni' e' un array per riga (un documento puo' avere piu'
    // organizzazioni collegate) - dedup per id, non per nome (due
    // organizzazioni con lo stesso nome in rami diversi dell'albero
    // resterebbero comunque due filtri distinti).
    function populateArt23OrganizzazioniFilter($select, rows) {ldelim}
        var byId = {ldelim}{rdelim};
        rows.forEach(function (row) {ldelim}
            (row.organizzazioni || []).forEach(function (org) {ldelim}
                byId[org.id] = org.nome;
            {rdelim});
        {rdelim});
        Object.keys(byId).sort(function (a, b) {ldelim}
            return byId[a].localeCompare(byId[b]);
        {rdelim}).forEach(function (id) {ldelim}
            $select.append($('<option></option>').attr('value', id).text(byId[id]));
        {rdelim});
    {rdelim}

    // Uniforma lo stile dei 3 filtri a tendina (Tipologia/Ufficio/Anno) a
    // quello del filtro data (campo testuale, non un <select> nativo) e
    // aggiunge la digitazione per filtrare - richiesto da Marco, utile
    // soprattutto per "Ufficio" su enti con molte unita' organizzative.
    // Stessa configurazione di jquery.opendata_remote_gui.js (filtri a
    // faccette di opendata_remote_gui.tpl/ricerca_luoghi.tpl/
    // search_people_by_role.tpl, l'uso gia' funzionante di questa libreria
    // nel progetto): displayMenu 'overlay' (il menu va in overlay sul resto
    // della pagina invece di spingerlo in basso), dropdownArrow disabilitata,
    // autoselect false. Niente preserveNullOptions (default libreria, non
    // impostato nemmeno da jquery.opendata_remote_gui.js): "Tutti" non
    // compare tra i suggerimenti, sarebbe ridondante con il campo vuoto
    // (gia' di per se' "nessun filtro" = "Tutti") - richiesto da Marco.
    // enhanceSelectElement() va chiamato DOPO aver popolato le <option>
    // (legge lo stato del <select> in quel momento) e rinomina l'id del
    // <select> originale in "<id>-select", nascondendolo - l'handler jQuery
    // gia' agganciato sotto per 'change' resta valido perche' e' legato al
    // nodo DOM, non all'id. onConfirm: stesso pattern di
    // jquery.opendata_remote_gui.js (query vuota => opzione con value vuoto,
    // cioe' "Tutti", che qui esiste davvero in markup anche se non e' tra i
    // suggerimenti) ma con trigger('change') esplicito al posto della
    // chiamata diretta a runSearch() del widget faccette - serve perche' il
    // default della libreria imposta solo `option.selected = true` SENZA
    // sparare alcun evento 'change' (mai dispatchato su una modifica fatta
    // da JS): senza il trigger() i filtri smetterebbero di funzionare
    // scegliendo un valore dall'autocomplete.
    function enhanceArt23Select($select) {ldelim}
        var select = $select.get(0);
        accessibleAutocomplete.enhanceSelectElement({ldelim}
            selectElement: select,
            showAllValues: true,
            autoselect: false,
            displayMenu: 'overlay',
            dropdownArrow: function () {ldelim} return null; {rdelim},
            defaultValue: '',
            onConfirm: function (query) {ldelim}
                var requestedOption;
                if (query) {ldelim}
                    requestedOption = [].filter.call(select.options, function (option) {ldelim}
                        return (option.textContent || option.innerText) === query;
                    {rdelim})[0];
                {rdelim} else {ldelim}
                    requestedOption = [].filter.call(select.options, function (option) {ldelim}
                        return option.value === '';
                    {rdelim})[0];
                {rdelim}
                if (requestedOption) {ldelim}
                    requestedOption.selected = true;
                    $select.trigger('change');
                {rdelim}
            {rdelim}
        {rdelim});
    {rdelim}

    {foreach $live_rendering.blocks as $block}
    {if or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
    (function () {ldelim}
        var domId = '{$block.dom_id}';
        var rows = readEmbeddedRows('live-rendering-' + domId + '-data');
        var table = $('#live-rendering-' + domId + '-table').DataTable();
        var tableId = 'live-rendering-' + domId + '-table';

        populateArt23Filter($('#live-rendering-' + domId + '-filter-denominazione'), rows, 'denominazione');
        populateArt23OrganizzazioniFilter($('#live-rendering-' + domId + '-filter-struttura'), rows);
        populateArt23Filter($('#live-rendering-' + domId + '-filter-anno'), rows, 'anno');

        $('#live-rendering-' + domId + '-filter-denominazione').on('change', function () {ldelim}
            table.column(2).search(this.value ? '^' + $.fn.dataTable.util.escapeRegex(this.value) + '$' : '', true, false).draw();
        {rdelim});
        $('#live-rendering-' + domId + '-filter-struttura').on('change', function () {ldelim}
            art23StrutturaFilters[tableId] = this.value || null;
            table.draw();
        {rdelim});
        $('#live-rendering-' + domId + '-filter-anno').on('change', function () {ldelim}
            art23AnnoFilters[tableId] = this.value || null;
            table.draw();
        {rdelim});

        enhanceArt23Select($('#live-rendering-' + domId + '-filter-denominazione'));
        enhanceArt23Select($('#live-rendering-' + domId + '-filter-struttura'));
        enhanceArt23Select($('#live-rendering-' + domId + '-filter-anno'));

        art23PeriodoInputs[tableId] = {ldelim}
            from: $('#live-rendering-' + domId + '-filter-data-da'),
            to: $('#live-rendering-' + domId + '-filter-data-a')
        {rdelim};
        $('#live-rendering-' + domId + '-filter-data-da, #live-rendering-' + domId + '-filter-data-a').on('change', function () {ldelim}
            table.draw();
        {rdelim});
    {rdelim})();
    {/if}
    {/foreach}
{rdelim});
</script>

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
    <h3 class="h4" id="live-rendering-{$block.dom_id}-title">{$block.title|wash()}</h3>
    <script type="application/json" id="live-rendering-{$block.dom_id}-data">{$block.rows_json}</script>
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
            $(this.api().table().container()).find('.dataTables_paginate').toggle(pages > 1);
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
{rdelim});
</script>

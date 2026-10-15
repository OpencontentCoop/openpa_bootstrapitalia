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

{foreach $live_rendering.blocks as $block}
<section class="mt-5">
    <h3 class="h4">{$block.title|wash()}</h3>
    <script type="application/json" id="live-rendering-{$block.dom_id}-data">{$block.rows_json}</script>
    <table id="live-rendering-{$block.dom_id}-table" class="table table-striped display responsive no-wrap" style="width:100%">
        <thead>
            <tr>
                <th>{'Body'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Body competencies'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office'|i18n('bootstrapitalia/anac_export')}</th>
                {if $block.schema|eq('art.13-oa')}
                <th>{'Type'|i18n('bootstrapitalia/anac_export')}</th>
                {/if}
                <th>{'Office competencies'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Manager'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Phone'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Email'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
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

    {foreach $live_rendering.blocks as $block}
    $('#live-rendering-{$block.dom_id}-table').DataTable({ldelim}
        data: readEmbeddedRows('live-rendering-{$block.dom_id}-data'),
        serverSide: false,
        responsive: true,
        language: {ldelim} url: datatableLanguageUrl {rdelim},
        columns: [
            {ldelim} data: 'organo' {rdelim},
            {ldelim} data: 'competenzeOrgano' {rdelim},
            {ldelim} data: 'denominazione' {rdelim},
            {if $block.schema|eq('art.13-oa')}
            {ldelim} data: 'tipologia' {rdelim},
            {/if}
            {ldelim} data: 'competenze' {rdelim},
            {ldelim} data: 'nominativo' {rdelim},
            {ldelim} data: 'telefono' {rdelim},
            {ldelim} data: 'email' {rdelim}
        ]
    {rdelim});
    {/foreach}
{rdelim});
</script>

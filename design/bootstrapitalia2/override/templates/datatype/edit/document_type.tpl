{* Prototipo: avviso discreto per il redattore quando il "Tipo di documento"
   selezionato corrisponde a un tag che fa comparire il documento in
   Amministrazione Trasparente/Societa' trasparente - rendering live
   (OIV/Organi di revisione, vedi classes/anac/Serializer/Art31Serializer.php,
   TAG_REMOTE_ID_TO_KEY) o tabella dichiarativa (Provvedimenti dirigenti/
   Provvedimenti organi indirizzo politico, vedi
   installer/modules/trasparenza-c1/contenttrees/.../Provvedimenti-*.yml).

   Lista mantenuta in openpa.ini [Trasparenza] DocumentTypeTrasparenzaHintTagRemoteIds[]
   (non letta da fields/schema_pubblicazione): va aggiornata a mano se
   cambiano le pagine trasparenza che filtrano per document_type. *}

{include uri='design:content/datatype/edit/eztags.tpl'}

{* Mostrato solo se il modulo trasparenza risulta installato su questo
   tenant (altrimenti nessuno di questi tag porterebbe mai a una pagina
   trasparenza reale, e l'avviso sarebbe solo rumore) - verificato
   controllando l'esistenza della radice C1 o C2, stesso principio gia'
   usato dal cron ANAC per sapere se un modulo e' installato
   (eZContentObject::fetchByRemoteID() su un oggetto radice noto, vedi
   cronjobs/anac_export.php). *}
{def $trasparenza_c1_root = fetch('content', 'object', hash('remote_id', '5399ef12f98766b90f1804e5d52afd75'))}
{def $trasparenza_c2_root = fetch('content', 'object', hash('remote_id', 't_c2_root'))}

{if or(is_object($trasparenza_c1_root), is_object($trasparenza_c2_root))}

{def $trasparenza_hint_tag_remote_ids = openpaini('Trasparenza', 'DocumentTypeTrasparenzaHintTagRemoteIds', array())}
{def $trasparenza_hint_tag_ids = array()}
{foreach $trasparenza_hint_tag_remote_ids as $remote_id}
    {def $trasparenza_hint_tag = fetch(tags, tag_by_remote_id, hash('remote_id', $remote_id))}
    {if is_object($trasparenza_hint_tag)}
        {set $trasparenza_hint_tag_ids = $trasparenza_hint_tag_ids|append($trasparenza_hint_tag.id)}
    {/if}
    {undef $trasparenza_hint_tag}
{/foreach}

{* Stesso stile gia' in uso in questa UI per gli altri avvisi contestuali
   su un campo (vedi content/edit_attribute.tpl, "Anac attribute update
   alert"/"Anac cig attribute alert") - un box "alert" generico non e'
   stilizzato da questa interfaccia (look non curato, vedi screenshot di
   Marco), questo paragrafo si'. *}
<p id="document-type-trasparenza-hint-{$attribute.id}" class="text-muted small mt-3" style="display:none">
    <em>{'The selected document type causes this document to be automatically published in the transparency section of the site.'|i18n('bootstrapitalia')}</em>
</p>

<script type="text/javascript">
(function () {ldelim}
    // Non ci si affida agli eventi custom del widget eztags
    // (add:after/remove:after): il builder "tree" usato da questa UI
    // (jquery.eztags.tree.js) non li innesca in modo affidabile per ogni
    // interazione (verificato: la rimozione di un tag tramite il tasto "x"
    // del chip non li emette). L'input nascosto `.tagids` invece viene
    // sempre tenuto aggiornato dal widget con l'elenco corrente degli id
    // selezionati (separatore '|#') qualunque sia il builder - polling
    // leggero su quel valore, affidabile indipendentemente
    // dall'implementazione JS interna del widget.
    var hintTagIds = JSON.parse('{$trasparenza_hint_tag_ids|json_encode()}').map(function (id) {ldelim} return parseInt(id, 10); {rdelim});
    var $hiddenIds = $('#eztags{$attribute.id}').find('.tagids');
    var $hint = $('#document-type-trasparenza-hint-{$attribute.id}');
    var lastValue = null;

    function checkHint() {ldelim}
        var raw = $hiddenIds.val() || '';
        if (raw === lastValue) {ldelim} return; {rdelim}
        lastValue = raw;
        var ids = raw.split('|#').filter(function (s) {ldelim} return s !== ''; {rdelim}).map(function (id) {ldelim} return parseInt(id, 10); {rdelim});
        var match = ids.some(function (id) {ldelim} return hintTagIds.indexOf(id) !== -1; {rdelim});
        $hint.toggle(match);
    {rdelim}

    checkHint();
    setInterval(checkHint, 400);
{rdelim})();
</script>

{/if}

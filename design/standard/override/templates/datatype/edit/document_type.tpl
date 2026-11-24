{* Override richiamato da settings/override.ini.append.php [datatype_edit_document_type]
   (classe document, attributo document_type). Fallback per i design che non
   hanno una propria personalizzazione: si usa il widget eztags standard.
   La versione con l'avviso trasparenza e' in design/bootstrapitalia2. *}
{include uri='design:content/datatype/edit/eztags.tpl'}

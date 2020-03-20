## Blocco Eventi (sorgente esterna)
Il blocco permette di visualizzare gli eventi di un OpenAgenda in un calendario fullcalendar.

Per configurarlo sono necessari due valori:
 - **Url del sito remoto**: è il dominio dal quale è raggiungibile l'OpenAgenda da embeddare, il valore è necessario in quanto al click sull'evento del calendario, l'utente viene redirezionato a OpenAgenda
 *ad esempio: https://openagenda.openpa.opencontent.io/*
 - **Url api sorgente (in formato JSON Fullcalendar https://fullcalendar.io/docs/events-json-feed)**: è il link alle api in formato fullcalendar presenti nei sistemi openpa.
 *ad esempio: https://www.comune.ala.tn.it/eventi/opendata/api/fullcalendar/search/?q=+classes+[event]+and+subtree+[16420]+and+state+in+[moderation.skipped,moderation.accepted]+sort+[from_time=>asc]* 
 Al momento non c'è ancora un modo veloce per conoscere il link corretto: è necessario copiare la chiamata XHR che viene effettuata su openagenda per caricare i contentuti nel formato a calendario e incollarla senza le GET start e end
 Quindi se la chiamata XHR è `https://openagenda.openpa.opencontent.io/opendata/api/calendar/search/?q=classes [event] and raw[ezf_df_tag_ids] in [20] and subtree [65] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc]&start=2020-02-24T00:00:00+01:00&end=2020-04-06T00:00:00+02:00`
 il link da copiare sarà `https://openagenda.openpa.opencontent.io/opendata/api/calendar/search/?q=classes [event] and raw[ezf_df_tag_ids] in [20] and subtree [65] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc]`
 
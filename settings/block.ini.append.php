<?php /*

[PushToBlock]
ContentClasses[]
ContentClasses[]=pagina_sito
ContentClasses[]=homepage
ContentClasses[]=topic
RootSubtree=1

[General]
AllowedTypes[]
AllowedTypes[]=Singolo
AllowedTypes[]=ListaAutomatica
AllowedTypes[]=ListaManuale
AllowedTypes[]=Eventi
AllowedTypes[]=GMapItems
AllowedTypes[]=AreaRiservata
AllowedTypes[]=Argomenti
AllowedTypes[]=ListaPaginata
AllowedTypes[]=RicercaDocumenti
AllowedTypes[]=RicercaLuoghi
AllowedTypes[]=HTML
AllowedTypes[]=EventiRemoti
AllowedTypes[]=OpendataRemoteContents
AllowedTypes[]=Ricerca
AllowedTypes[]=OpendataQueriedContents

[Singolo]
Name=Oggetto singolo
NumberOfValidItems=1
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
ViewList[]
ViewList[]=default
ViewList[]=alt
#ViewList[]=card
ViewList[]=card_image
#ViewList[]=card_children
ViewList[]=evidence
ViewList[]=image
ViewName[]
ViewName[default]=Default
ViewName[alt]=Testo più grande
ViewName[card_image]=Card (solo immagine)
ViewName[evidence]=In evidenza
ViewName[image]=Immagine decorativa
#ViewName[card]=Card
#ViewName[card_children]=Card (ultimi 4 contenuti)
ItemsPerRow[]
ContainerStyle[]
#ContainerStyle[card]=py-5
#ContainerStyle[card_children]=py-5
Wide[]
Wide[]=card_image
Wide[]=evidence
Wide[]=image
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[ListaAutomatica]
Name=Lista automatica
NumberOfValidItems=1
NumberOfArchivedItems=0
CustomAttributes[]
CustomAttributes[]=node_id
UseBrowseMode[node_id]=true
CustomAttributes[]=limite
CustomAttributes[]=elementi_per_riga
CustomAttributes[]=includi_classi
CustomAttributes[]=escludi_classi
CustomAttributes[]=ordinamento
CustomAttributes[]=livello_profondita
CustomAttributes[]=state_id
CustomAttributes[]=topic_node_id
CustomAttributes[]=tags
CustomAttributeNames[]
CustomAttributeNames[livello_profondita]=Livello di profondità nell'alberatura
CustomAttributeNames[limite]=Numero di elementi
CustomAttributeNames[elementi_per_riga]=Elementi per riga
CustomAttributeNames[includi_classi]=Tipologie di contenuto da includere
CustomAttributeNames[escludi_classi]=Tipologie di contenuto da escludere (alternativo rispetto al precedente)
CustomAttributeNames[ordinamento]=Ordina per
CustomAttributeNames[state_id]=Stato
CustomAttributeNames[topic_node_id]=Argomenti
CustomAttributeNames[tags]=Percorsi tag
CustomAttributeTypes[elementi_per_riga]=select
CustomAttributeSelection_elementi_per_riga[]
CustomAttributeSelection_elementi_per_riga[unset]=Non specificato
CustomAttributeSelection_elementi_per_riga[2]=2
CustomAttributeSelection_elementi_per_riga[3]=3
CustomAttributeSelection_elementi_per_riga[4]=4
CustomAttributeSelection_elementi_per_riga[6]=6
CustomAttributeSelection_elementi_per_riga[auto]=Masonry
CustomAttributeTypes[ordinamento]=select
CustomAttributeTypes[includi_classi]=class_select
CustomAttributeTypes[escludi_classi]=class_select
CustomAttributeSelection_ordinamento[]
CustomAttributeSelection_ordinamento[name]=Titolo ascendente
CustomAttributeSelection_ordinamento[pubblicato]=Data di pubblicazione discendente
CustomAttributeSelection_ordinamento[modificato]=Data di ultima modifica discendente
CustomAttributeSelection_ordinamento[priority]=Priorità del nodo discendente
CustomAttributeTypes[state_id]=state_select
CustomAttributeTypes[topic_node_id]=topic_select
CustomAttributeTypes[tags]=tag_tree_select
ManualAddingOfItems=disabled
ViewList[]
ViewList[]=lista_card
ViewList[]=lista_card_alt
ViewList[]=lista_card_image
ViewList[]=lista_card_children
ViewList[]=lista_accordion
ViewList[]=lista_banner
ViewList[]=lista_banner_color
#ViewList[]=lista_carousel
ViewName[]
ViewName[lista_card]=Card
ViewName[lista_card_alt]=Card (alternativa)
ViewName[lista_card_image]=Card (solo immagine)
ViewName[lista_card_children]=Card (ultimi 4 contenuti)
ViewName[lista_accordion]=Accordion
ViewName[lista_banner]=Banner
ViewName[lista_banner_color]=Banner (colorati)
#ViewName[lista_carousel]=Carousel
TTL=3600
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[lista_card]=py-5
ContainerStyle[lista_card_alt]=py-5
ContainerStyle[lista_card_image]=py-5
ContainerStyle[lista_card_children]=py-5
ContainerStyle[lista_accordion]=py-5
ContainerStyle[lista_banner]=py-5
ContainerStyle[lista_banner_color]=py-5
ContainerStyle[lista_carousel]=py-5
CanAddShowAllLink=enabled
CanAddIntroText=enabled

[ListaManuale]
Name=Lista manuale
NumberOfValidItems=15
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
CustomAttributes[]
CustomAttributes[]=elementi_per_riga
CustomAttributeNames[]
CustomAttributeNames[elementi_per_riga]=Elementi per riga
CustomAttributeTypes[elementi_per_riga]=select
CustomAttributeSelection_elementi_per_riga[]
CustomAttributeSelection_elementi_per_riga[unset]=Non specificato
CustomAttributeSelection_elementi_per_riga[2]=2
CustomAttributeSelection_elementi_per_riga[3]=3
CustomAttributeSelection_elementi_per_riga[4]=4
CustomAttributeSelection_elementi_per_riga[6]=6
CustomAttributeSelection_elementi_per_riga[auto]=Masonry
ViewList[]
ViewList[]=lista_card
ViewList[]=lista_card_alt
ViewList[]=lista_card_image
ViewList[]=lista_card_children
ViewList[]=lista_accordion
ViewList[]=lista_banner
ViewList[]=lista_banner_color
#ViewList[]=lista_carousel
ViewName[]
ViewName[lista_card]=Card
ViewName[lista_card_alt]=Card (alternativa)
ViewName[lista_card_image]=Card (solo immagine)
ViewName[lista_card_children]=Card (ultimi 4 contenuti)
ViewName[lista_accordion]=Accordion
ViewName[lista_banner]=Banner
ViewName[lista_banner_color]=Banner (colorati)
#ViewName[lista_carousel]=Carousel
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[lista_card]=py-5
ContainerStyle[lista_card_alt]=py-5
ContainerStyle[lista_card_image]=py-5
ContainerStyle[lista_card_children]=py-5
ContainerStyle[lista_accordion]=py-5
ContainerStyle[lista_banner]=py-5
ContainerStyle[lista_banner_color]=py-5
ContainerStyle[lista_carousel]=py-5
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[Eventi]
Name=Eventi
NumberOfValidItems=3
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
CustomAttributes[]
CustomAttributes[]=includi_classi
CustomAttributes[]=show_facets
CustomAttributes[]=topic_node_id
CustomAttributes[]=size
CustomAttributes[]=calendar_view
CustomAttributes[]=max_events
CustomAttributeNames[]
CustomAttributeNames[includi_classi]=Tipologie di contenuto da includere
CustomAttributeNames[show_facets]=Mostra faccette per tipologie selezionate
CustomAttributeNames[topic_node_id]=Argomenti
CustomAttributeNames[size]=Ingombro
CustomAttributeNames[calendar_view]=Visualizzazione
CustomAttributeNames[max_events]=Numero massimo di eventi per giorno
CustomAttributeTypes[]
CustomAttributeTypes[includi_classi]=class_select
CustomAttributeTypes[show_facets]=checkbox
CustomAttributeTypes[topic_node_id]=topic_select
CustomAttributeTypes[size]=select
CustomAttributeSelection_size[small]=Piccolo
CustomAttributeSelection_size[medium]=Medio
CustomAttributeSelection_size[big]=Grande
CustomAttributeTypes[calendar_view]=select
CustomAttributeSelection_calendar_view[day_grid_4]=4 giorni
CustomAttributeSelection_calendar_view[day_grid]=Settimana
CustomAttributeSelection_calendar_view[month]=Mese
ViewList[]
ViewList[]=default
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[default]=py-5
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[EventiRemoti]
Name=Eventi (sorgente esterna)
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=remote_url
CustomAttributes[]=api_url
CustomAttributes[]=size
CustomAttributes[]=calendar_view
CustomAttributeNames[]
CustomAttributeNames[remote_url]=Url del sito remoto
CustomAttributeNames[api_url]=Url api sorgente (in formato JSON Fullcalendar https://fullcalendar.io/docs/events-json-feed)
CustomAttributeNames[size]=Ingombro
CustomAttributeNames[calendar_view]=Visualizzazione
CustomAttributeTypes[]
CustomAttributeTypes[size]=select
CustomAttributeSelection_size[small]=Piccolo
CustomAttributeSelection_size[medium]=Medio
CustomAttributeSelection_size[big]=Grande
CustomAttributeTypes[calendar_view]=select
CustomAttributeSelection_calendar_view[day_grid_4]=4 giorni
CustomAttributeSelection_calendar_view[day_grid]=Settimana
CustomAttributeSelection_calendar_view[month]=Mese
ViewList[]
ViewList[]=default
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[default]=py-5
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[GMapItems]
Name=Mappa
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=parent_node_id
CustomAttributes[]=class
CustomAttributes[]=attribute
CustomAttributes[]=limit
CustomAttributes[]=width
CustomAttributes[]=height
UseBrowseMode[parent_node_id]=true
ViewList[]
ViewList[]=geo_located_content_osm
ViewList[]=map_nolist
ViewList[]=map_wide
ViewName[]
ViewName[geo_located_content_osm]=Mappa (OpenStreetMap)
ViewName[map_nolist]=Mappa senza lista (OpenStreetMap)
ViewName[map_wide]=Mappa wide (OpenStreetMap)
ItemsPerRow[]
ItemsPerRow[map_wide]=1
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[AreaRiservata]
Name=Accesso Area Riservata
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=parent_node_id
CustomAttributes[]=testo
CustomAttributes[]=signin
CustomAttributeTypes[testo]=text
CustomAttributeTypes[signin]=checkbox
UseBrowseMode[parent_node_id]=true
ViewList[]
ViewList[]=accesso_area_riservata
ViewName[]
ViewName[accesso_area_riservata]=Accesso area riservata
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[HTML]
Name=Codice HTML
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=html
CustomAttributeTypes[html]=text
CustomAttributeNames[html]=HTML code (With great power comes great responsibility)
ViewList[]
ViewList[]=html
ViewList[]=html_wide
ViewName[html]=html
ViewName[html_wide]=html wide
ItemsPerRow[]
ItemsPerRow[html_wide]=1
Wide[]
Wide[]=html_wide
CanAddShowAllLink=disabled
CanAddIntroText=disabled

[Html3Colonne]
Name=Codice HTML in 3 colonne
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=htmlCol1
CustomAttributes[]=htmlCol2
CustomAttributes[]=htmlCol3
CustomAttributeTypes[htmlCol1]=text
CustomAttributeTypes[htmlCol2]=text
CustomAttributeTypes[htmlCol3]=text
ViewList[]
ViewList[]=html_3_colonne
ViewName[html_3_colonne]=html
CanAddShowAllLink=disabled
CanAddIntroText=disabled

[Argomenti]
Name=Argomenti
NumberOfValidItems=15
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
CustomAttributes[]
CustomAttributes[]=image
CustomAttributes[]=exclude_classes
UseBrowseMode[image]=true
CustomAttributeNames[image]=Immagine di sfondo
CustomAttributeNames[exclude_classes]=Tipologie di contenuto da escludere
CustomAttributeTypes[]
CustomAttributeTypes[exclude_classes]=class_select
ViewList[]
ViewList[]=lista_card
ViewName[]
ViewName[lista_card]=Default
ItemsPerRow[]
Wide[]
Wide[]=lista_card
CanAddShowAllLink=disabled
CanAddIntroText=disabled

[ListaPaginata]
Name=Lista paginata
NumberOfValidItems=1
NumberOfArchivedItems=0
CustomAttributes[]
CustomAttributes[]=node_id
UseBrowseMode[node_id]=true
CustomAttributes[]=limite
CustomAttributes[]=elementi_per_riga
CustomAttributes[]=includi_classi
CustomAttributes[]=ordinamento
CustomAttributes[]=state_id
CustomAttributes[]=topic_node_id
CustomAttributes[]=tags
CustomAttributeNames[]
CustomAttributeNames[limite]=Numero di elementi per pagina
CustomAttributeNames[includi_classi]=Tipologie di contenuto da includere
CustomAttributeNames[ordinamento]=Ordina per
CustomAttributeNames[state_id]=Stato
CustomAttributeNames[topic_node_id]=Argomenti
CustomAttributeTypes[ordinamento]=select
CustomAttributeTypes[includi_classi]=class_select
CustomAttributeTypes[limite]=select
CustomAttributeTypes[elementi_per_riga]=select
CustomAttributeTypes[tags]=tag_tree_select
CustomAttributeNames[elementi_per_riga]=Elementi per riga
CustomAttributeSelection_ordinamento[]
CustomAttributeSelection_ordinamento[name]=Titolo
CustomAttributeSelection_ordinamento[pubblicato]=Data di pubblicazione
CustomAttributeSelection_ordinamento[modificato]=Data di ultima modifica
CustomAttributeSelection_limite[]
CustomAttributeSelection_limite[2]=2
CustomAttributeSelection_limite[3]=3
CustomAttributeSelection_limite[4]=4
CustomAttributeSelection_limite[6]=6
CustomAttributeSelection_limite[8]=8
CustomAttributeSelection_limite[9]=9
CustomAttributeSelection_elementi_per_riga[]
CustomAttributeSelection_elementi_per_riga[3]=3
CustomAttributeSelection_elementi_per_riga[2]=2
CustomAttributeSelection_elementi_per_riga[auto]=Masonry
CustomAttributeTypes[state_id]=state_select
CustomAttributeTypes[topic_node_id]=topic_select
CustomAttributeNames[tags]=Percorsi tag
ManualAddingOfItems=disabled
ViewList[]
ViewList[]=lista_paginata
ViewList[]=lista_paginata_card
ViewList[]=lista_paginata_banner
ViewName[]
ViewName[lista_paginata]=Card (teaser)
ViewName[lista_paginata_card]=Card
ViewName[lista_paginata_banner]=Banner
TTL=3600
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[lista_paginata]=section py-5
ContainerStyle[lista_paginata_card]=py-5
ContainerStyle[lista_paginata_banner]=py-5
CanAddShowAllLink=enabled
CanAddIntroText=enabled

[RicercaDocumenti]
Name=Ricerca Documenti
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=node_id
UseBrowseMode[node_id]=true
CustomAttributes[]=root_tag
CustomAttributes[]=topic_node_id
CustomAttributes[]=start_date
CustomAttributes[]=end_date
CustomAttributes[]=number
CustomAttributes[]=hide_first_level
CustomAttributes[]=hide_empty_facets
CustomAttributes[]=hide_tag_select
CustomAttributes[]=show_only_publication
CustomAttributes[]=hide_publication_end_time
CustomAttributes[]=hide_search_text
CustomAttributes[]=hide_search_number
CustomAttributes[]=hide_search_year
CustomAttributes[]=hide_search_daterange
CustomAttributes[]=hide_search_office
CustomAttributes[]=hide_search_area
CustomAttributes[]=hide_search_topics
CustomAttributeNames[]
CustomAttributeNames[root_tag]=Percorso tag classificazione
CustomAttributeNames[hide_first_level]=Nascondi tag primo livello
CustomAttributeNames[hide_empty_facets]=Nascondi tag senza contenuti
CustomAttributeNames[hide_tag_select]=Nascondi il menu laterale dei tag
CustomAttributeNames[topic_node_id]=Filtra contenuti per argomento
CustomAttributeNames[hide_publication_end_time]=Nascondi la data di fine
CustomAttributeNames[show_only_publication]=Mostra solo documenti compresi nelle date selezionate come inizio e fine
CustomAttributeNames[start_date]=Considera come data di inizio
CustomAttributeNames[end_date]=Considera come data di fine
CustomAttributeNames[number]=Considera come numero
CustomAttributeNames[hide_search_text]=Nascondi input ricerca libera
CustomAttributeNames[hide_search_number]=Nascondi input ricerca numero
CustomAttributeNames[hide_search_year]=Nascondi input ricerca anno
CustomAttributeNames[hide_search_daterange]=Nascondi input ricerca per data
CustomAttributeNames[hide_search_office]=Nascondi input ricerca per ufficio
CustomAttributeNames[hide_search_area]=Nascondi input ricerca per area
CustomAttributeNames[hide_search_topics]=Nascondi input ricerca per argomento
CustomAttributeTypes[]
CustomAttributeTypes[hide_first_level]=checkbox
CustomAttributeTypes[hide_empty_facets]=checkbox
CustomAttributeTypes[hide_tag_select]=checkbox
CustomAttributeTypes[topic_node_id]=topic_select
CustomAttributeTypes[hide_publication_end_time]=checkbox
CustomAttributeTypes[show_only_publication]=checkbox
CustomAttributeTypes[root_tag]=tag_tree_select
CustomAttributeTypes[start_date]=select
CustomAttributeTypes[end_date]=select
CustomAttributeTypes[number]=select
CustomAttributeTypes[hide_search_text]=checkbox
CustomAttributeTypes[hide_search_number]=checkbox
CustomAttributeTypes[hide_search_year]=checkbox
CustomAttributeTypes[hide_search_daterange]=checkbox
CustomAttributeTypes[hide_search_office]=checkbox
CustomAttributeTypes[hide_search_area]=checkbox
CustomAttributeTypes[hide_search_topics]=checkbox
CustomAttributeSelection_start_date[publication_start_time]=Data di inizio pubblicazione
CustomAttributeSelection_start_date[start_time]=Data di inizio validità/efficacia
CustomAttributeSelection_start_date[data_di_firma]=Data di firma
CustomAttributeSelection_start_date[data_protocollazione]= Data di protocollazione
CustomAttributeSelection_end_date[publication_end_time]=Data di fine pubblicazione
CustomAttributeSelection_end_date[end_time]=Data di fine validità/efficacia
CustomAttributeSelection_end_date[expiration_time]=Data di rimozione
CustomAttributeSelection_end_date[data_di_scadenza_delle_iscrizioni]=Data di scadenza delle iscrizioni
CustomAttributeSelection_end_date[data_di_conclusione]=Data di conclusione del bando/progetto
CustomAttributeSelection_number[has_code]=Identificativo del documento
CustomAttributeSelection_number[protocollo]=Numero di protocollo
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[default]=section py-5
CanAddShowAllLink=disabled
CanAddIntroText=disabled

[RicercaLuoghi]
Name=Ricerca Luoghi
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=node_id
UseBrowseMode[node_id]=true
CustomAttributes[]=root_tag
CustomAttributes[]=hide_first_level
CustomAttributes[]=hide_empty_facets
CustomAttributeNames[]
CustomAttributeNames[root_tag]=Percorso tag classificazione
CustomAttributeNames[hide_first_level]=Nascondi primo livello
CustomAttributeNames[hide_empty_facets]=Nascondi tag senza contenuti
CustomAttributeTypes[]
CustomAttributeTypes[hide_first_level]=checkbox
CustomAttributeTypes[hide_empty_facets]=checkbox
CustomAttributeTypes[root_tag]=tag_tree_select
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[default]=section py-5
CanAddShowAllLink=disabled
CanAddIntroText=enabled

[OpendataRemoteContents]
Name=Contenuti remoti (opencontent opendata)
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]
CustomAttributes[]=image
UseBrowseMode[image]=true
CustomAttributes[]=remote_url
CustomAttributes[]=query
CustomAttributes[]=show_grid
CustomAttributes[]=show_map
CustomAttributes[]=show_search
CustomAttributes[]=input_search_placeholder
CustomAttributes[]=limit
CustomAttributes[]=items_per_row
CustomAttributes[]=facets
CustomAttributes[]=view_api
CustomAttributes[]=fields
CustomAttributes[]=simple_geo_api
CustomAttributes[]=template
CustomAttributeNames[]
CustomAttributeNames[image]=Immagine di sfondo
CustomAttributeNames[remote_url]=Url remoto
CustomAttributeNames[query]=Query (esempio: classes [private_organization] sort [name=>asc])
CustomAttributeNames[show_grid]=Mostra lista
CustomAttributeNames[show_map]=Mostra mappa
CustomAttributeNames[show_search]=Mostra input di ricerca
CustomAttributeNames[input_search_placeholder]=Placeholder input di ricerca
CustomAttributeNames[fields]=[Impostazione avanzata] Identificatori campi (esempio: description,more_information)
CustomAttributeNames[facets]=Identificatori filtri (esempio: Argomenti:topics.name,Tipologia:type)
CustomAttributeNames[limit]=Elementi per pagina
CustomAttributeNames[items_per_row]=Elementi per riga
CustomAttributeNames[view_api]=Tipologia di visualizzazione (se disponibile)
CustomAttributeNames[simple_geo_api]=[Impostazione avanzata] Utilizza geo api semplici
CustomAttributeNames[template]=[Impostazione avanzata] Template jsrender custom
CustomAttributeTypes[]
CustomAttributeTypes[show_grid]=checkbox
CustomAttributeTypes[show_map]=checkbox
CustomAttributeTypes[show_search]=checkbox
CustomAttributeTypes[limit]=select
CustomAttributeTypes[items_per_row]=select
CustomAttributeTypes[simple_geo_api]=checkbox
CustomAttributeTypes[template]=text
CustomAttributeTypes[view_api]=select
CustomAttributeSelection_limit[2]=2
CustomAttributeSelection_limit[3]=3
CustomAttributeSelection_limit[4]=4
CustomAttributeSelection_limit[6]=6
CustomAttributeSelection_limit[8]=8
CustomAttributeSelection_limit[9]=9
CustomAttributeSelection_items_per_row[auto]=Masonry
CustomAttributeSelection_items_per_row[2]=2
CustomAttributeSelection_items_per_row[3]=3
CustomAttributeSelection_view_api[card_teaser]=Card (teaser)
CustomAttributeSelection_view_api[card]=Card
CustomAttributeSelection_view_api[banner]=Banner
ViewList[]
ViewList[]=default
ViewList[]=datatable
ViewName[default]=Default
ViewName[datatable]=Datatable
ItemsPerRow[]
CanAddShowAllLink=enabled
Wide[]
Wide[]=default
Wide[]=datatable
CanAddIntroText=enabled
CanAddShowAllLink=disabled

[Ricerca]
Name=Ricerca
NumberOfValidItems=15
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
CustomAttributes[]
CustomAttributes[]=image
UseBrowseMode[image]=true
CustomAttributeNames[image]=Immagine di sfondo
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
Wide[]
Wide[]=default
CanAddShowAllLink=disabled
CanAddIntroText=disabled

[OpendataQueriedContents]
Name=Contenuti in base a opendata query
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=image
UseBrowseMode[image]=true
CustomAttributes[]=query
CustomAttributes[]=ignore_policy
CustomAttributes[]=show_grid
CustomAttributes[]=show_map
CustomAttributes[]=show_search
CustomAttributes[]=input_search_placeholder
CustomAttributes[]=limit
CustomAttributes[]=items_per_row
CustomAttributes[]=facets
CustomAttributes[]=view_api
CustomAttributes[]=fields
CustomAttributes[]=simple_geo_api
CustomAttributes[]=template
CustomAttributeNames[]
CustomAttributeNames[image]=Immagine di sfondo
CustomAttributeNames[query]=Query (esempio: classes [private_organization] sort [name=>asc])
CustomAttributeNames[ignore_policy]=Mostra tutti i contenuti ignorando le policy di accesso
CustomAttributeNames[show_grid]=Mostra lista
CustomAttributeNames[show_map]=Mostra mappa
CustomAttributeNames[show_search]=Mostra input di ricerca
CustomAttributeNames[input_search_placeholder]=Placeholder input di ricerca
CustomAttributeNames[fields]=[Impostazione avanzata] Identificatori campi (esempio: description,more_information)
CustomAttributeNames[facets]=Identificatori filtri (esempio: Argomenti:topics.name,Tipologia:type)
CustomAttributeNames[limit]=Elementi per pagina
CustomAttributeNames[items_per_row]=Elementi per riga
CustomAttributeNames[view_api]=Tipologia di visualizzazione (se disponibile)
CustomAttributeNames[simple_geo_api]=[Impostazione avanzata] Utilizza geo api semplici
CustomAttributeNames[template]=[Impostazione avanzata] Template jsrender custom
CustomAttributeTypes[]
CustomAttributeTypes[ignore_policy]=checkbox
CustomAttributeTypes[show_grid]=checkbox
CustomAttributeTypes[show_map]=checkbox
CustomAttributeTypes[show_search]=checkbox
CustomAttributeTypes[limit]=select
CustomAttributeTypes[items_per_row]=select
CustomAttributeTypes[simple_geo_api]=checkbox
CustomAttributeTypes[template]=text
CustomAttributeTypes[view_api]=select
CustomAttributeSelection_limit[2]=2
CustomAttributeSelection_limit[3]=3
CustomAttributeSelection_limit[4]=4
CustomAttributeSelection_limit[6]=6
CustomAttributeSelection_limit[8]=8
CustomAttributeSelection_limit[9]=9
CustomAttributeSelection_items_per_row[auto]=Masonry
CustomAttributeSelection_items_per_row[2]=2
CustomAttributeSelection_items_per_row[3]=3
CustomAttributeSelection_view_api[card_teaser]=Card (teaser)
CustomAttributeSelection_view_api[card]=Card
CustomAttributeSelection_view_api[banner]=Banner
ViewList[]
ViewList[]=default
ViewName[default]=Default
ItemsPerRow[]
CanAddShowAllLink=enabled
Wide[]
Wide[]=default
Wide[]=datatable
CanAddIntroText=enabled
CanAddShowAllLink=disabled

*/ ?>

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

[Singolo]
Name=Oggetto singolo
NumberOfValidItems=1
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
ViewList[]
ViewList[]=default
#ViewList[]=card
ViewList[]=card_image
#ViewList[]=card_children
ViewList[]=evidence
ViewName[]
ViewName[default]=Default
ViewName[card_image]=Card (solo immagine)
ViewName[evidence]=In evidenza
#ViewName[card]=Card
#ViewName[card_children]=Card (ultimi 4 contenuti)
ItemsPerRow[]
ContainerStyle[]
#ContainerStyle[card]=py-5
#ContainerStyle[card_children]=py-5
Wide[]
Wide[]=card_image
Wide[]=evidence
CanAddShowAllLink=disabled

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
CustomAttributeSelection_ordinamento[name]=Titolo
CustomAttributeSelection_ordinamento[pubblicato]=Data di pubblicazione
CustomAttributeSelection_ordinamento[modificato]=Data di ultima modifica
CustomAttributeSelection_ordinamento[priority]=Priorità del nodo
CustomAttributeTypes[state_id]=state_select
CustomAttributeTypes[topic_node_id]=topic_select
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
CanAddShowAllLink=disabled

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
ViewList[]=lista_card
ViewName[]
ViewName[lista_card]=Default
ItemsPerRow[]
Wide[]
Wide[]=lista_card
CanAddShowAllLink=disabled

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
CanAddShowAllLink=enabled

[RicercaDocumenti]
Name=Ricerca Documenti
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
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[default]=section py-5
CanAddShowAllLink=disabled

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
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[]
ContainerStyle[default]=section py-5
CanAddShowAllLink=disabled

[OpendataRemoteContents]
Name=Contenuti remoti (opencontent opendata)
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=remote_url
CustomAttributes[]=query
CustomAttributes[]=show_grid
CustomAttributes[]=show_map
CustomAttributes[]=show_search
CustomAttributes[]=input_search_placeholder
CustomAttributes[]=limit
CustomAttributes[]=items_per_row
CustomAttributes[]=fields
CustomAttributes[]=facets
CustomAttributes[]=simple_geo_api
CustomAttributes[]=template
CustomAttributeNames[]
CustomAttributeNames[remote_url]=Url remoto
CustomAttributeNames[query]=Query (esempio: classes [private_organization] sort [name=>asc])
CustomAttributeNames[show_grid]=Mostra lista
CustomAttributeNames[show_map]=Mostra mappa
CustomAttributeNames[show_search]=Mostra input di ricerca
CustomAttributeNames[input_search_placeholder]=Placeholder input di ricerca
CustomAttributeNames[fields]=Identificatori campi (esempio: description,more_information)
CustomAttributeNames[facets]=Identificatori filtri (esempio: Argomenti:topics.name,Tipologia:type)
CustomAttributeNames[limit]=Elementi per pagina
CustomAttributeNames[items_per_row]=Elementi per riga
CustomAttributeNames[simple_geo_api]=Impostazione avanzata: utilizza geo api semplici
CustomAttributeNames[template]=Impostazione avanzata: template jsrender custom
CustomAttributeTypes[]
CustomAttributeTypes[show_grid]=checkbox
CustomAttributeTypes[show_map]=checkbox
CustomAttributeTypes[show_search]=checkbox
CustomAttributeTypes[limit]=select
CustomAttributeTypes[items_per_row]=select
CustomAttributeTypes[simple_geo_api]=checkbox
CustomAttributeTypes[template]=text
CustomAttributeSelection_limit[2]=2
CustomAttributeSelection_limit[3]=3
CustomAttributeSelection_limit[4]=4
CustomAttributeSelection_limit[6]=6
CustomAttributeSelection_items_per_row[2]=2
CustomAttributeSelection_items_per_row[3]=3
ViewList[]
ViewList[]=default
ViewName[default]=Default
ItemsPerRow[]
ContainerStyle[default]=py-5
CanAddShowAllLink=enabled

[Ricerca]
Name=Ricerca
NumberOfValidItems=15
NumberOfArchivedItems=0
ManualAddingOfItems=enabled
CustomAttributes[]
CustomAttributes[]=image
UseBrowseMode[image]=true
CustomAttributeNames[image]=Immagine di sfondo
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
Wide[]
Wide[]=default
CanAddShowAllLink=disabled

*/ ?>

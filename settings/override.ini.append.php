<?php /* #?ini charset="utf-8"?

############################################
############################################ EMBED-INLINE
############################################

[embed-inline_opening_hours_specification]
Source=content/view/embed-inline.tpl
MatchFile=embed-inline/opening_hours_specification.tpl
Subdir=templates
Match[class_identifier]=opening_hours_specification

############################################
############################################ EMBED
############################################

[embed_file]
Source=content/view/embed.tpl
MatchFile=embed/file.tpl
Subdir=templates
Match[class_identifier]=file

[embed_image]
Source=content/view/embed.tpl
MatchFile=embed/image.tpl
Subdir=templates
Match[class_identifier]=image

############################################
############################################ DATATYPE VIEW
############################################

[datatype_view_compensi]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_compensi.tpl
Subdir=templates
Match[attribute_identifier]=compensi

[datatype_view_ezstring_sito]
Source=content/datatype/view/ezstring.tpl
MatchFile=datatype/view/string_as_url.tpl
Subdir=templates
Match[attribute_identifier]=sito

[datatype_view_binary_mp3]
Source=content/datatype/view/ezbinaryfile.tpl
MatchFile=datatype/view/file_mp3.tpl
Subdir=templates
Match[attribute_identifier]=mp3

[datatype_view_video_seduta]
Source=content/datatype/view/ezstring.tpl
MatchFile=datatype/view/string_as_video.tpl
Subdir=templates
Match[attribute_identifier]=codice_video

[datatype_view_video_seduta2]
Source=content/datatype/view/ezstring.tpl
MatchFile=datatype/view/string_as_video.tpl
Subdir=templates
Match[attribute_identifier]=codice_video_2

[datatype_view_video_seduta3]
Source=content/datatype/view/ezstring.tpl
MatchFile=datatype/view/string_as_video.tpl
Subdir=templates
Match[attribute_identifier]=codice_video_3

[datatype_view_video_ezstring]
Source=content/datatype/view/ezstring.tpl
MatchFile=datatype/view/string_as_video.tpl
Subdir=templates
Match[attribute_identifier]=video

[datatype_view_video_ezstring2]
Source=content/datatype/view/ezstring.tpl
MatchFile=datatype/view/string_as_video.tpl
Subdir=templates
Match[attribute_identifier]=has_video

[datatype_view_video_ezurl]
Source=content/datatype/view/ezurl.tpl
MatchFile=datatype/view/url_as_video.tpl
Subdir=templates
Match[attribute_identifier]=video

[datatype_view_relations_gallery]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_gallery.tpl
Subdir=templates
Match[attribute_identifier]=images

[datatype_view_relations_gallery2]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_gallery.tpl
Subdir=templates
Match[attribute_identifier]=immagini

[datatype_view_relations_gallery3]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_gallery.tpl
Subdir=templates
Match[attribute_identifier]=gallery

[datatype_view_relations_gallery4]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_gallery.tpl
Subdir=templates
Match[attribute_identifier]=galleria

[datatype_view_relations_gallery5]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_gallery.tpl
Subdir=templates
Match[attribute_identifier]=image

[datatype_view_relations_map]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_map.tpl
Subdir=templates
Match[attribute_identifier]=takes_place_in

[datatype_view_matrix_has_cost]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_has_cost.tpl
Subdir=templates
Match[attribute_identifier]=has_cost

[datatype_view_matrix_channel]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_channel.tpl
Subdir=templates
Match[attribute_identifier]=channel

[datatype_view_matrix_link]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_link.tpl
Subdir=templates
Match[attribute_identifier]=link

[datatype_view_relations_requires_service]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_requires_service.tpl
Subdir=templates
Match[attribute_identifier]=requires_service

[datatype_view_relations_has_offer]
Source=content/datatype/view/ezobjectrelationlist.tpl
MatchFile=datatype/view/relations_has_offer.tpl
Subdir=templates
Match[attribute_identifier]=has_offer

[datatype_view_bool_is_accessible_for_free]
Source=content/datatype/view/ezboolean.tpl
MatchFile=datatype/view/bool_is_accessible_for_free.tpl
Subdir=templates
Match[attribute_identifier]=is_accessible_for_free

[datatype_view_integer_average_processing_time]
Source=content/datatype/view/ezinteger.tpl
MatchFile=datatype/view/integer_average_processing_time.tpl
Subdir=templates
Match[attribute_identifier]=average_processing_time

[datatype_view_integer_has_processing_time]
Source=content/datatype/view/ezinteger.tpl
MatchFile=datatype/view/integer_has_processing_time.tpl
Subdir=templates
Match[attribute_identifier]=has_processing_time

[datatype_view_matrix_opening_hours]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_opening_hours.tpl
Subdir=templates
Match[attribute_identifier]=opening_hours

[datatype_view_matrix_contact]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_contact.tpl
Subdir=templates
Match[attribute_identifier]=contact

[datatype_view_matrix_closure]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_closure.tpl
Subdir=templates
Match[attribute_identifier]=closure

[datatype_view_file_ezurl]
Source=content/datatype/view/ezurl.tpl
MatchFile=datatype/view/url_as_file.tpl
Subdir=templates
Match[class_identifier]=document
Match[attribute_identifier]=link

[datatype_view_matrix_resources]
Source=content/datatype/view/ezmatrix.tpl
MatchFile=datatype/view/matrix_resources.tpl
Subdir=templates
Match[class_identifier]=dataset
Match[attribute_identifier]=resources

############################################
############################################ DATATYPE EDIT
############################################

[datatype_edit_matrix_has_cost]
Source=content/datatype/edit/ezmatrix.tpl
MatchFile=datatype/edit/matrix_has_cost.tpl
Subdir=templates
Match[attribute_identifier]=has_cost

[datatype_edit_matrix_contact]
Source=content/datatype/edit/ezmatrix.tpl
MatchFile=datatype/edit/matrix_contact.tpl
Subdir=templates
Match[attribute_identifier]=contact

[datatype_edit_compensi]
Source=content/datatype/edit/ezmatrix.tpl
MatchFile=datatype/edit/matrix_compensi.tpl
Subdir=templates
Match[attribute_identifier]=compensi

############################################
############################################ BLOCK
############################################

#### ListaAutomatica

[block_lista_card]
Source=block/view/view.tpl
MatchFile=block/lista_card.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_card

[block_lista_card_alt]
Source=block/view/view.tpl
MatchFile=block/lista_card_alt.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_card_alt

[block_lista_card_image]
Source=block/view/view.tpl
MatchFile=block/lista_card_image.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_card_image

[block_lista_card_children]
Source=block/view/view.tpl
MatchFile=block/lista_card_children.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_card_children

[block_lista_accordion]
Source=block/view/view.tpl
MatchFile=block/lista_accordion.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_accordion

[block_lista_banner]
Source=block/view/view.tpl
MatchFile=block/lista_banner.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_banner

[block_lista_carousel]
Source=block/view/view.tpl
MatchFile=block/lista_carousel.tpl
Subdir=templates
Match[type]=ListaAutomatica
Match[view]=lista_carousel


#### ListaManuale

[block_lista_manuale_card]
Source=block/view/view.tpl
MatchFile=block/lista_card.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_card

[block_lista_manuale_card_alt]
Source=block/view/view.tpl
MatchFile=block/lista_card_alt.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_card_alt

[block_lista_manuale_card_image]
Source=block/view/view.tpl
MatchFile=block/lista_card_image.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_card_image

[block_lista_manuale_card_children]
Source=block/view/view.tpl
MatchFile=block/lista_card_children.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_card_children

[block_lista_manuale_accordion]
Source=block/view/view.tpl
MatchFile=block/lista_accordion.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_accordion

[block_lista_manuale_banner]
Source=block/view/view.tpl
MatchFile=block/lista_banner.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_banner

[block_lista_manuale_carousel]
Source=block/view/view.tpl
MatchFile=block/lista_carousel.tpl
Subdir=templates
Match[type]=ListaManuale
Match[view]=lista_carousel


#### Singolo

[block_singolo_default]
Source=block/view/view.tpl
MatchFile=block/singolo_default.tpl
Subdir=templates
Match[type]=Singolo
Match[view]=default

[block_singolo_card]
Source=block/view/view.tpl
MatchFile=block/singolo_card.tpl
Subdir=templates
Match[type]=Singolo
Match[view]=card

[block_singolo_card_image]
Source=block/view/view.tpl
MatchFile=block/singolo_card_image.tpl
Subdir=templates
Match[type]=Singolo
Match[view]=card_image

[block_singolo_card_children]
Source=block/view/view.tpl
MatchFile=block/singolo_card_children.tpl
Subdir=templates
Match[type]=Singolo
Match[view]=card_children

[block_singolo_evidence]
Source=block/view/view.tpl
MatchFile=block/singolo_evidence.tpl
Subdir=templates
Match[type]=Singolo
Match[view]=evidence


#### Eventi

[block_eventi_default]
Source=block/view/view.tpl
MatchFile=block/fullcalendar.tpl
Subdir=templates
Match[type]=Eventi
Match[view]=default

[block_eventiremoti_default]
Source=block/view/view.tpl
MatchFile=block/fullcalendar_remote.tpl
Subdir=templates
Match[type]=EventiRemoti
Match[view]=default


#### Argomenti

[block_argomenti_default]
Source=block/view/view.tpl
MatchFile=block/argomenti.tpl
Subdir=templates
Match[type]=Argomenti
Match[view]=lista_card

#### ListaPaginata

[block_lista_paginata_default]
Source=block/view/view.tpl
MatchFile=block/lista_paginata.tpl
Subdir=templates
Match[type]=ListaPaginata
Match[view]=lista_paginata

#### RicercaDocumenti

[block_ricerca_documenti_default]
Source=block/view/view.tpl
MatchFile=block/ricerca_documenti.tpl
Subdir=templates
Match[type]=RicercaDocumenti
Match[view]=default

#### RicercaLuoghi

[block_ricerca_luoghi_default]
Source=block/view/view.tpl
MatchFile=block/ricerca_luoghi.tpl
Subdir=templates
Match[type]=RicercaLuoghi
Match[view]=default


#### HTML

[block_HTML_default]
Source=block/view/view.tpl
MatchFile=block/html.tpl
Subdir=templates
Match[type]=HTML
Match[view]=default

[block_HTML_html]
Source=block/view/view.tpl
MatchFile=block/html.tpl
Subdir=templates
Match[type]=HTML
Match[view]=html

[block_HTML_wide]
Source=block/view/view.tpl
MatchFile=block/html.tpl
Subdir=templates
Match[type]=HTML
Match[view]=wide

#### OpendataRemoteContents

[block_opendata_remote_gui_default]
Source=block/view/view.tpl
MatchFile=block/opendata_remote_gui.tpl
Subdir=templates
Match[type]=OpendataRemoteContents
Match[view]=default

#### Ricerca

[block_ricerca_default]
Source=block/view/view.tpl
MatchFile=block/ricerca.tpl
Subdir=templates
Match[type]=Ricerca
Match[view]=default
<?php /* #?ini charset="utf-8"?

[IndexPlugins]
Class[event]=ezfIndexSubAttributeGeo
Class[private_organization]=ezfIndexSubAttributeGeo
Class[office]=ezfIndexSubAttributeGeo
Class[public_organization]=ezfIndexSubAttributeGeo
Class[public_service]=ezfIndexSubAttributeGeo
Class[administrative_area]=ezfIndexSubAttributeGeo
Class[document]=ezfIndexHasCodeNormalized
Class[time_indexed_role]=ezfIndexEndlessRole
Class[homepage]=ezfIndexHomepage
General[]=ezfIndexExtraGeo

# Per siti multilingua occorre impostare a livello globale questo index plugin:
#General[]=ezfIndexLangBitwise
# e in ciascun ezfind.ini di siteaccess con la lingua relativa:
# [LanguageSearch]
# SearchMainLanguageOnly=disabled
# [SearchFilters]
# RawFilterList[]=meta_language_code_ms:ita-IT OR extra_lang_ita-IT_b:true


[SolrFieldMapSettings]
DatatypeMap[openparestrictedarea]=lckeyword
CustomMap[eztags]=BootstrapItaliaSolrDocumentFieldeZTags

[IndexBoost]
Class[topic]=4.0
Class[public_service]=3.0
Class[pagina_sito]=3.0
Class[frontpage]=3.0
Class[employee]=3.0
Class[politico]=3.0
Attribute[legal_name]=2.0
Attribute[event_title]=2.0
Attribute[name]=2.0
Attribute[title]=2.0
Attribute[titolo]=2.0
Attribute[has_role]=2.0

[SiteSettings]
SearchOtherInstallations=enabled

*/ ?>

<?php /* #?ini charset="utf-8"?

[RegionalSettings]
TranslationExtensions[]=openpa_bootstrapitalia

#Per validare SC 3.1.1 - Tech H57 [WCAG 2.1 (A)]Using language attributes on the html element
HTTPLocale=it

[TemplateSettings]
ExtensionAutoloadPath[]=openpa_bootstrapitalia

[RoleSettings]
PolicyOmitList[]=image/view
PolicyOmitList[]=valuation/send
PolicyOmitList[]=valuation/form
PolicyOmitList[]=tags/treemenu
PolicyOmitList[]=bootstrapitalia/avatar
PolicyOmitList[]=prenota_appuntamento
PolicyOmitList[]=richiedi_assistenza
PolicyOmitList[]=segnala_disservizio
PolicyOmitList[]=accedi
PolicyOmitList[]=segnalazioni

[UserSettings]
LoginRedirectionUriAttribute[user]=redirect_after_login
LoginRedirectionUriAttribute[group]=redirect_after_login

[ContentSettings]
RedirectAfterPublish=node

[Event]
Listeners[]=oembed/html@OpenPABootstrapItaliaOperators::filterOembedHtml
Listeners[]=response/output@OpenPABootstrapItaliaOperators::minifyHtml

*/ ?>

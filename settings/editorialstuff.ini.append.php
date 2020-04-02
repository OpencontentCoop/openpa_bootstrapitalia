<?php /* #?ini charset="utf-8"?

[_moderation_defaults]
RepositoryNodes[]
AttributeIdentifiers[]
StateGroup=moderation
States[draft]=Bozza
States[waiting]=Bozza
States[accepted]=Accettato
States[refused]=Rifiutato
States[skipped]=Non necessita di moderazione
Actions[]
Actions[draft-accepted]=NotifyOwner
Actions[draft-refused]=NotifyOwner
Actions[accepted-draft]=NotifyOwner
NotificationAttributeIdentifiers[]

[_privacy_defaults]
RepositoryNodes[]
AttributeIdentifiers[]
StateGroup=privacy
States[private]=Privato
States[public]=Pubblico
Actions[]
Actions[private-public]=NotifyOwner
Actions[public-private]=NotifyOwner
NotificationAttributeIdentifiers[]

#[AvailableFactories]
#Identifiers[]=event
#Identifiers[]=place

#[event]
#Name=Eventi
#ClassIdentifier=event
#CreationRepositoryNode=79
#CreationButtonText=Crea nuovo evento
#ClassName=OpenPABootstrapItaliaModerationFactory

#[place]
#Name=Luoghi
#ClassIdentifier=place
#CreationRepositoryNode=71
#CreationButtonText=Crea nuovo luogo
#ClassName=OpenPABootstrapItaliaPrivacyFactory
/*?>
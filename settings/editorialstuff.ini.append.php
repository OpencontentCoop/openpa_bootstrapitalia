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
Actions[waiting-accepted]=NotifyOwner
Actions[waiting-refused]=NotifyOwner
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
AutoRegistration=disabled
#AutoRegistrationNotificationReceiver=group-<USERGROUP_NODE_ID>
#AutoRegistrationNotificationReceiver=<USER_ID>
AutoRegistrationNotificationReceiver=

### Esempi di configurazione:

#[AvailableFactories]
#Identifiers[]=event
#Identifiers[]=place
#Identifiers[]=private_organization

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

#[private_organization]
#Name=Organizzazione
#ClassIdentifier=private_organization
#CreationButtonText=Crea nuova organizzazione
#ClassName=OpenPABootstrapItaliaPrivacyFactory
#CreationRepositoryNode=12
#AutoRegistration=enabled

/*?>
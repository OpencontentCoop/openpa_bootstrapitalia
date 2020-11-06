### Configurazione di dashboard collaborative

 - Attivare workflow di post pubblicazione
 - Impostare file di configurazione `editorialstuff.ini.append.php` secondo esigenze, ad esempio:

```
[AvailableFactories]
Identifiers[]
Identifiers[]=event
Identifiers[]=place
Identifiers[]=private_organization
Identifiers[]=opportunita

[event]
Name=Eventi
ClassIdentifier=event
CreationRepositoryNode=79
CreationButtonText=Crea nuovo evento
ClassName=OpenPABootstrapItaliaModerationFactory

[place]
Name=Luoghi
ClassIdentifier=place
CreationRepositoryNode=72
CreationButtonText=Crea nuovo luogo
ClassName=OpenPABootstrapItaliaPrivacyFactory

[private_organization]
Name=Organizzazione
ClassIdentifier=private_organization
CreationButtonText=Crea nuova organizzazione
ClassName=OpenPABootstrapItaliaPrivacyFactory
CreationRepositoryNode=71
AutoRegistration=enabled

[opportunita]
Name=Opportunità
ClassIdentifier=article
CreationRepositoryNode=80
CreationButtonText=Crea nuova opportunita
ClassName=OpenPABootstrapItaliaModerationFactory
``` 

#### In caso di `AutoRegistration=enabled` 
 - Assegnare all'anonimo un ruolo con policy `join/join` 
 - Gli oggetti-utente che si registrano devono avere un ruolo che gli permetta di operare nella dashboard e che perciò preveda le policy:
   
   - tutte le policy previste nel ruolo Anonymous
   - tutte le policy previste nel ruolo Members
   
   e inoltre: 
   - `content/dashboard`
   - `editorialstuff/dashboard`
   - (`editorialstuff/full_dashboard` per avere visibilità su tutti i contenuti)
   - `content/read/Owner(Self)`
   - `content/create/Class(...)`
   - `content/edit/Owner(Self),StateGroup_moderation(In lavorazione) `
   - `content/remove/Owner(Self)`
   - `ezoe/editor`
   - `forms/use`
   - `gdpr/acceptance`
   - `ocmultibinary/*`
   - `recurrence/use`
   - `ocbtools/editor_tools`
   - `content/read/Class(Cartella),Section(Media)`   
   - `content/create/Subtree(Images),Class(Immagine)`
   - `content/edit/Subtree(Images),Class(Immagine),Owner(Self)`
   - `content/create/Subtree(...),Class(...)` altre classi correlate (ad esempio luoghi)
   - `content/edit/Subtree(...),Class(...),Owner(Self),StateGroup_...(...)` altre classi correlate (ad esempio luoghi)
   - esempio per moderation: `state/assign/Class(...),Owner(Self),StateGroup_moderation(In lavorazione),NewState(moderation/waiting)`    
   
   è possibile usare la strategia di aggiungere una collocazione all'aprovazione oppure associare il ruolo direttamente al contenitore.
   Nel caso il contenitore non sia un oggetto di classe user_group occorre abilitare l'asssegnazione modificando `browse.ini.append.php`
```
[AssignRole]
Class[]=...
```
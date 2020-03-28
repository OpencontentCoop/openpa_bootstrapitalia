## Nota sull'utilizzo della configurazione dei blocchi *Sovrapposto al blocco precedente*

Quando si utilizza l'impostazione del blocco *Sovrapposto al blocco precedente*, 
il contenuto del blocco viene "sollevato" per sovrapporsi al blocco precedente. 

Per equilibrare le distanze verticali dei blocchi, nel blocco successivo a quello sovrapposto, viene ridotto il margine superiore,
se gli sfondi dei due blocchi sono configurati allo stesso modo (entrambi bianchi o entrambi grigi).

Esempio in cui **non** viene ridotto il margine superiore del blocco 3:
 1. Blocco Oggetto singolo
 1. Blocco Lista Manuale  *Sovrapposto al blocco precedente* **Sfondo grigio**
 1. Blocco Lista Manuale **Sfondo bianco**

Esempio in cui viene ridotto il margine superiore del blocco 3:
 1. Blocco Oggetto singolo
 1. Blocco Lista Manuale  *Sovrapposto al blocco precedente* **Sfondo grigio**
 1. Blocco Lista Manuale **Sfondo grigio**


Tuttavia utilizzando come blocco successivo il blocco Argomenti con un'immagine di sfondo, questa correzione non viene applicata 
e il titolo del blocco appare troppo shiacciato al margine superiore dello sfondo.  
Per ovviare al problema è necessario impostare gli sfondi dei due blocchi in maniera differente.

Esempio:
 1. Blocco Oggetto singolo
 1. Blocco Lista Manuale  *Sovrapposto al blocco precedente* **Sfondo grigio**
 1. Blocco Argomenti Immagine di sfondo **Sfondo bianco**
 
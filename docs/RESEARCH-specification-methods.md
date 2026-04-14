# Research: How Top Programmers Approach Specification Before Coding

Research date: 2026-04-14

---

## 1. John Carmack (id Software, Oculus, Keen Technologies)

### Approccio

Carmack non ha mai seguito un approccio formale a design doc o specifiche scritte. Il suo metodo storico si basa su **modelli mentali chiari** costruiti con esperienza e su **iterazione continua** con codice sempre shippabile.

### Formato: il .plan file

Il principale artefatto di pianificazione di Carmack erano i `.plan` files -- log giornalieri in plain text condivisi via finger protocol. Usava un sistema a prefissi:
- Nessun prefisso: task menzionato ma non risolto
- `*`: completato lo stesso giorno
- `+`: completato in seguito
- `-`: scartato in seguito

> "Whenever a bug / missing feature is mentioned during the day and I don't fix it, I make a note of it."

### Principi chiave

- **"Don't do prototypes"** -- ma con contesto: "We knew what the game was, we had it in our minds. We had 10 years of experience." (Romero su id Software). Per team piccoli ed esperti, il modello mentale condiviso sostituiva il documento.
- **"Just make the game. Polish as you go. Don't depend on polish happening later. Always maintain constantly shippable code."**
- **"Don't waste time planning for your future games. You'll be smarter then."** -- Non over-architetturare per il futuro.
- Carmack ha poi **parzialmente ritrattato** nel 2019 (Joe Rogan): "I largely recant from that now" -- riconoscendo che id Software avrebbe potuto shippare Quake prima con piu' pianificazione upfront.

### Cosa risponde prima di codificare

- Qual e' l'input/output fondamentale del sistema? (es. "There are four principle inputs to a game: keystrokes, mouse moves, network packets, and time")
- Qual e' il costo a lungo termine di questa feature? ("The cost of adding a feature isn't just the time it takes to code it. The cost also includes the addition of an obstacle to future expansion.")
- Approccio funzionale: "Gather up your input, pass it to a pure function, then take the results and do something with it."

### Cosa esclude

- Design doc formali
- UML, diagrammi
- Pianificazione multi-progetto
- Specifiche dettagliate per altri (team di 4 persone con visione condivisa)

### Evoluzione con AI

Carmack ha fondato Keen Technologies per AGI. Il suo approccio al 2025 enfatizza **efficienza, team piccoli, innovazione architetturale** -- gradient descent con step piccoli e informazione locale.

**Fonti:**
- [The Carmack Plan](https://garbagecollected.org/2017/10/24/the-carmack-plan/)
- [id Software Principles](https://charlesboury.fr/articles/id-software-principles.html)
- [Carmack .plan archive 1997](https://fabiensanglard.net/fd_proxy/doom3/pdfs/johnc-plan_1997.pdf)
- [Lex Fridman Podcast #309](https://lexfridman.com/john-carmack/)

---

## 2. Linus Torvalds (Linux, Git)

### Approccio

Torvalds non produce specifiche o design doc. Il kernel Linux non ha roadmap centralizzata, design doc formali, o specifiche pre-coding. La "specifica" e' **il codice stesso**, la **patch submission**, e la **code review pubblica** sulla LKML.

### Formato: la patch + commit message

La patch e' l'unita' atomica di comunicazione. Ogni patch deve contenere:

1. **Subject line**: `[PATCH] subsystem: summary phrase` (max 70-75 caratteri)
2. **Body**: spiegazione del *perche'*, non del *cosa*
3. **Signed-off-by**: certificazione di origine

> "Whether your patch is a one-line bug fix or 5000 lines of a new feature, there must be an underlying problem that motivated you to do this work."

> "Convince the reviewer that there is a problem worth fixing and that it makes sense for them to read past the first paragraph."

### Domande a cui risponde

- **Perche' questo cambiamento esiste?** Il body deve dare "such detail so that when read weeks, months or even years later, it can give the reader the needed details to grasp the reasoning for **why** the patch was created."
- **Qual e' l'impatto utente?** Crash, lockup, regressioni di performance -- con dati empirici.
- **Performance claims?** Richiedono numeri concreti ("include numbers that back them up").

### Il concetto di "good taste"

Nel TED talk 2016, Torvalds definisce "taste" come la capacita' di vedere un problema da un'angolazione diversa, eliminando casi speciali:

> "Sometimes you can look at a problem from a different angle and rewrite the code by reducing the special case to the normal case, and that's what makes good code."

### Cosa esclude esplicitamente

- Design doc formali
- Roadmap centralizzate
- Specifiche pre-implementazione
- Documentation come soluzione ai problemi di qualita': "The AI slop issue is NOT going to be solved with documentation."

### Principi architetturali

- Funzioni corte che fanno una cosa sola
- Mai piu' di 3 livelli di indentazione
- Patch piccole e logicamente indipendenti, ognuna verificabile isolatamente
- "Solve real problems, not imaginary threats. Reject 'theoretically perfect' but practically complex solutions."
- Mai rompere lo userspace

**Fonti:**
- [Submitting Patches - Linux Kernel docs](https://kernel.org/doc/html/v6.8/process/submitting-patches.html)
- [Linux Kernel coding style](https://github.com/torvalds/linux/blob/master/Documentation/process/coding-style.rst)
- [Good Taste - Torvalds TED](https://gist.github.com/santisbon/42580049705ba3d8fbef7168e4668e3c)
- [Torvalds on AI slop](https://www.phoronix.com/news/Torvalds-Linux-Kernel-AI-Slop)
- [How Linux Is Built](https://newsletter.pragmaticengineer.com/p/how-linux-is-built-with-greg-kroah)

---

## 3. DHH / Shape Up (Ruby on Rails, Basecamp/37signals)

### Approccio

DHH e Basecamp hanno sviluppato **Shape Up** come alternativa sia a waterfall (troppa specifica) sia ad agile/scrum (troppo poca). Il principio centrale: **non puoi specificare accuratamente il software in anticipo**, ma puoi dare forma (*shape*) alla soluzione con il livello giusto di astrazione.

### Formato: il Pitch

Il Pitch e' il documento centrale di Shape Up. Contiene **5 ingredienti obbligatori**:

1. **Problem** -- Una storia specifica che mostra perche' lo status quo non funziona. "The best problem definition consists of a single specific story."
2. **Appetite** -- Quanto tempo si vuole investire (budget, non stima). "How much time we want to spend and how that constrains the solution."
3. **Solution** -- Gli elementi core, presentati in forma immediatamente comprensibile. Fat marker sketches, breadboards -- mai wireframes o mockup hi-fi.
4. **Rabbit Holes** -- Dettagli implementativi da segnalare per evitare problemi.
5. **No-Gos** -- Funzionalita' esplicitamente escluse per rispettare l'appetite.

### Tre proprieta' del lavoro shaped

1. **Rough**: visibilmente non finito. "Work that's too fine, too early commits everyone to the wrong details."
2. **Solved**: pensato a fondo a livello macro. "The overall solution is spelled out."
3. **Bounded**: limiti chiari su cosa non fare.

### Domande a cui risponde

- Qual e' il problema specifico?
- Quanto vale (in tempo) risolvere questo problema?
- Qual e' la soluzione a livello macro?
- Dove sono le trappole implementative?
- Cosa esplicitamente NON facciamo?

### Cosa esclude

- **Wireframes** ("too concrete, boxes in designers")
- **Mockup hi-fi** ("enable unproductive discussions about color/proportions")
- **Stime** (sostituiti da budget/appetite)
- **Backlog** (deliberatamente non mantenuto)
- **Task list** (i team le creano autonomamente)
- **Specifiche implementative dettagliate**

### Filosofia

> "It's impossible to accurately specify what software should do up front. You can only discover what software should do within constraints."

> "Don't do estimates, do budgets -- focusing on what something is worth rather than how long it will take."

**Fonti:**
- [Shape Up - Write the Pitch](https://basecamp.com/shapeup/1.5-chapter-06)
- [Principles of Shaping](https://basecamp.com/shapeup/1.1-chapter-02)
- [Shape Up - Introduction](https://basecamp.com/shapeup/0.3-chapter-01)
- [DHH interview - Computers Are Hard](https://medium.com/computers-are-hard/computers-are-hard-building-software-with-david-heinemeier-hansson-c9025cdf225e)

---

## 4. Casey Muratori (Handmade Hero, Molly Rocket)

### Approccio

Muratori e' probabilmente il piu' **anti-specifica** tra i programmatori di rilievo. Il suo metodo -- **Semantic Compression** / **Compression-Oriented Programming** -- rifiuta esplicitamente la pianificazione architetturale upfront.

### Filosofia core

> "Starting from a place where the details don't exist inevitably means you will forget or overlook something that will cause your plans to fail or lead to suboptimal results."

L'architettura **emerge** dalla compressione iterativa del codice, non dalla pianificazione:

> "Starting with details and repeatedly compressing to arrive at architecture avoids pitfalls of trying to conceive architecture ahead of time."

### Il processo

1. **Scrivi codice naive** -- "Just type out exactly what I want to happen in each specific case, without any regard to 'correctness' or 'abstraction'."
2. **Non astrarre mai alla prima istanza** -- "I don't reuse anything until I have at least two instances of it occurring."
3. **Comprimi semanticamente** -- Quando trovi duplicazione, estrai la parte riusabile.
4. **L'architettura emerge** -- "Code is procedurally oriented, and the 'objects' are simply constructs that arise that allow procedures to be reused."

### Domande a cui risponde (implicitamente)

- Cosa deve fare concretamente il codice in questo caso specifico?
- C'e' duplicazione semantica con codice esistente?
- Posso ridurre un caso speciale al caso generale?

### Cosa esclude

- **Tutto** cio' che e' upfront design: UML, diagrammi, index cards, Visio, design doc
- Architettura pre-pianificata
- OOP come principio organizzativo
- "Prematurely reusable" code

### Risultato

> "Make your code usable before you try to make it reusable."

Codice ben compresso e': facile da leggere (poco), semanticamente allineato al dominio, facile da mantenere, facile da estendere.

**Fonti:**
- [Semantic Compression](https://caseymuratori.com/blog_0015)
- [HN discussion on Semantic Compression](https://news.ycombinator.com/item?id=17090319)
- [Handmade Hero](https://hero.handmade.network/)

---

## 5. Stripe Engineering / Patrick Collison

### Approccio

Stripe non ha pubblicato un template ufficiale di design doc, ma la sua cultura ingegneristica e' profondamente **writing-first**. Patrick Collison modella questa cultura personalmente.

### Cultura della scrittura

- Il CEO e il CTO pubblicano ciascuno **piu' di un blog post interno al mese**
- "Engineers love the leverage good writing provides" -- "vastly more people consume the writing than produce it."
- Le decisioni importanti devono essere archiviate in **artefatti a lungo termine**, non in Slack
- "Slack is not meant for canonical information storage."

### Processi specifici

- **API Review rigorosa**: ogni modifica all'API Stripe deve passare una review che "goes way beyond a 'normal' code review."
- **Friction Logs**: narrativa stream-of-consciousness di come funziona un'esperienza utente, con contesto, pro/contro, documentazione visiva.
- **RFCs e ADRs**: "deeply embedded in Stripe's culture and are sometimes used for non-technical changes such as re-orgs."

### Struttura organizzativa

Non esistono team engineering e product separati. Ogni team di product engineering ha un manager. Gli ingegneri partecipano all'intero processo: business scope, user research, collaborazione con designer, legali, contabili.

### Cosa esclude

Non disponibile pubblicamente nel dettaglio. La cultura enfatizza la qualita' della scrittura e della review piu' che un template specifico.

**Fonti:**
- [Inside Stripe's Engineering Culture Part 2](https://newsletter.pragmaticengineer.com/p/stripe-part-2)
- [Companies Using RFCs](https://blog.pragmaticengineer.com/rfcs-and-design-docs/)

---

## 6. Google Design Doc Culture

### Approccio

I design doc sono un elemento chiave della cultura ingegneristica di Google. Sono documenti **relativamente informali** creati **prima di iniziare a codificare**.

> "As software engineers our job is not to produce code per se, but rather to solve problems."

### Sezioni standard

1. **Context and Scope** -- Background tecnico, fatti oggettivi, conoscenza assunta. Succinto.
2. **Goals and Non-Goals** -- Cosa il sistema fa e cosa **esplicitamente non fa**. "Non-goals are things that could reasonably be goals, but are explicitly chosen not to be goals."
3. **The Actual Design** -- Overview poi dettagli. Trade-off espliciti. Perche' questa soluzione e' la migliore dati gli obiettivi.
   - System context diagram
   - API (sketch, non definizioni verbose)
   - Data storage
   - Code/pseudo-code (raro, solo per algoritmi nuovi)
4. **Alternatives Considered** -- Design alternativi e perche' sono stati scartati. Trade-off.
5. **Cross-Cutting Concerns** -- Security, privacy, observability.

### Domande a cui risponde

- Sei incerto sull'approccio di design giusto?
- Un senior engineer coinvolto migliorerebbe il risultato?
- Il design e' abbastanza ambiguo o controverso da beneficiare del consenso?
- Il team tende a trascurare concern trasversali (privacy, security)?
- Serve documentazione per futuri engineer?

Se rispondi "si'" a 3+ di queste: scrivi un design doc.

### Livello di dettaglio

- **Sweet spot**: 10-20 pagine per progetti grandi
- **Mini design doc**: 1-3 pagine per miglioramenti incrementali
- Enfasi sui **trade-off**, non sulla descrizione dell'implementazione

### Quando NON scriverne uno

- La soluzione e' ovvia con trade-off minimi
- Il documento diventa un "implementation manual" senza esplorare alternative
- Prototyping e iterazione rapida sono critici (ma questo "is not an excuse for not taking the time to get solutions to actually known problems right")

### Processo di review

- **Lightweight**: condividi il doc con il team, discussione nei commenti
- **Formal**: presentazione a audience di senior engineer

> "The primary value of the review isn't that issues get discovered per-se, but rather that this happens relatively early in the development lifecycle when it is still relatively cheap to make changes."

### Ciclo di vita

1. Creazione e iterazione rapida (Google Docs per collaborazione real-time)
2. Review con audience piu' ampia
3. Implementazione (aggiornamento se la realta' diverge)
4. Mantenimento come entry point per nuovi engineer

**Fonti:**
- [Design Docs at Google](https://www.industrialempathy.com/posts/design-docs-at-google/)
- [RFC and Design Doc Examples](https://newsletter.pragmaticengineer.com/p/software-engineering-rfc-and-design)

---

## 7. Amazon "Working Backwards" (PR/FAQ)

### Approccio

Amazon usa il metodo **Working Backwards**: parti dall'esperienza cliente desiderata e lavora all'indietro fino a capire cosa costruire. Lo strumento principale e' il **PR/FAQ** -- un documento scritto prima che qualsiasi codice venga scritto.

### Formato: il PR/FAQ

#### Press Release (1 pagina)

1. **Heading** -- Nome prodotto in una frase
2. **Subheading** -- Target customer e benefici
3. **Summary Paragraph** -- Data lancio, overview prodotto
4. **Problem Paragraph** -- Pain point del cliente dalla loro prospettiva
5. **Solution Paragraph(s)** -- Descrizione dettagliata di come il prodotto risolve il problema
6. **Quotes** -- Citazione di un portavoce + testimonianza cliente
7. **Getting Started** -- Call-to-action

#### FAQ Section

**External FAQs** (cliente):
- Come funziona?
- Quanto costa?
- Come ottengo supporto?

**Internal FAQs** (stakeholder aziendali):
- Quali sono le alternative attuali del cliente?
- Qual e' il TAM (Total Addressable Market)?
- Analisi competitiva e differenziazione
- Sfide tecniche, legali, operative
- Capacita' e partnership necessarie
- Unit economics e timeline di profittabilita'
- Assunzioni critiche per il successo
- **Top 3 rischi di fallimento**

### Domande a cui risponde

- **Per chi e' questo?** Cliente target con problema specifico
- **Perche' lo vorrebbero?** Beneficio chiaro e differenziato
- **Come funziona?** "Described in sufficient detail to clarify how it addresses the problem"
- **Perche' noi e non altri?** "How your product is meaningfully differentiated"
- **Quanto costa farlo?** Unit economics
- **Cosa puo' andare storto?** Top 3 rischi

### Livello di dettaglio

- **Prima bozza**: "only a few hours, not a few days" -- per esplorare velocemente
- **Versione finale**: puo' richiedere **mesi** di lavoro iterativo ad Amazon
- La soluzione deve essere "described in sufficient detail" -- no vague, no high-level

### Cosa esclude

- Dettagli implementativi tecnici (quelli vengono dopo, spesso con Agile)
- Architettura del sistema
- Stime di effort (focus sul valore, non sul costo)

### Filosofia

> "The process of writing a press release and FAQs, in and of itself -- before any code is written, any budgets are set, and any headcount is given -- helps product teams identify features the team should invest in, and potential issues that may arise before they occur."

**Fonti:**
- [Working Backwards PR/FAQ Process](https://workingbackwards.com/concepts/working-backwards-pr-faq-process/)
- [PR/FAQ Instructions & Template](https://workingbackwards.com/resources/working-backwards-pr-faq/)
- [Amazon PR/FAQ Template](https://productstrategy.co/working-backwards-the-amazon-prfaq-for-product-innovation/)
- [AWS Working Backwards](https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-product-development/start-with-why.html)

---

## 8. Joel Spolsky (Stack Overflow, Fog Creek)

### Approccio

Spolsky ha scritto la serie seminale **"Painless Functional Specifications"** (2000) -- probabilmente il testo piu' influente mai scritto sulle specifiche software.

> "Failing to write a spec is the single biggest unnecessary risk you take in a software project."

### Formato: la Functional Specification

**Sezioni del documento:**

1. **Disclaimer** -- Stato di completezza del documento
2. **Author** -- Un singolo autore responsabile. "Your specs should be owned and written by one person."
3. **Scenarios** -- Narrative d'uso dettagliate e realistiche con utenti fittizi. "The more vivid and realistic the scenario, the better a job you will do designing a product."
4. **Nongoals** -- Cosa esplicitamente non sara' costruito. Previene scope creep.
5. **Overview** -- Table of contents o flowchart del prodotto
6. **Detailed Specifications** -- Il cuore. Ogni schermata ha un nome canonico con dettaglio esaustivo su tutti i casi d'uso, edge case, condizioni di errore. "Details are the most important thing in a functional spec."
7. **Open Issues** -- Decisioni irrisolte che richiedono risposta prima di codificare
8. **Side Notes** -- Note categorizzate: Technical Notes (programmatori), Testing Notes (QA), Marketing Notes, Documentation Notes

### Domande a cui risponde

- Come funziona il prodotto **dalla prospettiva dell'utente**?
- Cosa succede in ogni condizione di errore?
- Cosa **non** facciamo?
- Quali decisioni sono ancora aperte?
- Chi e' l'utente tipico e cosa sta cercando di fare?

### Livello di dettaglio

> "Details are the most important thing in a functional spec" -- con "outrageous detail about error cases."

Ma il documento deve essere **leggibile**:
> "Specs must be written to be read, not just to exist."

### 5 regole per specifiche efficaci

1. **Sii divertente** -- Humor negli esempi ("Miss Piggy poking at the keyboard")
2. **Scrivi per cervelli umani** -- Big picture prima, poi dettagli. Storie, non definizioni astratte. "Humans have evolved to understand stories."
3. **Scrivi semplicemente** -- Frasi corte, liste puntate, screenshot, whitespace
4. **Rileggi piu' volte** -- Riscrivi ogni frase non immediatamente chiara
5. **Evita template** -- "A spec is a document that you want people to read" -- trattala come un saggio, non come un form

### Cosa esclude

- **Dettagli implementativi tecnici** -- La spec descrive SOLO la prospettiva utente
- **Template rigidi** -- Spolsky sconsiglia esplicitamente i template standard
- **Linguaggio formale/accademico**

### Chi deve scrivere le spec

Il **Program Manager** -- ruolo separato dallo sviluppatore. Richiede: "writing clear English, diplomacy, market awareness, user empathy, and good UI design." Non deve avere autorita' gerarchica sui dev: deve convincere, non comandare.

### Perche' le spec sono essenziali

- Iterare su testo richiede minuti; iterare su codice richiede settimane
- I programmatori si legano emotivamente al codice scritto, resistendo ai cambi architetturali
- Senza spec, la QA interrompe continuamente gli sviluppatori con domande base
- Senza spec, scheduling e budgeting sono impossibili
- Le spec forzano decisioni di design **prima** che diventino costose

**Fonti:**
- [Part 1: Why Bother](https://www.joelonsoftware.com/2000/10/02/painless-functional-specifications-part-1-why-bother/)
- [Part 2: What's a Spec](https://www.joelonsoftware.com/2000/10/03/painless-functional-specifications-part-2-whats-a-spec/)
- [Part 3: But How](https://www.joelonsoftware.com/2000/10/04/painless-functional-specifications-part-3-but-how/)
- [Part 4: Tips](https://www.joelonsoftware.com/2000/10/15/painless-functional-specifications-part-4-tips/)

---

## 9. Altre figure rilevanti

### 9a. antirez (Salvatore Sanfilippo) -- Redis

Antirez e' particolarmente rilevante perche' ha coniato il termine **"Automatic Programming"** per distinguerlo dal "Vibe Coding".

**Metodo di pianificazione:**
- Scrive un **design document** prima dell'implementazione: "I started to write a design document, then I started to implement a proof of concept."
- Apre nuovi moduli con un **"README-inside-the-file"** di 10-20 righe: approccio scelto e alternative scartate
- Per lavorare con AI, prepara un **"brain dump"** contenente:
  - "Clear goals of what should be done, the invariants we require, and even the style the code should have"
  - "Hints about bad solutions that may look good, and why they could be suboptimal"
  - "Hints about very good potential solutions, even if not totally elaborated"

> "Programming is now automatic, vision is not (yet)."

> "Automatic programming produces vastly different results with the same LLMs depending on the human guiding the process."

**Fonti:**
- [Automatic Programming](https://antirez.com/news/159)
- [Coding with LLMs summer 2025](https://antirez.com/news/154)

---

### 9b. Addy Osmani (Google Chrome/Cloud)

Osmani ha scritto la guida piu' completa su come scrivere spec per AI agent nel 2025-2026.

**Processo:**
1. **Brainstorming iterativo con AI**: "I'll describe the idea and ask the LLM to iteratively ask me questions until we've fleshed out requirements and edge cases."
2. **Compilazione spec.md**: Requirements, architecture decisions, data models, testing strategy
3. **Piano di progetto**: Feed spec a reasoning model per generare task plan
4. **Iterazione**: Editing e critica fino a coerenza

**Struttura spec raccomandata:**
```
# Project Spec: [Name]
## Objective - What and why
## Tech Stack - Specific versions
## Commands - Full executable commands
## Project Structure - Directory organization
## Boundaries - Always / Ask First / Never tiers
```

**Sistema di limiti a 3 livelli:**
- Always do (sicuri senza chiedere)
- Ask first (impatto alto, richiede approvazione)
- Never do (hard stop)

**Principi chiave:**
- Specificita' sopra vaghezza: "React 18 with TypeScript, Vite, and Tailwind CSS" non "React project"
- Context overload degrada le performance: max ~10 requisiti simultanei
- Spec come documento vivente, non one-shot

> "Planning first forces you and the AI onto the same page and prevents wasted cycles."

> "Most agent files fail because they're too vague."

**Fonti:**
- [How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/)
- [My LLM coding workflow going into 2026](https://addyosmani.com/blog/ai-coding-workflow/)

---

### 9c. Martin Fowler (ThoughtWorks)

Fowler ha analizzato lo **Spec-Driven Development (SDD)** emergente nel 2025-2026, definendo tre livelli:

1. **Spec-first**: spec scritta prima, poi scartata dopo l'implementazione
2. **Spec-anchored**: spec mantenuta per evoluzione e manutenzione della feature
3. **Spec-as-source**: spec come artefatto primario; l'umano non tocca mai il codice generato

**Definizione di spec:**
> "A structured, behavior-oriented artifact -- or set of related artifacts -- written in natural language that expresses software functionality and serves as guidance to AI coding agents."

**Limiti identificati:**
- Problem-size mismatch: piccoli bug fix diventano inutilmente elaborati
- Review burden: "I'd rather review code than all these markdown files."
- Agent non-compliance: nonostante spec complete, gli agent ignorano spesso le istruzioni
- Rischio di "Verschlimmbesserung" (peggiorare tentando di migliorare)

> "The past has shown that the best way for us to stay in control of what we're building are small, iterative steps, so I'm very skeptical that lots of up-front spec design is a good idea."

**Fonti:**
- [Understanding SDD: Kiro, spec-kit, Tessl](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Spec-Driven Development - ThoughtWorks](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)

---

### 9d. Kent Beck (Extreme Programming, TDD)

Beck non usa specifiche formali. Il suo sostituto e' il **test**:
- **Test-Driven Development**: scrivi il test prima, poi codifica fino a quando il test passa
- **4 regole del Simple Design**: Passes the tests, reveals intention, no duplication, fewest elements
- La pianificazione e' un **processo continuo**, non un evento one-shot

---

### 9e. Simon Willison

Willison propone **conformance suites** -- test language-independent (spesso YAML) che qualsiasi implementazione deve passare. La suite agisce come contratto: specifica input/output attesi. Chiama il codice AI fragile "house of cards code" -- che specifiche ben fatte prevengono.

---

### 9f. Uber Engineering

Uber ha evoluto il suo processo di planning attraverso tre fasi:
- **<50 ingegneri**: "DUCK" documents -- linguaggio semplice per descrivere proposte
- **Centinaia di ingegneri**: RFC con mailing list segmentate
- **2000+ ingegneri**: Tooling custom con template tiered (lightweight vs heavyweight)

**Template servizi:**
Approvers, Abstract, Architecture changes, Service SLAs, Dependencies, Load/performance testing, Multi data-center concerns, Security, Testing & rollout, Metrics & monitoring, Customer support

**Fonti:**
- [Engineering Planning with RFCs](https://newsletter.pragmaticengineer.com/p/rfcs-and-design-docs)

---

## Sintesi comparativa

### Spettro di formalita'

```
PIU' FORMALE                                               MENO FORMALE
    |                                                           |
Amazon    Joel      Google    Stripe    Shape Up    Torvalds    Carmack    Muratori
PR/FAQ    Spolsky   Design    RFC/      Pitch       Patch +     .plan      Nessuna
          Func.     Doc       Friction              commit      file       spec
          Spec                Log                   msg
```

### Domande universali (risposte da tutti, in forme diverse)

| Domanda | Chi la risponde esplicitamente |
|---------|-------------------------------|
| Qual e' il problema? | Tutti |
| Per chi e'? | Amazon, Spolsky, Shape Up, Google |
| Cosa NON facciamo? | Google, Spolsky, Shape Up, Amazon |
| Perche' questa soluzione e non un'altra? | Google, Amazon |
| Quali sono i rischi? | Amazon, Google, Shape Up (rabbit holes) |
| Qual e' il budget di tempo? | Shape Up (appetite) |
| Cosa succede negli edge case? | Spolsky (dettaglio ossessivo) |
| Come lo verifichiamo? | Torvalds (numeri), Beck (test), Willison (conformance) |

### Pattern emergenti per AI-assisted coding (2025-2026)

1. **La spec e' tornata centrale** -- ma in forma diversa da waterfall. Non e' un documento monolitico; e' un artefatto vivo.
2. **Il "brain dump" di antirez** e' il formato emergente: goals, invarianti, stile, bad solutions da evitare, good solutions da esplorare.
3. **Addy Osmani** codifica la pratica: spec.md strutturato + boundaries a 3 livelli + iterazione con AI.
4. **Martin Fowler** avverte: attenzione al problem-size mismatch. Non tutto ha bisogno di una spec formale.
5. **Il consenso**: senior engineers spendono la maggior parte del tempo su planning prima che l'agent riceva il primo prompt. "The software design document is the single highest leverage artifact in the entire workflow."
6. **Simon Willison**: conformance suites come contratto. Spec + test = sicurezza contro "house of cards code."

### Cosa NON funziona (consensus negativo)

- Spec vaghe ("make it better") -- Osmani
- Spec troppo verbose per problemi piccoli -- Fowler
- Spec che diventano "implementation manuals" senza trade-off -- Google
- Template rigidi che nessuno legge -- Spolsky
- Documentazione come sostituto di comprensione -- Torvalds
- Architettura pre-pianificata senza codice concreto -- Muratori

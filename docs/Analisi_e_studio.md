# Analisi e Studio — Fase A del Workflow 1

> Ricerca approfondita su come antirez e le figure di spicco della programmazione mondiale approcciano la fase di specifica prima di codificare. Include esempi verbatim dai repository e blog post di antirez, analisi incrociata con altri programmatori di rilievo, e sintesi della ricerca accademica 2025-2026 sulle specifiche per AI coding agent.
>
> **Data:** 14 aprile 2026

---

## Indice

1. [Come antirez risponde concretamente](#1-come-antirez-risponde-concretamente)
2. [Analisi incrociata — figure di spicco](#2-analisi-incrociata--figure-di-spicco)
3. [Ricerca accademica e pratica 2025-2026](#3-ricerca-accademica-e-pratica-2025-2026)
4. [Sintesi finale — le 10 domande per /spec](#4-sintesi-finale--le-10-domande-per-spec)
5. [Cosa NON mettere nella spec](#5-cosa-non-mettere-nella-spec)
6. [Fonti](#6-fonti)

---

## 1. Come antirez risponde concretamente

antirez non scrive "specifiche". Scrive quello che un programmatore competente avrebbe bisogno di sapere per fare il lavoro senza chiedere niente a nessuno. La struttura emerge spontaneamente in 6 punti.

---

### 1.1 Scope ad alto livello

antirez apre SEMPRE con 1-3 frasi secche che dicono cosa fa il progetto. Niente introduzioni, niente contesto storico.

**iris.c/AGENT.md:**
> This is a C implementation of two image synthesis model families:
> - Flux.2 Klein (4B and 9B variants)
> - Z-Image-Turbo (6B)
>
> The project is called "Iris" (from the Greek goddess of the rainbow).

*Questa e' un'implementazione in C di due famiglie di modelli di sintesi immagini: Flux.2 Klein (varianti 4B e 9B) e Z-Image-Turbo (6B). Il progetto si chiama "Iris" (dalla dea greca dell'arcobaleno).*

**voxtral.c/CLAUDE.md:**
> Pure C implementation of Mistral AI's Voxtral Realtime 4B speech-to-text model.

*Implementazione in C puro del modello speech-to-text Voxtral Realtime 4B di Mistral AI.*

**qwen-asr/AGENT.md:**
> Pure C inference engine for Qwen3-ASR speech-to-text models:
> - Qwen3-ASR-0.6B
> - Qwen3-ASR-1.7B
>
> Primary target is CPU inference (BLAS + architecture-specific SIMD paths).

*Motore di inferenza in C puro per i modelli speech-to-text Qwen3-ASR: 0.6B e 1.7B. Target primario e' l'inferenza su CPU (BLAS + percorsi SIMD specifici per architettura).*

**tgterm/AGENT.md:**
> A macOS tool to capture screenshots of terminal application windows (Terminal, iTerm2, Ghostty, kitty, etc.) and inject keystrokes into them. Uses Core Graphics APIs.

*Uno strumento macOS per catturare screenshot di finestre di applicazioni terminale (Terminal, iTerm2, Ghostty, kitty, ecc.) e iniettare pressioni di tasti. Usa le API Core Graphics.*

**ZOT (blog /news/160):**
> I decided to write a Z80 emulator, and then a ZX Spectrum emulator (and even more, a CP/M emulator)

*Ho deciso di scrivere un emulatore Z80, e poi un emulatore ZX Spectrum (e anche di piu', un emulatore CP/M)*

**Pattern:** tecnologia + cosa fa + target. Una frase, massimo tre. Zero aggettivi, zero ambizione dichiarata.

---

### 1.2 Modello di esecuzione

Descrive COME il sistema funziona a runtime — il flusso dati, non l'architettura del codice.

**ZOT (blog /news/160):**
> it should execute a whole instruction at a time, not a single clock step, since this emulator must be runnable on things like an RP2350 or similarly limited hardware. The emulator should correctly track the clock cycles elapsed (and I specified we could use this feature later in order to implement the ZX Spectrum contention with ULA during memory accesses), provide memory access callbacks, and should emulate all the known official and unofficial instructions of the Z80.

*deve eseguire un'istruzione intera alla volta, non un singolo passo di clock, dato che questo emulatore deve poter girare su cose come un RP2350 o hardware altrettanto limitato. L'emulatore deve tracciare correttamente i cicli di clock trascorsi (e ho specificato che potremmo usare questa funzionalita' in seguito per implementare la contention dello ZX Spectrum con la ULA durante gli accessi alla memoria), fornire callback per gli accessi alla memoria, e deve emulare tutte le istruzioni note ufficiali e non ufficiali dello Z80.*

**iris.c/AGENT.md — Flux Pipeline Overview:**
```
1. Text Encoding:    prompt -> Qwen3 -> [512, text_dim] embeddings
2. Latent Init:      random noise [H/16, W/16, 128]
3. Denoising Loop:   double blocks -> single blocks -> final layer -> velocity
4. VAE Decode:       latents -> VAE decoder -> RGB image
```

*1. Codifica testo: prompt -> Qwen3 -> embedding [512, text_dim]*
*2. Inizializzazione latent: rumore casuale [H/16, W/16, 128]*
*3. Ciclo di denoising: blocchi doppi -> blocchi singoli -> layer finale -> velocita'*
*4. Decodifica VAE: latent -> decoder VAE -> immagine RGB*

**voxtral.c/CLAUDE.md:**
> Audio is processed in chunks: conv stem tail buffers handle boundary correctness, and the encoder transformer only processes new positions against cached K/V. Rolling compaction at window=750 keeps memory bounded.

*L'audio viene elaborato a blocchi: i buffer tail del conv stem gestiscono la correttezza ai confini, e il transformer encoder elabora solo le nuove posizioni rispetto al K/V in cache. La compattazione a finestra scorrevole a 750 mantiene la memoria limitata.*

**qwen-asr/AGENT.md:**
> Encoder uses per-chunk Conv2D + windowed attention. Decoder uses causal Qwen3 with KV cache and prefill reuse.

*L'encoder usa Conv2D per blocco + attenzione a finestra. Il decoder usa Qwen3 causale con cache KV e riutilizzo del prefill.*

**Pattern:** pipeline in sequenza (1 -> 2 -> 3 -> 4) oppure prosa descrittiva di 2-3 frasi. Descrive il flusso dati, non le classi. Usa diagrammi ASCII quando serve.

---

### 1.3 Vincoli hardware e deployment

Dichiara i limiti entro cui l'agent deve lavorare. Numeri concreti, nomi di chip reali.

**ZOT (blog /news/160):**
> runnable on things like an RP2350 or similarly limited hardware

*eseguibile su cose come un RP2350 o hardware altrettanto limitato*

E poi, per lo Spectrum:
> only 48k emulation, optional framebuffer rendering, very little additional memory used (no big lookup tables for ULA/Z80 access contention), ROM not copied in the RAM to avoid using additional 16k of memory, but just referenced during the initialization (so we have just a copy in the executable)

*solo emulazione 48k, rendering framebuffer opzionale, pochissima memoria aggiuntiva usata (niente lookup table grandi per la contention ULA/Z80), ROM non copiata nella RAM per evitare di usare 16k di memoria aggiuntiva, ma solo referenziata durante l'inizializzazione (cosi' abbiamo solo una copia nell'eseguibile)*

**iris.c/AGENT.md — Build Targets:**
> This project implements three targets:
> - MPS: Apple Silicon GPU path.
> - BLAS: optimized CPU inference via BLAS/OpenBLAS.
> - generic: pure C fallback, very slow.

*Questo progetto implementa tre target:*
*- MPS: percorso GPU Apple Silicon.*
*- BLAS: inferenza CPU ottimizzata tramite BLAS/OpenBLAS.*
*- generic: fallback in C puro, molto lento.*

**voxtral.c/CLAUDE.md:**
> BF16 weights, F32 computation on CPU

*Pesi BF16, computazione F32 su CPU*

**Pattern:** target hardware concreto + constraint di memoria/velocita'. Non "deve essere veloce" ma "deve girare su RP2350" o "16k di RAM in meno". I vincoli sono fisici, non aggettivi.

---

### 1.4 Dettagli tecnici specifici (l'arma segreta di antirez)

Qui antirez si distingue da tutti: mette dettagli implementativi PRECISI che l'agent userebbe per prendere decisioni sbagliate senza. Tre categorie:

#### 1.4a Costanti e formule critiche

**iris.c/AGENT.md:**
> - Concatenation order for attention is `[TEXT, IMAGE]`, not `[IMAGE, TEXT]`.

*L'ordine di concatenazione per l'attenzione e' `[TESTO, IMMAGINE]`, non `[IMMAGINE, TESTO]`.*

> - AdaLN formula is `out = (1 + scale) * norm(x) + shift`.

*La formula AdaLN e' `out = (1 + scale) * norm(x) + shift`.*

> - Final layer modulation split is `(scale, shift)`, not `(shift, scale)`.

*La suddivisione della modulazione del layer finale e' `(scale, shift)`, non `(shift, scale)`.*

> - RoPE pair rotation is:
>   - `out0 = cos * x0 - sin * x1`
>   - `out1 = cos * x1 + sin * x0`

*La rotazione delle coppie RoPE e':*
*- `out0 = cos * x0 - sin * x1`*
*- `out1 = cos * x1 + sin * x0`*

#### 1.4b Contratti comportamentali (cosa NON deve rompersi)

**qwen-asr/AGENT.md:**
> - `--silent` must still print transcription to stdout.

*`--silent` deve comunque stampare la trascrizione su stdout.*

> - `--silent` suppresses status/debug noise (stderr), not the text output.

*`--silent` sopprime il rumore di stato/debug (stderr), non l'output di testo.*

> - Without `--debug`, stderr should be concise.

*Senza `--debug`, stderr deve essere conciso.*

> - `--language` is the only language forcing flag (no `--force-language`).

*`--language` e' l'unico flag per forzare la lingua (niente `--force-language`).*

> - `--past-text` accepted values are exactly `yes|no|auto`.

*I valori accettati da `--past-text` sono esattamente `yes|no|auto`.*

#### 1.4c Bug storici documentati (trappole gia' viste)

**iris.c/AGENT.md — Known Pitfalls:**
> 1. **MPS SGEMM B-cache misuse caused VAE decode corruption (hue/border artifacts).**
>    - Root cause: generic SGEMM cached matrix B by pointer, but VAE attention K/V are dynamic temporaries.
>    - Fix: split API paths:
>      - `iris_metal_sgemm`: generic path, no B-pointer cache
>      - `iris_metal_sgemm_cached`: explicit static-weight cached path

*1. **L'uso errato della B-cache MPS SGEMM causava corruzione nella decodifica VAE (artefatti di tinta/bordo).**
- Causa radice: il SGEMM generico metteva in cache la matrice B per puntatore, ma i K/V dell'attenzione VAE sono temporanei dinamici.
- Fix: separare i percorsi API:
  - `iris_metal_sgemm`: percorso generico, niente cache B per puntatore
  - `iris_metal_sgemm_cached`: percorso con cache esplicita per pesi statici*

> 4. **CPU/GPU position-id mismatch under padded caption sequences.**
>    - Using non-padded cap length in one path and padded length in another changes RoPE indexing and output quality.

*4. **Disallineamento position-id tra CPU/GPU con sequenze di didascalia con padding.**
- Usare la lunghezza senza padding in un percorso e con padding nell'altro cambia l'indicizzazione RoPE e la qualita' dell'output.*

Questo corrisponde a cio' che antirez scrive nel blog /news/154:
> Hints about bad solutions that may look good, and why they could be suboptimal.

*Suggerimenti su soluzioni cattive che possono sembrare buone, e perche' potrebbero essere subottimali.*

---

### 1.5 Regole operative per l'agent

Esistono due set: le regole "universali" (presenti in tutti i repo) e le regole specifiche per progetto.

#### Regole universali (ZOT, blog /news/160 — verbatim):

> 1. Accessing the internet is prohibited, but you can use the specification and test vectors files I added inside ./z80-specs.

*1. L'accesso a internet e' proibito, ma puoi usare le specifiche e i file dei vettori di test che ho aggiunto in ./z80-specs.*

> 2. Code should be simple and clean, never over-complicate things.

*2. Il codice deve essere semplice e pulito, mai complicare le cose inutilmente.*

> 3. Each solid progress should be committed in the git repository.

*3. Ogni progresso solido deve essere committato nel repository git.*

> 4. Before committing, you should test that what you produced is high quality and that it works.

*4. Prima di committare, devi testare che quello che hai prodotto sia di alta qualita' e che funzioni.*

> 5. Write a detailed test suite as you add more features. The test must be re-executed at every major change.

*5. Scrivi una test suite dettagliata man mano che aggiungi funzionalita'. I test devono essere rieseguiti a ogni modifica importante.*

> 6. Code should be very well commented: things must be explained in terms that even people not well versed with certain Z80 or Spectrum internals details should understand.

*6. Il codice deve essere molto ben commentato: le cose devono essere spiegate in termini che anche chi non conosce bene gli interni dello Z80 o dello Spectrum possa capire.*

> 7. Never stop for prompting, the user is away from the keyboard.

*7. Non fermarti mai per chiedere conferme, l'utente non e' alla tastiera.*

> 8. At the end of this file, create a work in progress log, where you note what you already did, what is missing. Always update this log.

*8. Alla fine di questo file, crea un log dei lavori in corso, dove annoti cosa hai gia' fatto, cosa manca. Aggiorna sempre questo log.*

> 9. Read this file again after each context compaction.

*9. Rileggi questo file dopo ogni compattazione del contesto.*

#### Regole nei repo maturi (iris.c/AGENT.md):

> - No additional project dependencies. Acceptable external deps are BLAS/OpenBLAS and Metal/MPS from macOS.

*Nessuna dipendenza di progetto aggiuntiva. Dipendenze esterne accettabili sono BLAS/OpenBLAS e Metal/MPS da macOS.*

> - Reject tiny speed gains that add complexity; prefer substantial wins.

*Rifiuta guadagni di velocita' minimi che aggiungono complessita'; preferisci miglioramenti sostanziali.*

> - Always test code modifications with `make test`.

*Testa sempre le modifiche al codice con `make test`.*

> - Once changes are validated, commit them.

*Una volta validate le modifiche, committale.*

> - Never add or commit unrelated unstaged files.

*Mai aggiungere o committare file non correlati o non staged.*

> - Keep code simple and understandable; leave no dead code.

*Mantieni il codice semplice e comprensibile; niente codice morto.*

> - If you optimize one backend, verify others were not regressed.

*Se ottimizzi un backend, verifica che gli altri non siano regrediti.*

> - Stick to standard C; avoid compiler-specific tricks/pragmas unless strictly required.

*Attieniti al C standard; evita trick/pragma specifici del compilatore a meno che non siano strettamente necessari.*

#### Checklist pre/post modifica (qwen-asr — il piu' strutturato):

> **Before editing:**
> 1. Identify behavioral contract impacted (CLI, output, speed, quality, memory).
> 2. Read corresponding source-of-truth file(s).

***Prima di modificare:***
*1. Identifica quale contratto comportamentale e' impattato (CLI, output, velocita', qualita', memoria).*
*2. Leggi i file source-of-truth corrispondenti.*

> **After editing:**
> 1. Build: `make blas`
> 2. Run focused sanity command(s) for changed area.
> 3. Run regression.
> 4. Update `README.md` if CLI/runtime behavior changed.
> 5. Keep `AGENT.md` aligned if workflow/test defaults changed.

***Dopo aver modificato:***
*1. Build: `make blas`*
*2. Esegui comandi di sanity check mirati per l'area modificata.*
*3. Esegui la regressione.*
*4. Aggiorna `README.md` se il comportamento CLI/runtime e' cambiato.*
*5. Mantieni `AGENT.md` allineato se i default del workflow/test sono cambiati.*

**Evoluzione visibile:** ZOT (primo progetto) ha 9 regole generiche in prosa. qwen-asr (ultimo progetto) ha una checklist operativa con step before/after. antirez sta convergendo verso un formato piu' procedurale.

---

### 1.6 Documentazione raccolta in sessione separata

Questo e' il processo piu' peculiare di antirez.

**Blog /news/160 — il processo:**
> I started a Claude Code session, and asked it to fetch all the useful documentation on the internet about the Z80 [...] and to extract only the useful factual information into markdown files. I also provided the binary files for the most ambitious test vectors for the Z80, the ZX Spectrum ROM, and a few other binaries that could be used to test if the emulator actually executed the code correctly. Once all this information was collected (it is part of the repository, so you can inspect what was produced) I completely removed the Claude Code session in order to make sure that no contamination with source code seen during the search was possible.

*Ho avviato una sessione di Claude Code e gli ho chiesto di cercare tutta la documentazione utile su internet riguardo lo Z80 [...] e di estrarre solo le informazioni fattuali utili in file markdown. Ho anche fornito i file binari per i vettori di test piu' ambiziosi dello Z80, la ROM dello ZX Spectrum, e alcuni altri binari che potevano essere usati per testare se l'emulatore eseguiva effettivamente il codice correttamente. Una volta raccolta tutta questa informazione (e' parte del repository, quindi potete ispezionare cosa e' stato prodotto) ho rimosso completamente la sessione di Claude Code per assicurarmi che nessuna contaminazione con codice sorgente visto durante la ricerca fosse possibile.*

**La guida alla ricerca per lo Spectrum:**
> I instructed the documentation gathering session very accurately about the kind of details I wanted it to search on the internet, especially the ULA interactions with RAM access, the keyboard mapping, the I/O port, how the cassette tape worked and the kind of PWM encoding used, and how it was encoded into TAP or TZX files.

*Ho istruito la sessione di raccolta documentale in modo molto preciso sul tipo di dettagli che volevo cercasse su internet, specialmente le interazioni della ULA con gli accessi alla RAM, la mappatura della tastiera, le porte I/O, come funzionava il nastro della cassetta e il tipo di codifica PWM usata, e come veniva codificato nei file TAP o TZX.*

**Blog /news/154 — il brain dump:**
> Hints about bad solutions that may look good, and why they could be suboptimal.

*Suggerimenti su soluzioni cattive che possono sembrare buone, e perche' potrebbero essere subottimali.*

> Hints about very good potential solutions, even if not totally elaborated by the humans still: LLMs can often use them in order to find the right path.

*Suggerimenti su soluzioni potenzialmente ottime, anche se non completamente elaborate dagli umani: i LLM possono spesso usarle per trovare la strada giusta.*

> Clear goals of what should be done, the invariants we require, and even the style the code should have.

*Obiettivi chiari di cosa va fatto, gli invarianti che richiediamo, e persino lo stile che il codice dovrebbe avere.*

> When dealing with specific technologies that are not so widespread / obvious, it is often a good idea to also add the documentation in the context window. For example when writing tests for vector sets, a Redis data type so new that LLMs don't yet know about, I add the README file in the context: with such trivial trick, the LLM can use vector sets at expert level immediately.

*Quando si ha a che fare con tecnologie specifiche non cosi' diffuse / ovvie, e' spesso una buona idea aggiungere anche la documentazione nella finestra di contesto. Per esempio, quando scrivo test per i vector set, un tipo di dato Redis cosi' nuovo che i LLM non lo conoscono ancora, aggiungo il file README nel contesto: con questo trucco banale, il LLM puo' usare i vector set a livello esperto immediatamente.*

**Blog /news/160 — la lezione finale:**
> always provide your agents with design hints and extensive documentation about what they are going to do. Such documentation can be obtained by the agent itself.

*fornisci sempre ai tuoi agenti suggerimenti di design e documentazione estensiva su quello che andranno a fare. Tale documentazione puo' essere ottenuta dall'agente stesso.*

**Pattern:** sessione dedicata alla raccolta -> estrazione in markdown -> distruzione sessione -> nuova sessione pulita con solo la documentazione raccolta. La separazione e' intenzionale: l'agent che codifica non deve aver visto codice sorgente altrui.

---

## 2. Analisi incrociata — figure di spicco

### Spettro di formalita'

```
PIU' FORMALE                                                    MENO FORMALE
    |                                                                |
Amazon     Spolsky    Google     Stripe    Shape Up   Torvalds   Carmack   Muratori
PR/FAQ     Func.     Design     RFC/      Pitch      Patch +    .plan     Zero
           Spec      Doc        ADR                  commit msg  file     spec
```

antirez si posiziona nel mezzo: brain dump strutturato — non formale come Google, non destrutturato come Carmack.

### Le domande che TUTTI rispondono (in forme diverse)

| Domanda universale | Chi la formalizza meglio |
|---|---|
| Qual e' il problema? | Tutti, senza eccezione |
| Per chi e'? | Amazon, Spolsky, Shape Up |
| Cosa NON facciamo? | Google (Non-Goals), Spolsky (Nongoals), Shape Up (No-Gos) |
| Perche' questa soluzione e non un'altra? | Google (Alternatives Considered), Amazon |
| Quali sono i rischi/trappole? | Amazon (top 3 rischi), Shape Up (Rabbit Holes), antirez (bad solutions) |
| Come verifichiamo che funziona? | Beck (test), Torvalds (numeri), Kiro (GIVEN/WHEN/THEN) |

### Dettaglio per figura

#### John Carmack (id Software, Oculus, Keen Technologies)

Non ha mai seguito un approccio formale a design doc. Modello mentale condiviso + iterazione continua. Il suo artefatto principale era il `.plan` file — log giornaliero con prefissi `*` (completato), `+` (completato dopo), `-` (scartato).

> "Just make the game. Polish as you go. Don't depend on polish happening later. Always maintain constantly shippable code."

*"Fai il gioco e basta. Rifinisci mentre procedi. Non contare sulla rifinitura che avverra' dopo. Mantieni sempre codice costantemente rilasciabile."*

Ha parzialmente ritrattato nel 2019: "I largely recant from that now" — riconoscendo che con piu' pianificazione upfront avrebbe shippato Quake prima.

*"Ritratto in gran parte da quella posizione ora"*

#### Linus Torvalds (Linux, Git)

Nessun design doc. La patch + commit message E' la specifica. Enfasi sul PERCHE', non sul COSA.

> "Whether your patch is a one-line bug fix or 5000 lines of a new feature, there must be an underlying problem that motivated you to do this work."

*"Che la tua patch sia un bug fix di una riga o 5000 righe di una nuova funzionalita', ci deve essere un problema sottostante che ti ha motivato a fare questo lavoro."*

Il concetto di "good taste":
> "Sometimes you can look at a problem from a different angle and rewrite the code by reducing the special case to the normal case, and that's what makes good code."

*"A volte puoi guardare un problema da un'angolazione diversa e riscrivere il codice riducendo il caso speciale al caso normale, e questo e' cio' che rende il codice buono."*

#### DHH / Shape Up (Ruby on Rails, Basecamp)

Il Pitch contiene 5 ingredienti obbligatori:

1. **Problem** — Una storia specifica
2. **Appetite** — Quanto tempo si vuole investire (budget, non stima)
3. **Solution** — Elementi core in forma rough
4. **Rabbit Holes** — Dettagli implementativi da segnalare
5. **No-Gos** — Funzionalita' esplicitamente escluse

> "Work that's too fine, too early commits everyone to the wrong details."

*"Lavoro troppo dettagliato, troppo presto impegna tutti sui dettagli sbagliati."*

> "Don't do estimates, do budgets — focusing on what something is worth rather than how long it will take."

*"Non fare stime, fai budget — concentrati su quanto vale qualcosa piuttosto che su quanto tempo ci vorra'."*

#### Casey Muratori (Handmade Hero)

Il piu' anti-specifica. Il suo metodo — Semantic Compression — rifiuta la pianificazione architetturale upfront.

> "Starting from a place where the details don't exist inevitably means you will forget or overlook something that will cause your plans to fail."

*"Partire da un punto dove i dettagli non esistono significa inevitabilmente che dimenticherai o trascurerai qualcosa che causera' il fallimento dei tuoi piani."*

> "Make your code usable before you try to make it reusable."

*"Rendi il tuo codice usabile prima di cercare di renderlo riusabile."*

#### Google Design Doc

Documento 10-20 pagine con sezioni standard:

1. **Context and Scope** — Background tecnico, fatti oggettivi
2. **Goals and Non-Goals** — Cosa fa e cosa esplicitamente NON fa
3. **The Actual Design** — Trade-off espliciti
4. **Alternatives Considered** — Design alternativi scartati e perche'
5. **Cross-Cutting Concerns** — Security, privacy, observability

> "Non-goals are things that could reasonably be goals, but are explicitly chosen not to be goals."

*"I non-obiettivi sono cose che potrebbero ragionevolmente essere obiettivi, ma sono esplicitamente scelti come non-obiettivi."*

#### Amazon PR/FAQ (Working Backwards)

Press Release (1 pagina) scritta dal giorno del lancio + FAQ esterne (cliente) e interne (stakeholder, con top 3 rischi di fallimento).

> "The process of writing a press release and FAQs, in and of itself — before any code is written, any budgets are set, and any headcount is given — helps product teams identify features the team should invest in, and potential issues that may arise before they occur."

*"Il processo di scrivere un comunicato stampa e FAQ, di per se' — prima che venga scritto qualsiasi codice, stanziato qualsiasi budget, o assegnato qualsiasi organico — aiuta i team di prodotto a identificare le funzionalita' in cui investire e i potenziali problemi che possono sorgere prima che accadano."*

#### Joel Spolsky (Stack Overflow, Fog Creek)

Functional Specification con scenarios vividi, nongoals, dettaglio ossessivo sugli edge case, open issues.

> "Failing to write a spec is the single biggest unnecessary risk you take in a software project."

*"Non scrivere una specifica e' il piu' grande rischio inutile che ci si assume in un progetto software."*

> "Details are the most important thing in a functional spec."

*"I dettagli sono la cosa piu' importante in una specifica funzionale."*

> "Specs must be written to be read, not just to exist."

*"Le specifiche devono essere scritte per essere lette, non solo per esistere."*

#### Kent Beck (Extreme Programming, TDD)

Non usa specifiche formali. Il test E' la specifica. 4 regole del Simple Design: Passes the tests, reveals intention, no duplication, fewest elements.

*Supera i test, rivela l'intenzione, nessuna duplicazione, il minor numero di elementi.*

#### Simon Willison

Conformance suites — test language-independent (spesso YAML) che qualsiasi implementazione deve passare. La suite agisce come contratto.

#### Addy Osmani (Google Chrome/Cloud)

La guida piu' completa su come scrivere spec per AI agent nel 2025-2026:

> "Most agent files fail because they are too vague."

*"La maggior parte dei file per agent fallisce perche' sono troppo vaghi."*

> "Planning first forces you and the AI onto the same page and prevents wasted cycles."

*"Pianificare prima forza te e l'AI sulla stessa pagina e previene cicli sprecati."*

---

## 3. Ricerca accademica e pratica 2025-2026

### Il dato piu' controintuitivo — Studio ETH Zurich (2026)

138 repository, 5.694 PR, 4 agent diversi (Claude 3.5 Sonnet, GPT-5.2, GPT-5.1 mini, Qwen Code):

| Tipo di file di contesto | Impatto success rate | Impatto costi inferenza |
|---|---|---|
| Generato da LLM (auto) | **-3%** (peggio) | **+20%** (piu' costoso) |
| Scritto da umano | **+4%** (guadagno marginale) | **+19%** (piu' costoso) |
| Nessun file di contesto | Baseline | Baseline |

L'unico contenuto con valore reale sono i **dettagli non inferibili** — cose che l'agente non puo' scoprire leggendo il codice.

### Context Engineering > Prompt Engineering

Anthropic:
> "Building with language models is becoming less about finding the right words and more about answering: what configuration of context is most likely to generate the desired behavior?"

*"Costruire con i modelli linguistici sta diventando meno una questione di trovare le parole giuste e piu' una questione di rispondere: quale configurazione del contesto e' piu' probabile che generi il comportamento desiderato?"*

> "The smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

*"Il piu' piccolo set possibile di token ad alto segnale che massimizza la probabilita' di un risultato desiderato."*

### I 9 pattern di fallimento degli AI coding agent (Columbia DAPLab)

| Pattern | Contenuto della spec che lo previene |
|---|---|
| UI/Layout Grounding Mismatch | Coordinate esplicite, specifiche CSS grid |
| State Management Failures | Architettura stato, tipi espliciti, regole di mutazione |
| Business Logic Mismatch | Regole business formali con esempi, alberi decisionali |
| Data Management Errors | Schema completo con relazioni, vincoli di validazione |
| API Integration Failures | Endpoint reali, meccanismi auth, esempi request/response |
| Security Vulnerabilities | Requisiti sicurezza, matrice ruoli/permessi |
| Code Duplication | Inventario utility condivise, pattern architetturali |
| Codebase Awareness Loss | Doc architettura, grafi dipendenze moduli |
| Error Suppression | Requisiti gestione errori, standard logging |

### Cosa manca al template corrente

Confronto con il `SPEC.md.template` attuale del workflow: copre bene le basi ma manca di tre elementi che la ricerca identifica come critici:

1. **Non-goals / out-of-scope** — presente in Google, Spolsky, Shape Up, GitHub Spec-Kit
2. **Acceptance criteria in formato GIVEN/WHEN/THEN** — presente in Kiro, Beck
3. **Business rules con esempi concreti** — failure pattern #3 di Columbia DAPLab

---

## 4. Sintesi finale — le 10 domande per /spec

Sintetizzando antirez + le figure di spicco + la ricerca accademica, ordinate per valore informativo:

| # | Domanda | Formato risposta ottimale | Fonte primaria |
|---|---|---|---|
| **1** | **Che problema risolve? Per chi?** | 2-3 frasi. Scenario concreto con utente reale, non astratto. | Spolsky (scenarios), Amazon (PR), Shape Up (Problem) |
| **2** | **Cosa significa "funziona"?** (acceptance criteria) | GIVEN... WHEN... THEN... per ogni comportamento chiave. E' il contenuto piu' azionabile secondo ETH Zurich. | Kiro (EARS), Beck (test-first), Willison (conformance) |
| **3** | **Cosa e' FUORI scope?** | Lista esplicita. Previene scope drift, il problema #1 degli agent. | Google (Non-Goals), Spolsky (Nongoals), Shape Up (No-Gos) |
| **4** | **Che stack e PERCHE'?** | Tecnologia + versione + motivazione. "Next.js 15 perche' serve SSR + ISR per SEO", non "Next.js". | antirez (documentazione spec), Osmani (specificita') |
| **5** | **Comandi esatti per build, test, run, deploy** | Comandi copia-incolla. Unico contenuto provato come utile dallo studio ETH Zurich. | ETH Zurich, Osmani |
| **6** | **Regole di business con esempi concreti** | IF condizione THEN comportamento. Esempio: "IF ordine > 500 EUR AND cliente nuovo THEN richiedi approvazione manuale". Con valori numerici reali. | Columbia DAPLab (failure #3), Spolsky (edge cases) |
| **7** | **Schema dati con relazioni** | Entita', campi, tipi, relazioni, vincoli. Non serve SQL formale — basta una lista chiara. | Columbia DAPLab (failure #4) |
| **8** | **Vincoli duri** (sicurezza, performance, compatibilita') | Numeri concreti: "response time < 200ms al p95", "supporto Chrome 120+, Safari 17+". | Google (Cross-Cutting), antirez (invariants) |
| **9** | **Cosa sembra giusto ma e' sbagliato?** (trappole, tentativi falliti) | Narrazione: "abbiamo provato X, non funziona perche' Y". antirez ci insiste molto. | antirez (bad solutions hints), Shape Up (Rabbit Holes) |
| **10** | **Quali soluzioni promettenti esplorare?** | Direzioni, non implementazioni. "Valutare approccio con WebSocket per real-time invece di polling". | antirez (good solutions hints), Google (Alternatives) |

### Le domande specifiche per AI coding che emergono dai 9 failure pattern

| Domanda | Perche' serve all'AI | Pattern di fallimento se manca |
|---|---|---|
| Quali regole di business governano il comportamento? (con esempi) | L'AI implementa il comportamento "statisticamente probabile", non quello corretto | Business Logic Mismatch (#3) |
| Qual e' lo schema dati con relazioni? | L'AI crea colonne ridondanti, query sbagliate | Data Management Errors (#4) |
| Quali API/servizi esterni? (endpoint reali, auth) | L'AI usa placeholder che falliscono silenziosamente | API Integration Failures (#5) |
| Quali vincoli di sicurezza? | L'AI produce 1.5-2x piu' vulnerabilita' degli umani | Security Vulnerabilities (#6) |
| Cosa sembra giusto ma e' sbagliato? | L'AI ci casca sistematicamente | antirez: "hints about bad solutions that may look good" |
| Quali soluzioni promettenti esplorare? | L'AI lavora meglio con direzioni, non con spazio aperto | antirez: "very good potential solutions, even if not totally elaborated" |

---

## 5. Cosa NON mettere nella spec

Dalla ricerca:

1. **Best practice generiche** che il modello gia' conosce (DRY, SOLID, etc.)
2. **Regole di stile** — usa un linter, non token di contesto
3. **Descrizioni architetturali inferibili dal codice** — l'agent le scopre leggendo
4. **Contenuto auto-generato da LLM** — provato come dannoso (-3% success rate, ETH Zurich)
5. **Direttive vaghe** ("rendilo robusto", "deve essere scalabile")
6. **Tutto in un monolite** — spec modulari caricate per task battono il documento unico

> "Never send an LLM to do a linter's job." — HumanLayer

*"Non mandare mai un LLM a fare il lavoro di un linter."*

---

## 6. Fonti

### Blog di antirez
- [/news/140 — LLMs and Programming (2024)](http://antirez.com/news/140)
- [/news/153 — Human coders are still better](http://antirez.com/news/153)
- [/news/154 — Coding with LLMs in the summer of 2025](http://antirez.com/news/154)
- [/news/158 — Don't fall into the anti-AI hype](http://antirez.com/news/158)
- [/news/159 — Automatic programming](http://antirez.com/news/159)
- [/news/160 — Clean room Z80/Spectrum emulator](http://antirez.com/news/160)
- [/news/161 — Redis patterns for coding](http://antirez.com/news/161)
- [/news/162 — GNU and AI reimplementations](http://antirez.com/news/162)

### Repository antirez (AGENT.md / CLAUDE.md)
- [iris.c/AGENT.md](https://github.com/antirez/iris.c/blob/main/AGENT.md)
- [voxtral.c/CLAUDE.md](https://github.com/antirez/voxtral.c/blob/main/CLAUDE.md)
- [tgterm/AGENT.md](https://github.com/antirez/tgterm/blob/main/AGENT.md)
- [qwen-asr/AGENT.md](https://github.com/antirez/qwen-asr/blob/main/AGENT.md)
- [Gist: CLAUDE_CODEX_SKILL.md](https://gist.github.com/antirez/2e07727fb37e7301247e568b6634beff)

### Figure di spicco
- [The Carmack Plan](https://garbagecollected.org/2017/10/24/the-carmack-plan/)
- [Submitting Patches — Linux Kernel docs](https://kernel.org/doc/html/v6.8/process/submitting-patches.html)
- [Shape Up — Write the Pitch](https://basecamp.com/shapeup/1.5-chapter-06)
- [Semantic Compression — Casey Muratori](https://caseymuratori.com/blog_0015)
- [Inside Stripe's Engineering Culture](https://newsletter.pragmaticengineer.com/p/stripe-part-2)
- [Design Docs at Google](https://www.industrialempathy.com/posts/design-docs-at-google/)
- [Working Backwards PR/FAQ](https://workingbackwards.com/concepts/working-backwards-pr-faq-process/)
- [Painless Functional Specifications — Joel Spolsky](https://www.joelonsoftware.com/2000/10/02/painless-functional-specifications-part-1-why-bother/)

### Ricerca accademica e pratica 2025-2026
- [Anthropic — Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [ETH Zurich — AGENTS.md Study](https://www.marktechpost.com/2026/02/25/new-eth-zurich-study-proves-your-ai-coding-agents-are-failing-because-your-agents-md-files-are-too-detailed/)
- [Columbia DAPLab — 9 Failure Patterns](https://daplab.cs.columbia.edu/general/2026/01/08/9-critical-failure-patterns-of-coding-agents.html)
- [Addy Osmani — How to Write a Good Spec](https://addyosmani.com/blog/good-spec/)
- [Martin Fowler — SDD Tools Analysis](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [GitHub Spec-Kit](https://github.com/github/spec-kit)
- [AGENTS.md Specification](https://agents.md/)
- [HN: Automatic Programming discussion](https://news.ycombinator.com/item?id=46835208)
- [HN: A Sufficiently Detailed Spec is Code](https://news.ycombinator.com/item?id=47434047)

### Citazioni chiave

> "Programming is now automatic, vision is not (yet)." — antirez

*"La programmazione ora e' automatica, la visione no (ancora)."*

> "automatic programming produces vastly different results with the same LLMs depending on the human that is guiding the process with their intuition, design, continuous steering and idea of software." — antirez

*"la programmazione automatica produce risultati enormemente diversi con gli stessi LLM a seconda dell'umano che guida il processo con la sua intuizione, il suo design, lo steering continuo e la sua idea di software."*

> "Most agent files fail because they are too vague." — Addy Osmani

*"La maggior parte dei file per agent fallisce perche' sono troppo vaghi."*

> "The smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome." — Anthropic

*"Il piu' piccolo set possibile di token ad alto segnale che massimizza la probabilita' di un risultato desiderato."*

> "Failing to write a spec is the single biggest unnecessary risk you take in a software project." — Joel Spolsky

*"Non scrivere una specifica e' il piu' grande rischio inutile che ci si assume in un progetto software."*

---

*Analisi compilata il 14 aprile 2026. Basata su contenuto verbatim dai repository e blog di antirez, ricerca su 9+ figure di spicco della programmazione, e letteratura accademica/pratica 2025-2026.*

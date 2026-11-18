# Specifiche di progetto — Caelestia Ubuntu Live ISO

## Obiettivo

Produrre e validare una ISO live Ubuntu LTS amd64 avviabile, con desktop Hyprland e Caelestia (Quickshell e componenti correlati), rete funzionante e installazione grafica sul disco virtuale. L'ISO deve poter essere provata in QEMU e i componenti devono essere riproducibili e tracciati.

## Macchina di sviluppo

- Host di riferimento: iMac Intel con macOS e QEMU per macOS.
- Host disponibile per lo sviluppo corrente: Mac Apple Silicon. I risultati di prestazioni raccolti su questo host non sono rappresentativi di un iMac Intel.
- Architettura guest/target: amd64 (x86_64), Ubuntu 24.04 LTS per il primo prototipo.
- Il sistema host non va modificato; installazione e build avvengono nel guest Linux amd64.
- Accelerazione CPU: preferire HVF su iMac Intel quando `qemu-system-x86_64 -accel help` lo dichiara disponibile. In ogni altro caso usare TCG con `thread=multi`. Il launcher consente l'override tramite `VM_ACCEL`.
- Risorse guest configurabili con `VM_CPUS`, `VM_MEMORY` e `VM_DISK_SIZE`; valori iniziali 8 vCPU, 16 GiB e disco qcow2 sparse da 100 GiB. Adeguare i valori alla RAM e ai core del singolo iMac, lasciando risorse al macOS host.
- UEFI x86_64 tramite firmware OVMF, disco virtio, rete user-mode con inoltro SSH locale. Nessuna scrittura su supporti fisici.

## Grafica

- Usare `virtio-vga` come dispositivo di base per la console desktop.
- L'accelerazione 3D (`virtio-vga-gl`/virgl o backend equivalente) è facoltativa e va attivata solo quando QEMU, backend grafico e host la supportano insieme. Il launcher attuale usa grafica 2D; non si assume che HVF abiliti la GPU guest.
- Verificare concretamente la disponibilità del dispositivo e il rendering nel guest sul modello iMac di riferimento. Se non disponibile, registrare l'esito e proseguire con rendering software.

## Requisiti del prodotto

- ISO live Ubuntu Desktop amd64 con desktop Caelestia/Hyprland e installer grafico.
- Pacchetti Debian per i componenti compilati da sorgente, con revisioni upstream fissate e licenze registrate.
- Configurazione coerente tra sessione live e sistema installato.
- Build e validazione ripetibili, con log, manifest, pacchetti e ISO sotto `artifacts/`.
- Verificare avvio live, rete, sessione grafica, installazione su disco virtuale, primo avvio installato e test automatizzati previsti dal piano.

## Sicurezza e limiti

- Ispezionare gli script upstream prima dell'esecuzione e non eseguire setup che scrivano direttamente nel sistema host.
- Non includere credenziali, chiavi SSH dell'host o dati personali nei guest e negli artefatti.
- Non dichiarare superato un criterio senza evidenza; annotare test non eseguiti e blocchi in `docs/progress.md`.
- Specifiche e stato correnti: vedere anche [progress.md](progress.md), [vm.md](vm.md) e [architecture-decision.md](architecture-decision.md).

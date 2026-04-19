# Asincronía y servicios en Flutter

## Conceptos

### 1. Future / async / await
- Permite ejecutar tareas asincrónicas sin bloquear la UI.
- Usado para llamadas a APIs o simulaciones con Future.delayed.

### 2. Timer
- Ejecuta código repetidamente cada intervalo de tiempo.
- Ideal para cronómetros o actualizaciones en tiempo real.
- Debe cancelarse en dispose().

### 3. Isolate
- Permite ejecutar tareas pesadas sin bloquear el hilo principal.
- Usa memoria separada y comunicación por mensajes.

---

## Flujo de pantallas

Home Menu
├── Async/Await Screen
│     └── Simula API + estados UI
│
├── Timer Screen
│     └── Cronómetro con start/pause/reset
│
└── Isolate Screen
└── Cálculo pesado en background

---

## Cuándo usar cada uno

| Herramienta | Uso |
|------------|-----|
| Future / async | I/O, APIs, archivos |
| Timer | eventos periódicos |
| Isolate | CPU pesado |
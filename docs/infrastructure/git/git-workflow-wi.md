# Developer Work Instruction – Git Workflow

## 1. Grundregeln

* Jedes eigenständige Projekt erhält ein eigenes Git-Repository.
* Niemals direkt auf `main` oder `develop` entwickeln oder pushen.
* Jede Änderung erfolgt über einen eigenen Branch.
* Jede Integration erfolgt über einen Pull Request.
* Code muss vor dem Merge geprüft, getestet und freigegeben werden.
* Nach erfolgreichem Merge wird der Arbeits-Branch gelöscht.

## 2. Branch-Struktur

```text
main
│
├── hotfix/*
│
└── develop
    ├── feature/*
    ├── bugfix/*
    └── release/*
```

### `main`

* Enthält ausschließlich freigegebenen Produktions-/Release-Code.
* Direkte Entwicklung auf `main` ist verboten.
* Releases und Hotfixes werden nach `main` integriert.

### `develop`

* Zentrale Integrations-Branch für die laufende Entwicklung.
* Neue Features und normale Bugfixes starten von `develop`.
* Direkte Entwicklung und direkte Pushes auf `develop` sind verboten.

### `feature/*`

Für neue Funktionen.

```text
feature/customer-management
feature/project-dashboard
```

Flow:

```text
develop
   ↓
feature/*
   ↓
Pull Request
   ↓
develop
```

### `bugfix/*`

Für Fehler im aktuellen Entwicklungsstand.

```text
bugfix/invoice-calculation
```

Flow:

```text
develop
   ↓
bugfix/*
   ↓
Pull Request
   ↓
develop
```

### `release/*`

Für die Vorbereitung eines Releases.

```text
release/1.0.0
```

* Wird von `develop` erstellt.
* Nur Stabilisierung und Release-Fixes.
* Keine neuen Features.

Flow:

```text
develop
   ↓
release/*
   ├──→ main
   └──→ develop
```

### `hotfix/*`

Für kritische Fehler in Production.

```text
hotfix/1.0.1
```

Flow:

```text
main
 ↓
hotfix/*
 ├──→ main
 └──→ develop
```

Die Branch-Struktur und Merge-Richtungen entsprechen dem beschriebenen GitFlow-Modell.

## 3. Pull-Request-Regeln

Für jede Änderung gilt:

1. Branch vom vorgesehenen Basis-Branch erstellen.
2. Änderung ausschließlich im eigenen Branch entwickeln.
3. Änderungen lokal testen.
4. Branch pushen.
5. Pull Request erstellen.
6. Ein anderer Entwickler führt das Code Review durch.
7. Automatisierte Tests müssen erfolgreich sein.
8. Merge-Konflikte müssen behoben sein.
9. Review-Kommentare müssen bearbeitet sein.
10. Pull Request muss freigegeben sein.
11. Erst danach darf der Branch Owner den Pull Request mergen.
12. Arbeits-Branch anschließend löschen.

Der zugrunde liegende PR-Workflow verlangt Review, Tests und Approval vor dem Merge.

## 4. Review-Regel

```text
Author
  ↓
Pull Request
  ↓
Reviewer
  ↓
Review + Tests
  ↓
Approval
  ↓
Author / Branch Owner
  ↓
Merge
```

* Der Autor erstellt den Pull Request.
* Der Autor genehmigt seinen eigenen Pull Request nicht.
* Mindestens ein anderer Entwickler muss den Code reviewen und freigeben.
* Ohne Approval kein Merge.
* Bei notwendigen Änderungen wird der Code angepasst und erneut geprüft.
* Erst nach erfolgreicher Prüfung darf gemerged werden.

## 5. Verbindliche Merge-Flows

```text
feature/* → develop
bugfix/*  → develop

release/* → main
release/* → develop

hotfix/*  → main
hotfix/*  → develop
```

Release- und Hotfix-Änderungen müssen zurück nach `develop`, damit der Entwicklungsstand nicht vom Produktionsstand abweicht.

## 6. Verboten

* Direkter Push auf `main`.
* Direkter Push auf `develop`.
* Entwicklung direkt auf `main`.
* Entwicklung direkt auf `develop`.
* Feature ohne eigenen Branch.
* Merge ohne Pull Request.
* Merge ohne Review.
* Merge ohne erfolgreiche Tests.
* Merge trotz ungelöster Konflikte.
* Eigenes Approval als erforderliches Review verwenden.
* Neue Features auf `release/*`.
* Production-Fixes nur auf `main` durchführen, ohne sie nach `develop` zurückzuführen.

## 7. Standard-Workflow

```text
develop
   ↓
feature/*
   ↓
Development
   ↓
Tests
   ↓
Pull Request
   ↓
Code Review
   ↓
Approval
   ↓
Merge
   ↓
develop
   ↓
release/*
   ↓
main
   ↓
Production
```

## 8. Quellen

1. Karm Patel – **Git Branching Strategies: A Comprehensive Guide**
   DEV Community, 16.03.2025
   https://dev.to/karmpatel/git-branching-strategies-a-comprehensive-guide-24kh

2. Ariel Camus / freeCodeCamp – **Follow these simple rules and you’ll become a Git and GitHub master**
   Medium, 10.08.2018
   https://medium.com/free-code-camp/follow-these-simple-rules-and-youll-become-a-git-and-github-master-e1045057468f

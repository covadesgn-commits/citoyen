# Architecture du Projet CoVaDeS Mobile

Ce projet respecte la **Clean Architecture** par domaine fonctionnel.
Chaque fonctionnalité est isolée dans un dossier `features/X/` avec 3 couches.

---

## Structure Générale

```
lib/
├── core/           → Noyau partagé
├── shared/         → Widgets et modèles réutilisables
├── features/       → Domaines métier
│   ├── auth/       → Authentification
│   └── citoyen/    → Espace Citoyen
└── main.dart       → Point d'entrée
```

---

## Les 3 Couches Clean Architecture

```
features/X/
├── domain/           COUCHE DOMAINE (règles métier, interfaces)
│   ├── repositories/ → Interfaces abstraites (contrats)
│   └── usecases/     → Cas d'usage (logique métier Pure)
│
├── data/             COUCHE DONNÉES (implémentation concrète)
│   └── repositories/ → Implémentation Supabase des interfaces domain
│
└── presentation/     COUCHE PRÉSENTATION (UI + State)
    ├── providers/    → Providers Riverpod (gestion d'état)
    └── screens/      → Widgets / Écrans Flutter
```

**Règle d'or :**
- `domain/` ne dépend de rien
- `data/` dépend de `domain/`
- `presentation/` dépend de `domain/` et `data/`

---

## Détail des Dossiers

### `core/`
| Dossier | Rôle |
|---------|------|
| `constants/` | Constantes globales (noms de routes, clés) |
| `services/` | Services transversaux (Supabase client, etc.) |
| `theme/` | Design system : couleurs (`app_colors.dart`), thème (`app_theme.dart`) |
| `utils/` | Utilitaires : `router.dart` (navigation go_router) |

### `shared/`
| Dossier | Rôle |
|---------|------|
| `models/` | Modèles de données communs à plusieurs features |
| `widgets/` | Widgets réutilisables (`CustomTextField`, `PrimaryButton`, `RoleCard`) |

---

## Feature : `auth/`

```
auth/
├── domain/repositories/auth_repository.dart          → Interface AuthRepository
├── data/repositories/supabase_auth_repository.dart   → Impl. Supabase (signIn, signUp, OAuth)
└── presentation/
    ├── providers/auth_providers.dart                  → Riverpod providers (authRepositoryProvider, authStateProvider)
    └── screens/
        ├── splash_screen.dart         → Écran de démarrage
        ├── profile_selection_screen.dart → Choix du profil (Citoyen, PME, etc.)
        ├── login_screen.dart          → Connexion (email + OAuth)
        ├── register_screen.dart       → Inscription multi-rôle
        └── success_screen.dart        → Confirmation d'inscription
```

---

## Feature : `citoyen/`

```
citoyen/
├── domain/
│   ├── repositories/   → (à implémenter : CitoyenRepositoryInterface)
│   └── usecases/       → (à implémenter : GetRecentActions, SubscribeToPME...)
├── data/repositories/supabase_citoyen_repository.dart
│   → CitoyenRepository : getAvailablePMEs(), subscribeToPME(), reportWaste(),
│                          getRecentReports(), getRecentSubscriptions()
└── presentation/
    ├── providers/citoyen_providers.dart
    │   → availablePMEsProvider, recentReportsProvider,
    │     recentSubscriptionsProvider, recentActionsProvider
    └── screens/
        ├── citoyen_shell_screen.dart      → Shell avec BottomNavigationBar
        ├── citoyen_home_screen.dart       → Tableau de bord principal
        ├── citoyen_placeholder_screens.dart → Écrans Prestation, Marketplace, Profil (WIP)
        ├── pme_subscription_screen.dart  → Abonnement aux PMEs
        └── report_waste_screen.dart      → Signalement de déchets
```

---

## Flux de données

```
UI (screens) ──watch──► Providers ──read──► Repository (data) ──► Supabase
                                              ▲
                                         Contrat défini dans
                                         domain/repositories
```

---

## Navigation (router.dart)

Le router **go_router** est dans `core/utils/router.dart`.
- Routes racines : `/splash`, `/login`, `/register/:role`, `/profile_selection`, `/success`
- Shell citoyen : `/` (accueil), `/prestation`, `/marketplace`, `/profil`
- Routes push : `/subscription`, `/report_waste`

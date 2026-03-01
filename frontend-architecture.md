# 🎨 Architecture Frontend — SaaS Chatbot WhatsApp IA Multi-Entreprises

---

## 1. Vue d'ensemble

Le frontend est une **Single Page Application (SPA)** construite avec **Next.js 14** (App Router). Elle constitue le tableau de bord web pour les entreprises clientes du SaaS. L'interface est responsive, sécurisée, et conçue pour une expérience multi-tenant fluide.

---

## 2. Stack Technique

| Couche | Technologie | Justification |
|---|---|---|
| Framework | Next.js 14 (App Router) | SSR/SSG, routing avancé, performance |
| Langage | TypeScript | Typage fort, maintenabilité |
| Styling | Tailwind CSS + shadcn/ui | Rapidité UI, composants accessibles |
| State Management | Zustand | Léger, simple, performant |
| Data Fetching | TanStack Query (React Query) | Cache, refetch, optimistic updates |
| Formulaires | React Hook Form + Zod | Validation robuste côté client |
| Auth | Supabase Auth (SSR) | JWT, sessions, OAuth intégré |
| HTTP Client | Axios | Intercepteurs, gestion erreurs centralisée |
| Graphiques | Recharts | Charts légers et personnalisables |
| Notifications | Sonner (toast) | UX fluide |
| Icons | Lucide React | Cohérence visuelle |
| Tests | Jest + React Testing Library | Tests unitaires et d'intégration |

---

## 3. Structure des Répertoires

```
src/
├── app/                          # Next.js App Router
│   ├── (auth)/                   # Groupe de routes publiques
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── register/
│   │   │   └── page.tsx
│   │   ├── forgot-password/
│   │   │   └── page.tsx
│   │   └── layout.tsx            # Layout auth (sans sidebar)
│   │
│   ├── (dashboard)/              # Groupe de routes protégées
│   │   ├── layout.tsx            # Layout principal avec sidebar
│   │   ├── page.tsx              # Redirect vers /dashboard
│   │   ├── dashboard/
│   │   │   └── page.tsx          # Vue d'ensemble
│   │   ├── onboarding/
│   │   │   └── page.tsx          # Configuration initiale entreprise
│   │   ├── whatsapp/
│   │   │   ├── connect/
│   │   │   │   └── page.tsx      # Connexion numéro WhatsApp
│   │   │   └── settings/
│   │   │       └── page.tsx      # Paramètres webhook
│   │   ├── ai-config/
│   │   │   └── page.tsx          # Configuration IA (prompt, tonalité, etc.)
│   │   ├── conversations/
│   │   │   ├── page.tsx          # Liste des conversations
│   │   │   └── [id]/
│   │   │       └── page.tsx      # Détail d'une conversation
│   │   ├── analytics/
│   │   │   └── page.tsx          # Statistiques & rapports
│   │   ├── billing/
│   │   │   ├── page.tsx          # Plan & abonnement
│   │   │   └── invoices/
│   │   │       └── page.tsx      # Historique factures
│   │   └── settings/
│   │       └── page.tsx          # Paramètres compte entreprise
│   │
│   ├── api/                      # API Routes Next.js (BFF)
│   │   └── webhooks/
│   │       └── stripe/
│   │           └── route.ts      # Webhook Stripe
│   │
│   ├── layout.tsx                # Root layout
│   └── globals.css
│
├── components/
│   ├── ui/                       # Composants shadcn/ui réexportés
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   ├── badge.tsx
│   │   ├── dialog.tsx
│   │   └── ...
│   │
│   ├── layout/
│   │   ├── Sidebar.tsx           # Navigation latérale
│   │   ├── Topbar.tsx            # Barre supérieure
│   │   ├── MobilNav.tsx          # Navigation mobile
│   │   └── PageHeader.tsx        # Header de page réutilisable
│   │
│   ├── auth/
│   │   ├── LoginForm.tsx
│   │   ├── RegisterForm.tsx
│   │   └── ResetPasswordForm.tsx
│   │
│   ├── onboarding/
│   │   ├── OnboardingWizard.tsx  # Stepper multi-étapes
│   │   ├── StepCompany.tsx
│   │   ├── StepWhatsApp.tsx
│   │   └── StepAIConfig.tsx
│   │
│   ├── conversations/
│   │   ├── ConversationList.tsx
│   │   ├── ConversationItem.tsx
│   │   ├── MessageBubble.tsx
│   │   ├── ChatHistory.tsx
│   │   └── SearchBar.tsx
│   │
│   ├── analytics/
│   │   ├── StatsCard.tsx
│   │   ├── MessagesChart.tsx
│   │   ├── ResponseTimeChart.tsx
│   │   └── AIUsageChart.tsx
│   │
│   ├── billing/
│   │   ├── PlanCard.tsx
│   │   ├── QuotaProgress.tsx
│   │   └── InvoiceTable.tsx
│   │
│   └── shared/
│       ├── LoadingSpinner.tsx
│       ├── EmptyState.tsx
│       ├── ErrorBoundary.tsx
│       ├── ConfirmDialog.tsx
│       └── StatusBadge.tsx
│
├── hooks/
│   ├── useAuth.ts                # Hook authentification
│   ├── useEntreprise.ts          # Hook données entreprise
│   ├── useConversations.ts       # Hook conversations
│   ├── useAnalytics.ts           # Hook statistiques
│   ├── useSubscription.ts        # Hook abonnement
│   └── useWhatsApp.ts            # Hook statut connexion WhatsApp
│
├── lib/
│   ├── supabase/
│   │   ├── client.ts             # Client Supabase (browser)
│   │   ├── server.ts             # Client Supabase (server)
│   │   └── middleware.ts         # Auth middleware SSR
│   ├── api/
│   │   ├── client.ts             # Instance Axios + intercepteurs
│   │   ├── entreprises.ts        # Appels API entreprises
│   │   ├── conversations.ts      # Appels API conversations
│   │   ├── analytics.ts          # Appels API analytics
│   │   └── billing.ts            # Appels API facturation
│   └── utils/
│       ├── formatDate.ts
│       ├── formatNumber.ts
│       └── cn.ts                 # Utility classnames
│
├── store/
│   ├── useAuthStore.ts           # État authentification global
│   ├── useEntrepriseStore.ts     # État entreprise courante
│   └── useUIStore.ts             # État UI (sidebar, modals)
│
├── types/
│   ├── entreprise.ts
│   ├── conversation.ts
│   ├── message.ts
│   ├── analytics.ts
│   └── subscription.ts
│
├── middleware.ts                 # Next.js middleware (protection routes)
└── constants/
    ├── plans.ts                  # Définition plans Basic/Pro/Premium
    └── routes.ts                 # Routes centralisées
```

---

## 4. Architecture des Pages

### 4.1 Flux d'Authentification

```
/ (root)
 └─ Vérification session (middleware)
     ├─ Non connecté → /login
     └─ Connecté
         ├─ Onboarding non complété → /onboarding
         └─ Onboarding complété → /dashboard
```

### 4.2 Onboarding (Wizard 3 étapes)

```
/onboarding
  Step 1: Informations entreprise
    - Nom, secteur, description
    - Tonalité souhaitée (formel / décontracté / technique)
    
  Step 2: Connexion WhatsApp
    - Saisie numéro WhatsApp Business
    - Validation webhook Meta
    - Test de connexion
    
  Step 3: Configuration IA
    - Prompt système personnalisé
    - Langue(s) supportée(s)
    - Heures d'ouverture
    - FAQ initiale
```

### 4.3 Dashboard Principal

```
/dashboard
  ┌─────────────────────────────────────────────┐
  │  KPIs du jour                               │
  │  [Conversations] [Messages] [Taux réponse]  │
  ├─────────────────────────────────────────────┤
  │  Graphique messages 7 derniers jours        │
  ├─────────────────────────────────────────────┤
  │  Quota restant (barre de progression)       │
  ├─────────────────────────────────────────────┤
  │  Dernières conversations (5 max)            │
  └─────────────────────────────────────────────┘
```

---

## 5. Gestion de l'État

### 5.1 Zustand Stores

```typescript
// store/useEntrepriseStore.ts
interface EntrepriseStore {
  entreprise: Entreprise | null;
  isLoading: boolean;
  setEntreprise: (e: Entreprise) => void;
  clearEntreprise: () => void;
}

// store/useAuthStore.ts
interface AuthStore {
  user: User | null;
  session: Session | null;
  setSession: (s: Session | null) => void;
}
```

### 5.2 TanStack Query — Stratégie de Cache

```typescript
// hooks/useConversations.ts
export const useConversations = (entrepriseId: string) => {
  return useQuery({
    queryKey: ['conversations', entrepriseId],
    queryFn: () => api.conversations.getAll(entrepriseId),
    staleTime: 30_000,        // 30 secondes avant refetch
    refetchInterval: 60_000,  // Polling toutes les 60 secondes
  });
};

// hooks/useAnalytics.ts
export const useAnalytics = (range: DateRange) => {
  return useQuery({
    queryKey: ['analytics', range],
    queryFn: () => api.analytics.get(range),
    staleTime: 5 * 60_000,   // 5 minutes (données moins critiques)
  });
};
```

---

## 6. Sécurité Frontend

### 6.1 Protection des Routes (Middleware)

```typescript
// middleware.ts
export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico|login|register).*)'],
};

export async function middleware(request: NextRequest) {
  const supabase = createMiddlewareClient({ req: request, res: NextResponse.next() });
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Vérification onboarding complété
  const onboardingDone = request.cookies.get('onboarding_done');
  if (!onboardingDone && !request.nextUrl.pathname.startsWith('/onboarding')) {
    return NextResponse.redirect(new URL('/onboarding', request.url));
  }

  return NextResponse.next();
}
```

### 6.2 Intercepteur Axios

```typescript
// lib/api/client.ts
axiosInstance.interceptors.request.use(async (config) => {
  const session = await supabase.auth.getSession();
  if (session.data.session?.access_token) {
    config.headers.Authorization = `Bearer ${session.data.session.access_token}`;
  }
  return config;
});

axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      supabase.auth.signOut();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### 6.3 Validation Formulaires (Zod)

```typescript
// Exemple : schéma configuration IA
const AIConfigSchema = z.object({
  systemPrompt: z.string().min(50, "Le prompt doit faire au moins 50 caractères").max(2000),
  language: z.enum(['fr', 'en', 'ar', 'es']),
  tone: z.enum(['formel', 'decontracte', 'technique']),
  openingHours: z.object({
    enabled: z.boolean(),
    start: z.string().regex(/^\d{2}:\d{2}$/),
    end: z.string().regex(/^\d{2}:\d{2}$/),
    timezone: z.string(),
  }),
  maxHistoryMessages: z.number().min(1).max(20).default(10),
});
```

---

## 7. Composants Clés

### 7.1 Composant QuotaProgress

```typescript
// Affiche la consommation du quota mensuel
interface QuotaProgressProps {
  used: number;
  limit: number;
  plan: 'basic' | 'pro' | 'premium';
}

// Couleurs dynamiques :
// < 70% → vert
// 70-90% → orange
// > 90% → rouge + alerte
```

### 7.2 Composant ChatHistory

```typescript
// Affiche l'historique d'une conversation en temps réel
// - Bulles colorées selon rôle (IA = bleu, client = gris)
// - Timestamp sur chaque message
// - Badge "IA" ou "Humain" sur les messages de l'assistant
// - Export CSV via bouton téléchargement
```

### 7.3 Composant OnboardingWizard

```typescript
// Stepper avec :
// - Validation par étape avant de passer à la suivante
// - Sauvegarde brouillon automatique (localStorage)
// - Barre de progression visuelle
// - Possibilité de revenir en arrière sans perdre les données
```

---

## 8. Internationalisation (i18n)

```
Support des langues de l'interface :
- Français (par défaut)
- Anglais
- Arabe (RTL supporté)

Librairie : next-intl
Dossier : /messages/fr.json, /messages/en.json, /messages/ar.json
```

---

## 9. Performance & Optimisations

| Optimisation | Méthode |
|---|---|
| Code splitting | Automatique via Next.js App Router |
| Images | next/image avec lazy loading |
| Polices | next/font avec self-hosting |
| Bundle size | Dynamic imports pour composants lourds (charts) |
| API calls | TanStack Query avec cache et déduplication |
| Re-renders | useMemo / useCallback sur composants coûteux |
| Skeleton loaders | Sur toutes les pages avec fetch asynchrone |

---

## 10. Tests

```
Tests unitaires (Jest + RTL) :
  - Composants UI critiques
  - Hooks personnalisés
  - Fonctions utilitaires
  - Validation schémas Zod

Tests E2E (Playwright) :
  - Flux inscription → onboarding → dashboard
  - Connexion WhatsApp
  - Visualisation conversations
  - Changement de plan

Seuil de couverture cible : > 70%
```

---

## 11. Variables d'Environnement

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
NEXT_PUBLIC_API_BASE_URL=https://api.mondomaine.com
NEXT_PUBLIC_APP_URL=https://app.mondomaine.com
STRIPE_PUBLISHABLE_KEY=pk_live_...
NEXT_PUBLIC_POSTHOG_KEY=phc_...   # Analytics produit (optionnel)
```

---

## 12. Déploiement

```
Plateforme recommandée : Vercel
  - Déploiement automatique depuis Git (main → production)
  - Preview deployments sur chaque PR
  - Edge Network CDN intégré
  - Variables d'env gérées dans le dashboard Vercel

Alternative : Netlify ou VPS avec Docker + Nginx
```

---

## 13. Conventions de Code

```
Nommage :
  - Composants : PascalCase (ex : ConversationList.tsx)
  - Hooks : camelCase préfixé "use" (ex : useConversations.ts)
  - Types : PascalCase dans /types/
  - Constantes : SCREAMING_SNAKE_CASE

Imports :
  - Absolus via alias "@/" configuré dans tsconfig
  - Ex : import { Button } from "@/components/ui/button"

Git :
  - Conventional Commits (feat:, fix:, chore:, docs:)
  - Branches : main, develop, feature/*, fix/*
```

---

*Document généré pour le projet SaaS Chatbot WhatsApp IA — Version 1.0*

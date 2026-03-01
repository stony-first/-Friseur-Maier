# 🎨 Architecture Frontend — SaaS Chatbot WhatsApp IA Multi-Entreprises

---

## 1. Vue d'ensemble

Le frontend est une **Single Page Application (SPA)** construite avec **React.js 18 + Vite**. Elle constitue le tableau de bord web pour les entreprises clientes du SaaS. L'interface est responsive, sécurisée, et conçue pour une expérience multi-tenant fluide.

---

## 2. Stack Technique

| Couche | Technologie | Justification |
|---|---|---|
| Framework | React.js 18 | SPA, écosystème riche, composants réactifs |
| Bundler | Vite 5 | Build ultra-rapide, HMR instantané |
| Langage | TypeScript | Typage fort, maintenabilité |
| Routing | React Router v6 | Routing déclaratif, layouts imbriqués |
| Styling | Tailwind CSS + shadcn/ui | Rapidité UI, composants accessibles |
| State Management | Zustand | Léger, simple, performant |
| Data Fetching | TanStack Query (React Query) | Cache, refetch, optimistic updates |
| Formulaires | React Hook Form + Zod | Validation robuste côté client |
| Auth | Supabase Auth (client) | JWT, sessions, OAuth intégré |
| HTTP Client | Axios | Intercepteurs, gestion erreurs centralisée |
| Graphiques | Recharts | Charts légers et personnalisables |
| Notifications | Sonner (toast) | UX fluide |
| Icons | Lucide React | Cohérence visuelle |
| Tests | Vitest + React Testing Library | Tests unitaires et d'intégration |

---

## 3. Structure des Répertoires

```
src/
├── main.tsx                        # Point d'entrée React
├── App.tsx                         # Composant racine + providers
├── router.tsx                      # Définition des routes React Router
│
├── pages/
│   ├── auth/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── ForgotPasswordPage.tsx
│   │   └── ResetPasswordPage.tsx
│   │
│   ├── onboarding/
│   │   └── OnboardingPage.tsx      # Wizard configuration initiale
│   │
│   ├── dashboard/
│   │   └── DashboardPage.tsx       # Vue d'ensemble KPIs
│   │
│   ├── whatsapp/
│   │   ├── WhatsAppConnectPage.tsx
│   │   └── WhatsAppSettingsPage.tsx
│   │
│   ├── ai-config/
│   │   └── AIConfigPage.tsx        # Configuration IA (prompt, tonalité…)
│   │
│   ├── conversations/
│   │   ├── ConversationsPage.tsx
│   │   └── ConversationDetailPage.tsx
│   │
│   ├── analytics/
│   │   └── AnalyticsPage.tsx
│   │
│   ├── billing/
│   │   ├── BillingPage.tsx
│   │   └── InvoicesPage.tsx
│   │
│   ├── settings/
│   │   └── SettingsPage.tsx
│   │
│   └── errors/
│       ├── NotFoundPage.tsx
│       └── UnauthorizedPage.tsx
│
├── layouts/
│   ├── AuthLayout.tsx              # Layout pages publiques (login, register)
│   ├── DashboardLayout.tsx         # Layout principal (sidebar + topbar)
│   └── OnboardingLayout.tsx        # Layout onboarding (sans sidebar)
│
├── components/
│   ├── ui/                         # Composants shadcn/ui réexportés
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   ├── badge.tsx
│   │   ├── dialog.tsx
│   │   ├── progress.tsx
│   │   ├── select.tsx
│   │   ├── textarea.tsx
│   │   ├── table.tsx
│   │   └── ...
│   │
│   ├── layout/
│   │   ├── Sidebar.tsx
│   │   ├── Topbar.tsx
│   │   ├── MobileNav.tsx
│   │   └── PageHeader.tsx
│   │
│   ├── auth/
│   │   ├── LoginForm.tsx
│   │   ├── RegisterForm.tsx
│   │   └── ResetPasswordForm.tsx
│   │
│   ├── onboarding/
│   │   ├── OnboardingWizard.tsx
│   │   ├── StepCompanyInfo.tsx
│   │   ├── StepWhatsApp.tsx
│   │   └── StepAIConfig.tsx
│   │
│   ├── conversations/
│   │   ├── ConversationList.tsx
│   │   ├── ConversationItem.tsx
│   │   ├── MessageBubble.tsx
│   │   ├── ChatHistory.tsx
│   │   ├── HandoffButton.tsx
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
│       ├── SkeletonCard.tsx
│       ├── EmptyState.tsx
│       ├── ErrorBoundary.tsx
│       ├── ConfirmDialog.tsx
│       ├── AuthGuard.tsx
│       ├── OnboardingGuard.tsx
│       └── StatusBadge.tsx
│
├── hooks/
│   ├── useAuth.ts
│   ├── useEntreprise.ts
│   ├── useConversations.ts
│   ├── useConversationDetail.ts
│   ├── useAnalytics.ts
│   ├── useSubscription.ts
│   └── useWhatsApp.ts
│
├── lib/
│   ├── supabase.ts                 # Instance client Supabase
│   ├── api/
│   │   ├── client.ts               # Instance Axios + intercepteurs
│   │   ├── entreprises.api.ts
│   │   ├── conversations.api.ts
│   │   ├── analytics.api.ts
│   │   ├── aiConfig.api.ts
│   │   └── billing.api.ts
│   └── utils/
│       ├── formatDate.ts
│       ├── formatNumber.ts
│       ├── exportCSV.ts
│       └── cn.ts                   # clsx + tailwind-merge
│
├── store/
│   ├── useAuthStore.ts
│   ├── useEntrepriseStore.ts
│   └── useUIStore.ts
│
├── types/
│   ├── entreprise.types.ts
│   ├── conversation.types.ts
│   ├── message.types.ts
│   ├── analytics.types.ts
│   └── subscription.types.ts
│
├── constants/
│   ├── plans.ts
│   └── routes.ts
│
└── assets/
    ├── logo.svg
    └── illustrations/
```

---

## 4. Configuration Router (React Router v6)

```tsx
// router.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import React, { lazy, Suspense } from 'react';

// Lazy loading de toutes les pages (code splitting automatique)
const LoginPage            = lazy(() => import('./pages/auth/LoginPage'));
const RegisterPage         = lazy(() => import('./pages/auth/RegisterPage'));
const OnboardingPage       = lazy(() => import('./pages/onboarding/OnboardingPage'));
const DashboardPage        = lazy(() => import('./pages/dashboard/DashboardPage'));
const WhatsAppConnectPage  = lazy(() => import('./pages/whatsapp/WhatsAppConnectPage'));
const AIConfigPage         = lazy(() => import('./pages/ai-config/AIConfigPage'));
const ConversationsPage    = lazy(() => import('./pages/conversations/ConversationsPage'));
const ConversationDetailPage = lazy(() => import('./pages/conversations/ConversationDetailPage'));
const AnalyticsPage        = lazy(() => import('./pages/analytics/AnalyticsPage'));
const BillingPage          = lazy(() => import('./pages/billing/BillingPage'));
const SettingsPage         = lazy(() => import('./pages/settings/SettingsPage'));
const NotFoundPage         = lazy(() => import('./pages/errors/NotFoundPage'));

export const router = createBrowserRouter([
  // ── Routes publiques ──────────────────────────────────
  {
    element: <AuthLayout />,
    children: [
      { path: '/login',           element: <LoginPage /> },
      { path: '/register',        element: <RegisterPage /> },
      { path: '/forgot-password', element: <ForgotPasswordPage /> },
      { path: '/reset-password',  element: <ResetPasswordPage /> },
    ],
  },

  // ── Onboarding (protégé, sans sidebar) ───────────────
  {
    element: <AuthGuard><OnboardingLayout /></AuthGuard>,
    children: [
      { path: '/onboarding', element: <OnboardingPage /> },
    ],
  },

  // ── Dashboard (protégé + onboarding requis) ───────────
  {
    element: (
      <AuthGuard>
        <OnboardingGuard>
          <DashboardLayout />
        </OnboardingGuard>
      </AuthGuard>
    ),
    children: [
      { path: '/',                    element: <Navigate to="/dashboard" replace /> },
      { path: '/dashboard',           element: <DashboardPage /> },
      { path: '/whatsapp/connect',    element: <WhatsAppConnectPage /> },
      { path: '/whatsapp/settings',   element: <WhatsAppSettingsPage /> },
      { path: '/ai-config',           element: <AIConfigPage /> },
      { path: '/conversations',       element: <ConversationsPage /> },
      { path: '/conversations/:id',   element: <ConversationDetailPage /> },
      { path: '/analytics',           element: <AnalyticsPage /> },
      { path: '/billing',             element: <BillingPage /> },
      { path: '/billing/invoices',    element: <InvoicesPage /> },
      { path: '/settings',            element: <SettingsPage /> },
    ],
  },

  { path: '*', element: <NotFoundPage /> },
]);
```

---

## 5. Guards de Navigation

### 5.1 AuthGuard — Protection des routes privées

```tsx
// components/shared/AuthGuard.tsx
export function AuthGuard({ children }: { children: ReactNode }) {
  const { session, isLoading } = useAuthStore();

  if (isLoading) return <LoadingSpinner fullScreen />;
  if (!session)  return <Navigate to="/login" replace />;

  return <>{children}</>;
}
```

### 5.2 OnboardingGuard — Forçage onboarding initial

```tsx
// components/shared/OnboardingGuard.tsx
export function OnboardingGuard({ children }: { children: ReactNode }) {
  const { entreprise } = useEntrepriseStore();

  if (!entreprise?.onboardingDone) {
    return <Navigate to="/onboarding" replace />;
  }

  return <>{children}</>;
}
```

---

## 6. App.tsx — Providers

```tsx
// App.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { Toaster } from 'sonner';
import { router } from './router';
import { useInitAuth } from './hooks/useAuth';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: 2, refetchOnWindowFocus: false },
  },
});

function AuthInit({ children }: { children: ReactNode }) {
  useInitAuth(); // Initialise la session Supabase au démarrage
  return <>{children}</>;
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthInit>
        <RouterProvider router={router} />
        <Toaster richColors position="top-right" />
      </AuthInit>
    </QueryClientProvider>
  );
}
```

---

## 7. Gestion de l'État (Zustand)

```typescript
// store/useAuthStore.ts
import { create } from 'zustand';

interface AuthStore {
  user: User | null;
  session: Session | null;
  isLoading: boolean;
  setSession: (session: Session | null) => void;
  setLoading: (v: boolean) => void;
  signOut: () => Promise<void>;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  session: null,
  isLoading: true,
  setSession: (session) => set({ session, user: session?.user ?? null, isLoading: false }),
  setLoading: (isLoading) => set({ isLoading }),
  signOut: async () => {
    await supabase.auth.signOut();
    set({ session: null, user: null });
  },
}));

// store/useEntrepriseStore.ts
export const useEntrepriseStore = create<EntrepriseStore>((set) => ({
  entreprise: null,
  setEntreprise: (entreprise) => set({ entreprise }),
  clearEntreprise: () => set({ entreprise: null }),
}));

// store/useUIStore.ts
export const useUIStore = create<UIStore>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  activeModal: null,
  openModal: (name) => set({ activeModal: name }),
  closeModal: () => set({ activeModal: null }),
}));
```

---

## 8. TanStack Query — Stratégie de Cache

```typescript
// hooks/useConversations.ts
export const useConversations = (filters?: ConversationFilters) => {
  const { entreprise } = useEntrepriseStore();

  return useQuery({
    queryKey: ['conversations', entreprise?.id, filters],
    queryFn: () => conversationsApi.getAll(entreprise!.id, filters),
    staleTime: 30_000,        // 30s avant refetch automatique
    refetchInterval: 60_000,  // Polling toutes les 60 secondes
    enabled: !!entreprise?.id,
  });
};

// hooks/useAnalytics.ts
export const useAnalytics = (range: DateRange) => {
  const { entreprise } = useEntrepriseStore();

  return useQuery({
    queryKey: ['analytics', entreprise?.id, range],
    queryFn: () => analyticsApi.get(entreprise!.id, range),
    staleTime: 5 * 60_000,   // 5 minutes
    enabled: !!entreprise?.id,
  });
};

// Mutation exemple — mise à jour config IA
export const useUpdateAIConfig = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: AIConfigUpdate) => aiConfigApi.update(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ai-config'] });
      toast.success('Configuration IA mise à jour');
    },
    onError: () => toast.error('Erreur lors de la mise à jour'),
  });
};
```

---

## 9. Sécurité Frontend

### 9.1 Initialisation Auth Supabase

```typescript
// hooks/useAuth.ts
export function useInitAuth() {
  const { setSession, setLoading } = useAuthStore();
  const { setEntreprise } = useEntrepriseStore();

  useEffect(() => {
    // Récupération session au démarrage
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) fetchEntreprise(session.user.id).then(setEntreprise);
    });

    // Écoute des changements de session
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        setSession(session);
        if (event === 'SIGNED_IN' && session) {
          const entreprise = await fetchEntreprise(session.user.id);
          setEntreprise(entreprise);
        }
        if (event === 'SIGNED_OUT') {
          setEntreprise(null);
        }
      }
    );

    return () => subscription.unsubscribe();
  }, []);
}
```

### 9.2 Intercepteur Axios

```typescript
// lib/api/client.ts
const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15_000,
});

axiosInstance.interceptors.request.use(async (config) => {
  const { data: { session } } = await supabase.auth.getSession();
  if (session?.access_token) {
    config.headers.Authorization = `Bearer ${session.access_token}`;
  }
  return config;
});

axiosInstance.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await supabase.auth.signOut();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### 9.3 Validation Formulaires (Zod + React Hook Form)

```typescript
// Schéma configuration IA
const AIConfigSchema = z.object({
  systemPrompt: z.string().min(50).max(2000),
  language:     z.enum(['fr', 'en', 'ar', 'es']),
  tone:         z.enum(['formel', 'decontracte', 'technique']),
  openingHours: z.object({
    enabled:  z.boolean(),
    start:    z.string().regex(/^\d{2}:\d{2}$/).optional(),
    end:      z.string().regex(/^\d{2}:\d{2}$/).optional(),
    timezone: z.string(),
  }),
  maxHistoryMessages: z.number().min(1).max(20).default(10),
});

// Usage dans le composant AIConfigPage
const { register, handleSubmit, formState: { errors } } = useForm<AIConfigForm>({
  resolver: zodResolver(AIConfigSchema),
});
```

---

## 10. Onboarding (Wizard 3 étapes)

```
/onboarding
  ┌─────────────────────────────────────────┐
  │  ● Étape 1  ○ Étape 2  ○ Étape 3       │
  │  ─────────────────────────────────────  │
  │                                         │
  │  Step 1 — Informations entreprise       │
  │    Nom, secteur, description, tonalité  │
  │                                         │
  │  Step 2 — Connexion WhatsApp            │
  │    Numéro, génération webhook token     │
  │    Feedback statut connexion temps réel │
  │                                         │
  │  Step 3 — Configuration IA initiale     │
  │    Prompt système, langue, FAQ          │
  │    Heures d'ouverture                   │
  │                                         │
  │  [ Retour ]              [ Continuer ]  │
  └─────────────────────────────────────────┘

Comportements :
  - Validation Zod par étape avant passage à la suivante
  - Données sauvegardées en sessionStorage (anti-perte sur refresh)
  - Indicateur de chargement pendant les appels API
  - À la complétion : onboardingDone = true → redirect /dashboard
```

---

## 11. Dashboard Principal

```
/dashboard
  ┌─────────────────────────────────────────────────────┐
  │  KPIs du jour (4 cartes)                            │
  │  [Conversations] [Messages IA] [Taux réponse] [TTR] │
  ├─────────────────────────────────────────────────────┤
  │  Graphique messages — 7 derniers jours (Recharts)   │
  ├──────────────────────┬──────────────────────────────┤
  │  Quota mensuel       │  Statut WhatsApp             │
  │  [====75%====  ]     │  ● Connecté / ✕ Déconnecté  │
  ├──────────────────────┴──────────────────────────────┤
  │  Dernières conversations (5 max)                    │
  └─────────────────────────────────────────────────────┘
```

---

## 12. Performance & Optimisations

| Optimisation | Méthode |
|---|---|
| Code splitting | `React.lazy()` + `Suspense` sur chaque page |
| Bundle size | Dynamic imports pour Recharts |
| Images | `loading="lazy"` sur toutes les images |
| API calls | TanStack Query — cache et déduplication |
| Re-renders | `useMemo` / `useCallback` sur composants coûteux |
| Skeleton loaders | Sur toutes les sections avec données async |
| Vite build | Tree-shaking automatique, chunks par route |

```tsx
// Layout avec Suspense global
function DashboardLayout() {
  return (
    <div className="flex h-screen">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <Topbar />
        <Suspense fallback={<PageSkeleton />}>
          <Outlet />
        </Suspense>
      </main>
    </div>
  );
}
```

---

## 13. Composants Clés

### QuotaProgress

```tsx
interface QuotaProgressProps {
  used: number;
  limit: number;
  plan: 'basic' | 'pro' | 'premium';
}
// < 70%  → vert    (usage normal)
// 70-90% → orange  (attention)
// > 90%  → rouge + badge "Upgrader"
```

### ChatHistory

```tsx
// - Bulles colorées : IA = bleu, client = gris
// - Timestamp sur chaque message
// - Badge "IA" / "Humain" sur les réponses de l'assistant
// - Bouton export CSV
// - Bouton "Transférer à un humain" (si conversation ACTIVE)
```

### OnboardingWizard

```tsx
// - Barre de progression visuelle (Step 1 / 2 / 3)
// - Validation Zod par étape avant de continuer
// - Sauvegarde brouillon sessionStorage
// - Navigation retour sans perte de données
```

---

## 14. Internationalisation (i18n)

```
Librairie : react-i18next
Langues   : Français (défaut), Anglais, Arabe (RTL)
Dossier   : /public/locales/fr/translation.json
                             /en/translation.json
                             /ar/translation.json
```

---

## 15. Tests

```
Vitest + React Testing Library :
  - Composants : QuotaProgress, MessageBubble, PlanCard
  - Hooks      : useConversations, useAuth, useSubscription
  - Utils      : formatDate, exportCSV, cn
  - Schémas Zod

Playwright (E2E) :
  - Inscription → Onboarding → Dashboard
  - Connexion/déconnexion WhatsApp
  - Visualisation et export conversations
  - Upgrade de plan

Seuil de couverture cible : > 70%
```

---

## 16. Variables d'Environnement

```bash
# .env
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_API_BASE_URL=https://api.mondomaine.com
VITE_APP_URL=https://app.mondomaine.com
VITE_STRIPE_PUBLISHABLE_KEY=pk_live_...
VITE_POSTHOG_KEY=phc_...      # Analytics produit (optionnel)
```

---

## 17. Déploiement

```
Build production : npm run build → /dist (fichiers statiques)

Hébergement recommandé :
  Vercel   → déploiement automatique Git, CDN global, previews PR
  Netlify  → alternative similaire
  VPS+Nginx → servir /dist directement

Configuration Nginx (SPA fallback) :
  server {
    listen 80;
    root /var/www/dist;
    index index.html;
    location / { try_files $uri $uri/ /index.html; }
  }

CI/CD (GitHub Actions) :
  1. Push main → vitest (tests)
  2. npm run build
  3. Deploy /dist → Vercel ou Netlify
```

---

## 18. Conventions de Code

```
Nommage :
  Pages      → PascalCase + "Page"   (ConversationsPage.tsx)
  Layouts    → PascalCase + "Layout" (DashboardLayout.tsx)
  Composants → PascalCase            (ConversationItem.tsx)
  Hooks      → camelCase + "use"     (useConversations.ts)
  Types      → PascalCase            (conversation.types.ts)
  Constantes → SCREAMING_SNAKE_CASE

Imports (alias Vite) :
  "@/" configuré dans vite.config.ts + tsconfig.json
  Ex : import { Button } from "@/components/ui/button"

Git :
  Conventional Commits : feat:, fix:, chore:, docs:
  Branches : main, develop, feature/*, fix/*
```

---

*Document généré pour le projet SaaS Chatbot WhatsApp IA — Version 1.1 (React.js + Vite)*

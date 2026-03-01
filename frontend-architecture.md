# ðŸŽ¨ Architecture Frontend â€” SaaS Chatbot WhatsApp IA Multi-Entreprises

---

## 1. Vue d'ensemble

Le frontend est une **Single Page Application (SPA)** construite avec **React.js 18** (Vite + React Router). Elle constitue le tableau de bord web pour les entreprises clientes du SaaS. L'interface est responsive, sÃ©curisÃ©e, et conÃ§ue pour une expÃ©rience multi-tenant fluide.

---

## 2. Stack Technique

| Couche | Technologie | Justification |
|---|---|---|
| Framework | React.js 18 (Vite + React Router) | SSR/SSG, routing avancÃ©, performance |
| Langage | JavaScript (ES6+) | Simplicité, maintenabilité |
| Styling | Tailwind CSS + shadcn/ui | RapiditÃ© UI, composants accessibles |
| State Management | Zustand | LÃ©ger, simple, performant |
| Data Fetching | TanStack Query (React Query) | Cache, refetch, optimistic updates |
| Formulaires | React Hook Form + Zod | Validation robuste cÃ´tÃ© client |
| Auth | Supabase Auth (SPA/JWT) | JWT, sessions, OAuth intÃ©grÃ© |
| HTTP Client | Axios | Intercepteurs, gestion erreurs centralisÃ©e |
| Graphiques | Recharts | Charts lÃ©gers et personnalisables |
| Notifications | Sonner (toast) | UX fluide |
| Icons | Lucide React | CohÃ©rence visuelle |
| Tests | Jest + React Testing Library | Tests unitaires et d'intÃ©gration |

---

## 3. Structure des Répertoires

```
src/
├── main.jsx                     # Point d'entrée React
├── App.jsx                      # Router principal
├── pages/
│   ├── auth/
│   │   ├── LoginPage.jsx
│   │   ├── RegisterPage.jsx
│   │   └── ForgotPasswordPage.jsx
│   ├── dashboard/
│   │   ├── DashboardPage.jsx
│   │   ├── OnboardingPage.jsx
│   │   ├── WhatsAppConnectPage.jsx
│   │   ├── WhatsAppSettingsPage.jsx
│   │   ├── AIConfigPage.jsx
│   │   ├── ConversationsPage.jsx
│   │   ├── ConversationDetailPage.jsx
│   │   ├── AnalyticsPage.jsx
│   │   ├── BillingPage.jsx
│   │   ├── InvoicesPage.jsx
│   │   └── SettingsPage.jsx
├── routes/
│   ├── index.jsx                # Définition des routes React Router
│   └── ProtectedRoute.jsx       # Protection des routes privées
├── components/
│   ├── ui/
│   │   ├── button.jsx
│   │   ├── card.jsx
│   │   ├── input.jsx
│   │   ├── badge.jsx
│   │   ├── dialog.jsx
│   │   └── ...
│   ├── layout/
│   │   ├── Sidebar.jsx
│   │   ├── Topbar.jsx
│   │   ├── MobileNav.jsx
│   │   └── PageHeader.jsx
│   ├── auth/
│   │   ├── LoginForm.jsx
│   │   ├── RegisterForm.jsx
│   │   └── ResetPasswordForm.jsx
│   ├── onboarding/
│   │   ├── OnboardingWizard.jsx
│   │   ├── StepCompany.jsx
│   │   ├── StepWhatsApp.jsx
│   │   └── StepAIConfig.jsx
│   ├── conversations/
│   │   ├── ConversationList.jsx
│   │   ├── ConversationItem.jsx
│   │   ├── MessageBubble.jsx
│   │   ├── ChatHistory.jsx
│   │   └── SearchBar.jsx
│   ├── analytics/
│   │   ├── StatsCard.jsx
│   │   ├── MessagesChart.jsx
│   │   ├── ResponseTimeChart.jsx
│   │   └── AIUsageChart.jsx
│   ├── billing/
│   │   ├── PlanCard.jsx
│   │   ├── QuotaProgress.jsx
│   │   └── InvoiceTable.jsx
│   └── shared/
│       ├── LoadingSpinner.jsx
│       ├── EmptyState.jsx
│       ├── ErrorBoundary.jsx
│       ├── ConfirmDialog.jsx
│       └── StatusBadge.jsx
├── hooks/
│   ├── useAuth.js
│   ├── useEntreprise.js
│   ├── useConversations.js
│   ├── useAnalytics.js
│   ├── useSubscription.js
│   └── useWhatsApp.js
├── lib/
│   ├── supabase/
│   │   ├── client.js
│   │   └── auth.js
│   ├── api/
│   │   ├── client.js
│   │   ├── entreprises.js
│   │   ├── conversations.js
│   │   ├── analytics.js
│   │   └── billing.js
│   └── utils/
│       ├── formatDate.js
│       ├── formatNumber.js
│       └── cn.js
├── store/
│   ├── useAuthStore.js
│   ├── useEntrepriseStore.js
│   └── useUIStore.js
├── types/
│   ├── entreprise.js
│   ├── conversation.js
│   ├── message.js
│   ├── analytics.js
│   └── subscription.js
└── constants/
    ├── plans.js
    └── routes.js
```
---

## 4. Architecture des Pages

### 4.1 Flux d'Authentification

```
/ (root)
 â””â”€ VÃ©rification session (ProtectedRoute)
     â”œâ”€ Non connectÃ© â†’ /login
     â””â”€ ConnectÃ©
         â”œâ”€ Onboarding non complÃ©tÃ© â†’ /onboarding
         â””â”€ Onboarding complÃ©tÃ© â†’ /dashboard
```

### 4.2 Onboarding (Wizard 3 Ã©tapes)

```
/onboarding
  Step 1: Informations entreprise
    - Nom, secteur, description
    - TonalitÃ© souhaitÃ©e (formel / dÃ©contractÃ© / technique)
    
  Step 2: Connexion WhatsApp
    - Saisie numÃ©ro WhatsApp Business
    - Validation webhook Meta
    - Test de connexion
    
  Step 3: Configuration IA
    - Prompt systÃ¨me personnalisÃ©
    - Langue(s) supportÃ©e(s)
    - Heures d'ouverture
    - FAQ initiale
```

### 4.3 Dashboard Principal

```
/dashboard
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  KPIs du jour                               â”‚
  â”‚  [Conversations] [Messages] [Taux rÃ©ponse]  â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚  Graphique messages 7 derniers jours        â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚  Quota restant (barre de progression)       â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚  DerniÃ¨res conversations (5 max)            â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 5. Gestion de l'Ã‰tat

### 5.1 Zustand Stores

```javascript
// store/useEntrepriseStore.js
export const useEntrepriseStore = create((set) => ({
  entreprise: null,
  isLoading: false,
  setEntreprise: (entreprise) => set({ entreprise }),
  clearEntreprise: () => set({ entreprise: null }),
}));

// store/useAuthStore.js
export const useAuthStore = create((set) => ({
  user: null,
  session: null,
  onboardingDone: false,
  setSession: (session) => set({ session }),
}));
```

### 5.2 TanStack Query â€” StratÃ©gie de Cache

```javascript
// hooks/useConversations.js
export const useConversations = (entrepriseId) => {
  return useQuery({
    queryKey: ['conversations', entrepriseId],
    queryFn: () => api.conversations.getAll(entrepriseId),
    staleTime: 30_000,        // 30 secondes avant refetch
    refetchInterval: 60_000,  // Polling toutes les 60 secondes
  });
};

// hooks/useAnalytics.js
export const useAnalytics = (range) => {
  return useQuery({
    queryKey: ['analytics', range],
    queryFn: () => api.analytics.get(range),
    staleTime: 5 * 60_000,   // 5 minutes (données moins critiques)
  });
};
```

---

## 6. SÃ©curitÃ© Frontend

### 6.1 Protection des Routes (React Router)

```javascript
// routes/ProtectedRoute.jsx
import { Navigate } from 'react-router-dom';
import { useAuthStore } from '@/store/useAuthStore';

export default function ProtectedRoute({ children }) {
  const { session, onboardingDone } = useAuthStore();

  if (!session) {
    return <Navigate to="/login" replace />;
  }

  if (!onboardingDone && window.location.pathname !== '/onboarding') {
    return <Navigate to="/onboarding" replace />;
  }

  return children;
}
```
### 6.2 Intercepteur Axios

```javascript
// lib/api/client.js
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

```javascript
// Exemple : schÃ©ma configuration IA
const AIConfigSchema = z.object({
  systemPrompt: z.string().min(50, "Le prompt doit faire au moins 50 caractÃ¨res").max(2000),
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

## 7. Composants ClÃ©s

### 7.1 Composant QuotaProgress

```javascript
// Affiche la consommation du quota mensuel
const QuotaProgress = ({ used, limit, plan }) => {
  const ratio = (used / limit) * 100;
  return ratio;
};

// Couleurs dynamiques :
// < 70% → vert
// 70-90% → orange
// > 90% → rouge + alerte
```

### 7.2 Composant ChatHistory

```javascript
// Affiche l'historique d'une conversation en temps rÃ©el
// - Bulles colorÃ©es selon rÃ´le (IA = bleu, client = gris)
// - Timestamp sur chaque message
// - Badge "IA" ou "Humain" sur les messages de l'assistant
// - Export CSV via bouton tÃ©lÃ©chargement
```

### 7.3 Composant OnboardingWizard

```javascript
// Stepper avec :
// - Validation par Ã©tape avant de passer Ã  la suivante
// - Sauvegarde brouillon automatique (localStorage)
// - Barre de progression visuelle
// - PossibilitÃ© de revenir en arriÃ¨re sans perdre les donnÃ©es
```

---

## 8. Internationalisation (i18n)

```
Support des langues de l'interface :
- FranÃ§ais (par dÃ©faut)
- Anglais
- Arabe (RTL supportÃ©)

Librairie : react-i18next
Dossier : /messages/fr.json, /messages/en.json, /messages/ar.json
```

---

## 9. Performance & Optimisations

| Optimisation | MÃ©thode |
|---|---|
| Code splitting | Automatique via Vite + React.lazy |
| Images | Balises <img> optimisées + lazy loading natif |
| Polices | Google Fonts ou self-hosting via CSS |
| Bundle size | Dynamic imports pour composants lourds (charts) |
| API calls | TanStack Query avec cache et dÃ©duplication |
| Re-renders | useMemo / useCallback sur composants coÃ»teux |
| Skeleton loaders | Sur toutes les pages avec fetch asynchrone |

---

## 10. Tests

```
Tests unitaires (Jest + RTL) :
  - Composants UI critiques
  - Hooks personnalisÃ©s
  - Fonctions utilitaires
  - Validation schÃ©mas Zod

Tests E2E (Playwright) :
  - Flux inscription â†’ onboarding â†’ dashboard
  - Connexion WhatsApp
  - Visualisation conversations
  - Changement de plan

Seuil de couverture cible : > 70%
```

---

## 11. Variables d'Environnement

```bash
# .env.local
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_API_BASE_URL=https://api.mondomaine.com
VITE_APP_URL=https://app.mondomaine.com
STRIPE_PUBLISHABLE_KEY=pk_live_...
VITE_POSTHOG_KEY=phc_...   # Analytics produit (optionnel)
```

---

## 12. DÃ©ploiement

```
Plateforme recommandÃ©e : Vercel
  - DÃ©ploiement automatique depuis Git (main â†’ production)
  - Preview deployments sur chaque PR
  - Edge Network CDN intÃ©grÃ©
  - Variables d'env gÃ©rÃ©es dans le dashboard Vercel

Alternative : Netlify ou VPS avec Docker + Nginx
```

---

## 13. Conventions de Code

```
Nommage :
  - Composants : PascalCase (ex : ConversationList.jsx)
  - Hooks : camelCase prÃ©fixÃ© "use" (ex : useConversations.js)
  - Types : PascalCase dans /types/
  - Constantes : SCREAMING_SNAKE_CASE

Imports :
  - Absolus via alias "@/" configurÃ© dans jsconfig
  - Ex : import { Button } from "@/components/ui/button"

Git :
  - Conventional Commits (feat:, fix:, chore:, docs:)
  - Branches : main, develop, feature/*, fix/*
```

---

*Document gÃ©nÃ©rÃ© pour le projet SaaS Chatbot WhatsApp IA â€” Version 1.0*




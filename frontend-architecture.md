# 🖥️ SmartSalon AI — Architecture Frontend
> React + Vite + TailwindCSS + Zustand + TanStack Query + Supabase Auth

---

## 1. Structure du Projet

```
smartsalon-dashboard/
├── public/
│   ├── index.html
│   ├── manifest.json              # Config PWA
│   └── icons/
├── src/
│   ├── main.jsx                   # Point d'entrée React + Providers
│   ├── App.jsx                    # Router principal
│   │
│   ├── core/                      # Infrastructure transverse
│   │   ├── api/
│   │   │   ├── apiClient.js       # Instance Axios configurée (JWT, intercepteurs)
│   │   │   ├── endpoints.js       # Constantes de tous les endpoints
│   │   │   └── index.js           # Export centralisé des modules API
│   │   ├── auth/
│   │   │   ├── AuthContext.jsx    # Context React Auth
│   │   │   ├── AuthProvider.jsx   # Provider Supabase Auth
│   │   │   └── useAuth.js         # Hook d'accès au contexte auth
│   │   └── config.js              # Variables d'env publiques
│   │
│   ├── features/                  # Modules par domaine métier
│   │   ├── dashboard/
│   │   │   ├── DashboardPage.jsx
│   │   │   ├── components/
│   │   │   │   ├── StatsCards.jsx
│   │   │   │   ├── RecentBookings.jsx
│   │   │   │   └── AutomationRate.jsx
│   │   │   └── hooks/
│   │   │       └── useDashboard.js
│   │   │
│   │   ├── appointments/
│   │   │   ├── AppointmentsPage.jsx
│   │   │   ├── components/
│   │   │   │   ├── AppointmentCalendar.jsx
│   │   │   │   ├── BookingModal.jsx
│   │   │   │   ├── AppointmentCard.jsx
│   │   │   │   └── SlotPicker.jsx
│   │   │   └── hooks/
│   │   │       └── useAppointments.js
│   │   │
│   │   ├── services/
│   │   │   ├── ServicesPage.jsx
│   │   │   ├── components/
│   │   │   │   ├── ServiceList.jsx
│   │   │   │   └── ServiceForm.jsx
│   │   │   └── hooks/
│   │   │       └── useServices.js
│   │   │
│   │   ├── clients/
│   │   │   ├── ClientsPage.jsx
│   │   │   ├── components/
│   │   │   │   ├── ClientTable.jsx
│   │   │   │   └── ClientDetail.jsx
│   │   │   └── hooks/
│   │   │       └── useClients.js
│   │   │
│   │   ├── settings/
│   │   │   ├── SettingsPage.jsx
│   │   │   └── components/
│   │   │       ├── BusinessForm.jsx
│   │   │       ├── WorkingHoursForm.jsx
│   │   │       └── WhatsAppConfig.jsx
│   │   │
│   │   └── onboarding/
│   │       ├── OnboardingPage.jsx
│   │       └── steps/
│   │           ├── Step1_BusinessInfo.jsx
│   │           ├── Step2_Services.jsx
│   │           ├── Step3_WorkingHours.jsx
│   │           └── Step4_WhatsApp.jsx
│   │
│   ├── shared/                    # Composants et utilitaires réutilisables
│   │   ├── components/
│   │   │   ├── ui/                # Primitives du design system
│   │   │   │   ├── Button.jsx
│   │   │   │   ├── Input.jsx
│   │   │   │   ├── Modal.jsx
│   │   │   │   ├── Table.jsx
│   │   │   │   ├── Badge.jsx
│   │   │   │   ├── Spinner.jsx
│   │   │   │   ├── Select.jsx
│   │   │   │   └── Toast.jsx
│   │   │   └── layout/
│   │   │       ├── MainLayout.jsx
│   │   │       ├── Sidebar.jsx
│   │   │       └── Header.jsx
│   │   ├── hooks/
│   │   │   ├── useLocalStorage.js
│   │   │   ├── useDebounce.js
│   │   │   └── useMediaQuery.js
│   │   └── utils/
│   │       ├── dateUtils.js
│   │       ├── formatters.js
│   │       └── validators.js
│   │
│   └── store/                     # State global Zustand
│       ├── authStore.js
│       ├── businessStore.js
│       ├── appointmentsStore.js
│       ├── servicesStore.js
│       └── clientsStore.js
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── tailwind.config.js
├── vite.config.js
└── package.json
```

---

## 2. Architecture Pattern : Clean Architecture Simplifiée

Le frontend adopte une architecture **Feature-First** avec une séparation claire entre données, logique et présentation.

```
┌─────────────────────────────────────────────────────┐
│                     PAGES                           │  ← Composition + routing
│           DashboardPage, AppointmentsPage...        │
├─────────────────────────────────────────────────────┤
│                 FEATURE COMPONENTS                  │  ← UI propre à la feature
│         Calendar, BookingModal, ServiceForm...      │
├─────────────────────────────────────────────────────┤
│                  CUSTOM HOOKS                       │  ← Logique métier + effets
│      useAppointments, useServices, useDashboard...  │
├────────────────────────┬────────────────────────────┤
│     STORES (Zustand)   │       API LAYER            │  ← État global | HTTP
│  appointmentsStore     │   appointmentsAPI.js       │
│  businessStore         │   businessAPI.js           │
│  servicesStore         │   apiClient.js (Axios)     │
├────────────────────────┴────────────────────────────┤
│              SHARED COMPONENTS / UI                 │  ← Design System
│          Button, Input, Modal, Table, Badge...      │
└─────────────────────────────────────────────────────┘
```

| Couche | Responsabilité |
|--------|----------------|
| **Pages** | Composition des features, gestion du layout |
| **Feature Components** | Logique d'affichage spécifique à un domaine |
| **Custom Hooks** | Logique métier, effets de bord, appels API |
| **Stores (Zustand)** | État global partagé entre features |
| **API Layer** | Appels HTTP, transformation données, erreurs HTTP |
| **Shared Components** | Primitives UI réutilisables, design system |

---

## 3. State Management (Zustand + TanStack Query)

La gestion d'état est séparée en deux responsabilités strictes pour éviter les doubles sources de vérité:

- **Server state** (données API): TanStack Query (`useQuery`, `useMutation`, cache, invalidation, retry)
- **UI state** (état local cross-feature): Zustand (filtres, modal ouverte, date sélectionnée, préférences UI)

Règle d'architecture: une donnée venant du backend ne doit pas être stockée durablement dans Zustand.

### Business Store

```js
// store/businessStore.js
import { create } from 'zustand';
import { businessAPI } from '../core/api';

export const useBusinessStore = create((set, get) => ({
  business:  null,
  isLoading: false,
  error:     null,
  isSetupComplete: false,

  fetchBusiness: async () => {
    set({ isLoading: true, error: null });
    try {
      const data = await businessAPI.getMe();
      set({
        business: data,
        isLoading: false,
        isSetupComplete: !!data.config?.whatsapp_number
      });
    } catch (err) {
      set({ error: err.message, isLoading: false });
    }
  },

  updateConfig: async (config) => {
    const updated = await businessAPI.update(config);
    set({ business: updated, isSetupComplete: !!updated.config?.whatsapp_number });
  },
}));
```

### Appointments Store

```js
// store/appointmentsStore.js
export const useAppointmentsStore = create((set, get) => ({
  appointments:  [],
  selectedDate:  new Date(),
  filters:       { status: 'all' },
  isLoading:     false,

  setSelectedDate: (date) => {
    set({ selectedDate: date });
    get().fetchAppointments(date);
  },

  fetchAppointments: async (date) => {
    set({ isLoading: true });
    const data = await appointmentsAPI.list({ date: date.toISOString() });
    set({ appointments: data, isLoading: false });
  },

  addAppointment: (appointment) => {
    set(state => ({ appointments: [...state.appointments, appointment] }));
  },

  updateAppointment: async (id, changes) => {
    // Optimistic update
    set(state => ({
      appointments: state.appointments.map(a => a.id === id ? { ...a, ...changes } : a)
    }));
    try {
      await appointmentsAPI.update(id, changes);
    } catch (err) {
      // Rollback en cas d'erreur
      get().fetchAppointments(get().selectedDate);
      throw err;
    }
  },

  cancelAppointment: async (id) => {
    await get().updateAppointment(id, { status: 'cancelled' });
  },
}));
```

### Auth Store (session robuste)

```js
// store/authStore.js
export const useAuthStore = create((set) => ({
  user:      null,
  isReady:   false,
  isLoading: true,

  login: async (email, password) => {
    set({ isLoading: true });
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    set({ user: data.user, isLoading: false, isReady: true });
  },

  logout: async () => {
    await supabase.auth.signOut();
    set({ user: null, isReady: true, isLoading: false });
  },

  // Hydratation session via supabase.auth.getSession + onAuthStateChange
  setSession: (session) => set({
    user: session?.user || null,
    isReady: true,
    isLoading: false
  }),
}));
```

---

## 4. Data Layer — API Client

```js
// core/api/apiClient.js
import axios from 'axios';
import { supabase } from '../auth/supabaseClient';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/api/v1',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' }
});

// Injecter le token JWT automatiquement (source Supabase session)
apiClient.interceptors.request.use(async (config) => {
  const { data } = await supabase.auth.getSession();
  const token = data.session?.access_token;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Gérer l'expiration du token
apiClient.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    // Retourner l'erreur formatée
    const message = error.response?.data?.error?.message || error.message;
    return Promise.reject(new Error(message));
  }
);

export default apiClient;
```

```js
// core/query/queryClient.js
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,
      gcTime: 10 * 60_000,
      retry: 2,
      refetchOnWindowFocus: false
    },
    mutations: {
      retry: 1
    }
  }
});
```

```jsx
// main.jsx
<QueryClientProvider client={queryClient}>
  <App />
</QueryClientProvider>
```

### Timezone & dates

Tous les timestamps backend restent en UTC (`TIMESTAMPTZ`) et le frontend convertit à l'affichage avec la timezone du salon (`business.timezone`, ex: `Europe/Paris`).

```js
formatInTimeZone(appointment.scheduled_at, business.timezone, 'dd/MM/yyyy HH:mm')
```

```js
// core/api/appointments.api.js
export const appointmentsAPI = {
  list:           (params) => apiClient.get('/appointments', { params }),
  create:         (data)   => apiClient.post('/appointments', data),
  update:         (id, data) => apiClient.put(`/appointments/${id}`, data),
  cancel:         (id)     => apiClient.delete(`/appointments/${id}`),
  getSlots:       (date)   => apiClient.get('/appointments/slots', { params: { date } }),
};

// core/api/business.api.js
export const businessAPI = {
  getMe:   ()     => apiClient.get('/businesses/me'),
  update:  (data) => apiClient.put('/businesses/me', data),
  setup:   (data) => apiClient.post('/businesses/me/setup', data),
};
```

---

## 5. Navigation & Routing

```jsx
// App.jsx — React Router v6
function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Routes publiques */}
        <Route path="/login"    element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />

        {/* Routes protégées — nécessitent d'être connecté */}
        <Route element={<PrivateRoute />}>

          {/* Onboarding obligatoire si WhatsApp non configuré */}
          <Route path="/onboarding" element={<OnboardingPage />} />

          {/* Dashboard principal — redirige vers /onboarding si pas setup */}
          <Route element={<SetupGuard />}>
            <Route element={<MainLayout />}>
              <Route path="/"              element={<DashboardPage />} />
              <Route path="/appointments"  element={<AppointmentsPage />} />
              <Route path="/services"      element={<ServicesPage />} />
              <Route path="/clients"       element={<ClientsPage />} />
              <Route path="/settings"      element={<SettingsPage />} />
            </Route>
          </Route>
        </Route>

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}
```

```jsx
// PrivateRoute — vérifie l'authentification
function PrivateRoute() {
  const { user, isLoading } = useAuthStore();
  if (isLoading) return <FullPageSpinner />;
  return user ? <Outlet /> : <Navigate to="/login" replace />;
}

// SetupGuard — redirige si configuration initiale non faite
function SetupGuard() {
  const { isSetupComplete, isLoading } = useBusinessStore();
  if (isLoading) return <FullPageSpinner />;
  return isSetupComplete ? <Outlet /> : <Navigate to="/onboarding" replace />;
}
```

---

## 6. UI Components & Widgets

### Composant Calendar — Vue des rendez-vous

```jsx
// features/appointments/components/AppointmentCalendar.jsx
function AppointmentCalendar() {
  const { appointments, selectedDate, setSelectedDate, fetchAppointments } = useAppointmentsStore();
  const [view, setView] = useState('week'); // day | week | month
  const [bookingSlot, setBookingSlot] = useState(null);

  useEffect(() => {
    fetchAppointments(selectedDate);
  }, [selectedDate]);

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100">
      <CalendarToolbar
        date={selectedDate}
        view={view}
        onDateChange={setSelectedDate}
        onViewChange={setView}
      />
      <CalendarGrid
        date={selectedDate}
        view={view}
        appointments={appointments}
        onSlotClick={(slot) => setBookingSlot(slot)}
        onAppointmentClick={(appt) => openDetailModal(appt)}
      />
      {bookingSlot && (
        <BookingModal
          slot={bookingSlot}
          isOpen={!!bookingSlot}
          onClose={() => setBookingSlot(null)}
        />
      )}
    </div>
  );
}
```

### Composant OnboardingWizard — Configuration initiale

```jsx
// features/onboarding/OnboardingPage.jsx
const STEPS = [
  { id: 1, label: 'Informations salon',  icon: '🏪', component: Step1_BusinessInfo },
  { id: 2, label: 'Vos services',        icon: '✂️',  component: Step2_Services },
  { id: 3, label: 'Horaires',            icon: '🕐',  component: Step3_WorkingHours },
  { id: 4, label: 'WhatsApp',            icon: '📱',  component: Step4_WhatsApp },
];

function OnboardingPage() {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState({});
  const { updateConfig } = useBusinessStore();
  const navigate = useNavigate();

  const handleStepComplete = (stepData) => {
    const updated = { ...formData, ...stepData };
    setFormData(updated);

    if (currentStep === STEPS.length) {
      // Dernière étape — soumettre tout
      updateConfig(updated).then(() => navigate('/'));
    } else {
      setCurrentStep(s => s + 1);
    }
  };

  const StepComponent = STEPS[currentStep - 1].component;

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="w-full max-w-2xl bg-white rounded-2xl shadow-lg p-8">
        <StepIndicator steps={STEPS} currentStep={currentStep} />
        <StepComponent onComplete={handleStepComplete} data={formData} />
      </div>
    </div>
  );
}
```

### Tableau des composants principaux

| Composant | Feature | Description |
|-----------|---------|-------------|
| `StatsCards` | Dashboard | KPIs: RDV du jour, taux automatisation, revenus |
| `AppointmentCalendar` | Appointments | Vue jour/semaine/mois avec drag & drop |
| `BookingModal` | Appointments | Formulaire création RDV + sélection créneau |
| `SlotPicker` | Appointments | Grille de créneaux disponibles |
| `ServiceForm` | Services | CRUD services: nom, durée, prix, catégorie |
| `WorkingHoursForm` | Settings | Horaires par jour de la semaine |
| `WhatsAppConfig` | Settings | Saisie et validation numéro + token |
| `ClientTable` | Clients | Liste avec historique, dernière visite, statut |
| `OnboardingWizard` | Onboarding | Stepper 4 étapes de configuration initiale |

---

## 7. Platform-Specific Considerations

### Progressive Web App (PWA)

Le dashboard est configuré en **PWA** pour un accès mobile optimisé via navigateur.

```js
// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        name:        'SmartSalon AI',
        short_name:  'SmartSalon',
        description: 'Gérez vos rendez-vous avec l\'IA',
        theme_color: '#1A56DB',
        background_color: '#ffffff',
        display:     'standalone',
        start_url:   '/',
        icons: [
          { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/icon-512.png', sizes: '512x512', type: 'image/png' },
        ]
      },
      workbox: {
        runtimeCaching: [
          {
            urlPattern: /\/api\/v1\/(appointments|services|clients)/,
            handler: 'NetworkFirst',
            options: { cacheName: 'api-cache', expiration: { maxAgeSeconds: 300 } }
          },
          {
            urlPattern: /\.(js|css|png|jpg|svg|woff2)$/,
            handler: 'CacheFirst',
            options: { cacheName: 'assets-cache' }
          }
        ]
      }
    })
  ]
});
```

### Responsive Design

```js
// Breakpoints TailwindCSS utilisés
// sm:  640px  — Petits mobiles (rare, dashboard pensé pour tablette+)
// md:  768px  — Tablettes — sidebar collapse
// lg:  1024px — Desktop — sidebar visible, calendrier plein
// xl:  1280px — Large desktop — stats étendues

// Exemple : Sidebar responsive
function Sidebar() {
  const { isMobile } = useMediaQuery();
  return isMobile
    ? <MobileSidebarDrawer />
    : <DesktopSidebar />;
}
```

### Note Flutter (application mobile native)

Si une app mobile native est développée en Flutter, le même backend est réutilisé intégralement. Les adaptations côté Flutter seraient :

| Élément React | Équivalent Flutter |
|---------------|--------------------|
| Zustand stores | Riverpod providers |
| Axios + intercepteurs | Dio + interceptors |
| React Router | GoRouter |
| TailwindCSS | ThemeData + CustomWidgets |
| React Query | flutter_query |

---

## 8. Performance Optimizations

| Technique | Implémentation |
|-----------|----------------|
| **Code Splitting** | `React.lazy()` + `Suspense` sur chaque page/feature |
| **Memoïsation** | `useMemo`, `useCallback`, `React.memo` sur composants lourds |
| **Virtual Scroll** | `react-virtual` pour listes de +100 RDV ou clients |
| **Optimistic Updates** | Mise à jour UI immédiate avant confirmation serveur |
| **Query Cache** | TanStack Query pour cache intelligent des appels API |
| **Bundle Analysis** | Rollup Visualizer + tree shaking Vite automatique |
| **Image Optimization** | `loading="lazy"` natif + WebP pour avatars/logos |

```jsx
// Code splitting par feature — chaque page chargée à la demande
const DashboardPage    = React.lazy(() => import('./features/dashboard/DashboardPage'));
const AppointmentsPage = React.lazy(() => import('./features/appointments/AppointmentsPage'));
const ServicesPage     = React.lazy(() => import('./features/services/ServicesPage'));
const ClientsPage      = React.lazy(() => import('./features/clients/ClientsPage'));

function App() {
  return (
    <Suspense fallback={<PageSpinner />}>
      <Routes>
        <Route path="/"             element={<DashboardPage />} />
        <Route path="/appointments" element={<AppointmentsPage />} />
        <Route path="/services"     element={<ServicesPage />} />
        <Route path="/clients"      element={<ClientsPage />} />
      </Routes>
    </Suspense>
  );
}
```

```jsx
// Optimistic update + rollback automatique
const updateAppointment = async (id, changes) => {
  // 1. Update UI immédiatement
  set(state => ({
    appointments: state.appointments.map(a => a.id === id ? { ...a, ...changes } : a)
  }));

  try {
    // 2. Confirmer côté serveur
    await appointmentsAPI.update(id, changes);
  } catch (err) {
    // 3. Rollback si erreur
    toast.error('Erreur de mise à jour, annulation...');
    await get().fetchAppointments(get().selectedDate);
  }
};
```

---

## 9. Testing

| Type | Outil | Stratégie |
|------|-------|-----------|
| **Unit** | Vitest + Testing Library | Hooks et composants isolés |
| **Integration** | MSW (Mock Service Worker) | Mocker les appels API |
| **E2E** | Playwright | Flux complet: login → créer RDV → confirmer |
| **Visual Regression** | Storybook + Chromatic | Détecter régressions UI |
| **Accessibilité** | axe-playwright | Audit a11y automatique |

```jsx
// tests/unit/BookingModal.test.jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { server } from '../mocks/server'; // MSW

describe('BookingModal', () => {

  it('affiche les créneaux disponibles', async () => {
    render(<BookingModal isOpen date={new Date('2025-03-10')} />);

    await screen.findByText('10:00');
    expect(screen.getAllByRole('button', { name: /créneau/i })).toHaveLength(8);
  });

  it('soumet le formulaire et ferme la modal', async () => {
    const onClose = vi.fn();
    render(<BookingModal isOpen onClose={onClose} />);

    fireEvent.click(screen.getByText('14:00'));
    fireEvent.click(screen.getByText('Confirmer'));

    await waitFor(() => expect(onClose).toHaveBeenCalled());
  });

  it('affiche une erreur si le créneau est indisponible', async () => {
    server.use(rest.get('/appointments/slots', (req, res, ctx) =>
      res(ctx.json({ data: [] }))
    ));

    render(<BookingModal isOpen date={new Date()} />);
    await screen.findByText('Aucun créneau disponible ce jour');
  });
});
```

```js
// tests/hooks/useAppointments.test.js
import { renderHook, act } from '@testing-library/react';
import { useAppointmentsStore } from '../../store/appointmentsStore';

describe('appointmentsStore', () => {

  it('récupère les rendez-vous', async () => {
    const { result } = renderHook(() => useAppointmentsStore());

    await act(async () => {
      await result.current.fetchAppointments(new Date());
    });

    expect(result.current.appointments).toHaveLength(3);
    expect(result.current.isLoading).toBe(false);
  });
});
```

```js
// tests/e2e/booking.spec.js — Playwright
test('créer un rendez-vous depuis le dashboard', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name=email]',    'salon@test.com');
  await page.fill('[name=password]', 'password123');
  await page.click('button[type=submit]');

  await page.waitForURL('/');
  await page.click('[data-testid=new-booking-btn]');
  await page.click('[data-testid=slot-14h00]');
  await page.click('[data-testid=confirm-booking]');

  await expect(page.locator('[data-testid=success-toast]'))
    .toContainText('Rendez-vous confirmé');
});
```

---

## 10. Deployment

| Composant | Solution |
|-----------|----------|
| **Hébergement** | Vercel (CDN global, déploiement automatique) |
| **CI/CD** | GitHub Actions: lint → test → build → deploy |
| **Preview** | PR auto-déployée sur URL unique (Vercel feature) |
| **Domain** | `app.smartsalon.ai` avec HTTPS automatique |
| **Analytics** | Posthog ou Plausible (privacy-first) |
| **Error Tracking** | Sentry Frontend |

```bash
# Variables d'environnement (Vercel dashboard)
VITE_API_URL=https://api.smartsalon.ai
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGci...
VITE_ENV=production
```

```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend
on:
  push:
    branches: [frontend]
  pull_request:
    branches: [frontend]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }

      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run test -- --run
      - run: npm run build

  deploy:
    needs: ci
    if: github.ref == 'refs/heads/frontend'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token:      ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id:     ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args:       '--prod'
```

```js
// vite.config.js — Configuration build production
export default defineConfig({
  build: {
    outDir:     'dist',
    sourcemap:  false,
    minify:     'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor:   ['react', 'react-dom', 'react-router-dom'],
          ui:       ['@radix-ui/react-dialog', '@radix-ui/react-select'],
          calendar: ['date-fns', 'react-big-calendar'],
          charts:   ['recharts'],
        }
      }
    }
  }
});
```

---

## 11. Conclusion

L'architecture frontend SmartSalon AI repose sur quatre choix techniques structurants :

**Feature-First avec Clean Architecture** — L'organisation par domaine métier (appointments, services, clients, settings) plutôt que par type de fichier permet à chaque développeur de travailler sur une feature sans impacter les autres, et facilite l'ajout de nouvelles sections au dashboard.

**Séparation stricte des états** — TanStack Query gère le server state (cache, invalidation, retry) et Zustand gère uniquement l'état UI cross-feature. Cette règle réduit les incohérences et simplifie le debugging.

**Optimistic Updates systématiques** — Toutes les mutations (annuler RDV, modifier service, changer statut) mettent à jour l'UI instantanément puis confirment côté serveur, avec rollback automatique. Cela donne une réactivité perçue maximale aux gérants de salon.

**PWA + Code Splitting** — L'application se comporte comme une app native sur mobile sans passer par l'App Store, et le code splitting par feature maintient un First Contentful Paint sous 1.5s même sur connexion 3G.

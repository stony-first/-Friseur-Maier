# ⚙️ SmartSalon AI — Architecture Backend
> Node.js + Express + Supabase + WhatsApp Business API

---

## 1. Structure du Projet

```
smartsalon-backend/
├── src/
│   ├── app.js                        # Point d'entrée Express
│   ├── server.js                     # Démarrage serveur HTTP
│   ├── config/
│   │   ├── database.js               # Configuration Supabase
│   │   ├── whatsapp.js               # Config WhatsApp Business API
│   │   ├── ai.js                     # Config OpenAI / Claude
│   │   └── env.js                    # Variables d'environnement typées
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.routes.js
│   │   │   ├── auth.controller.js
│   │   │   ├── auth.service.js
│   │   │   └── auth.middleware.js
│   │   ├── businesses/
│   │   │   ├── businesses.routes.js
│   │   │   ├── businesses.controller.js
│   │   │   └── businesses.service.js
│   │   ├── appointments/
│   │   │   ├── appointments.routes.js
│   │   │   ├── appointments.controller.js
│   │   │   └── appointments.service.js
│   │   ├── services/
│   │   │   ├── services.routes.js
│   │   │   ├── services.controller.js
│   │   │   └── services.service.js
│   │   ├── clients/
│   │   │   ├── clients.routes.js
│   │   │   ├── clients.controller.js
│   │   │   └── clients.service.js
│   │   ├── whatsapp/
│   │   │   ├── whatsapp.routes.js
│   │   │   ├── whatsapp.controller.js
│   │   │   ├── whatsapp.service.js
│   │   │   └── whatsapp.templates.js
│   │   └── ai/
│   │       ├── ai.service.js
│   │       ├── ai.prompts.js
│   │       └── conversation.manager.js
│   ├── middleware/
│   │   ├── auth.middleware.js
│   │   ├── rateLimiter.js
│   │   ├── validator.js
│   │   ├── logger.js
│   │   └── errorHandler.js
│   ├── shared/
│   │   ├── constants.js
│   │   ├── utils.js
│   │   └── errors.js
│   └── jobs/
│       ├── reminder.job.js           # Rappels automatiques clients
│       └── cleanup.job.js            # Nettoyage conversations expirées
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── .env
├── .env.example
├── package.json
└── Dockerfile
```

---

## 2. Architecture en Couches

Le backend suit le pattern **MVC étendu** avec 4 couches strictement séparées.

| Couche | Fichiers | Responsabilité |
|--------|----------|----------------|
| **Routes** | `*.routes.js` | Définition endpoints, validation entrante, doc API |
| **Controllers** | `*.controller.js` | Orchestration req/res, HTTP status codes |
| **Services** | `*.service.js` | Logique métier pure, règles business |
| **Data** | Supabase client | Accès PostgreSQL, requêtes, mappage entités |

### Flux d'une requête

```
Client HTTP
    ↓
Express Router
    ↓
Middleware Pipeline (Auth → RateLimit → Validation)
    ↓
Controller  (req/res handling)
    ↓
Service     (Business Logic)
    ↓
Supabase    (Data Access)
    ↓
PostgreSQL  (Database)
```

### Architecture Multi-Tenant

Chaque requête est automatiquement **scopée au salon** via le middleware d'authentification. Le `business_id` extrait du JWT est injecté dans toutes les requêtes Supabase. Les **Row Level Security (RLS)** de Supabase garantissent l'isolation totale entre salons.

---

## 3. Middleware Pipeline

```js
// app.js — Pipeline complet dans l'ordre d'exécution

const app = express();

// === LAYER 1: Security ===
app.use(helmet());                          // Headers HTTP sécurisés
app.use(cors(corsOptions));                 // CORS configuré par domaine
app.use(express.json({ limit: '10mb' }));  // Body parsing

// === LAYER 2: Logging ===
app.use(morganLogger);                      // HTTP request logging
app.use(requestIdMiddleware);               // UUID unique par requête (x-request-id)

// === LAYER 3: Rate Limiting ===
app.use('/api/',     generalRateLimiter);   // 100 req/min par IP
app.use('/api/auth', authRateLimiter);      // 10 req/min
app.use('/webhook',  webhookRateLimiter);   // 1000 req/min

// === LAYER 4: Routes ===
app.use('/api/v1', apiRouter);
app.use('/webhook', webhookRouter);

// === LAYER 5: Error Handler ===
app.use(notFoundHandler);
app.use(globalErrorHandler);
```

### Middleware d'Authentification

```js
// middleware/auth.middleware.js
async function authenticate(req, res, next) {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) return res.status(401).json({ error: 'Token manquant' });

  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) return res.status(401).json({ error: 'Token invalide' });

  // Charger et injecter le contexte salon
  const { data: business } = await supabase
    .from('businesses')
    .select('*')
    .eq('owner_id', user.id)
    .single();

  req.user     = user;
  req.business = business; // disponible dans tous les controllers
  next();
}
```

---

## 4. Modèles de Données

### Table: `businesses`

```sql
CREATE TABLE businesses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id        UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name            VARCHAR(255) NOT NULL,
  whatsapp_number VARCHAR(20)  UNIQUE NOT NULL, -- Identifiant unique de l'IA
  phone           VARCHAR(20),
  email           VARCHAR(255),
  address         TEXT,
  city            VARCHAR(100),
  country         VARCHAR(100),
  config          JSONB DEFAULT '{}'::jsonb,    -- Horaires et paramètres métier (pas de secrets)
  ai_persona      TEXT,                          -- Nom personnalisé de l'IA
  is_active       BOOLEAN DEFAULT true,
  subscription    VARCHAR(50) DEFAULT 'free',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Structure du champ config (JSONB):
-- {
--   "working_hours": { "1": {"open":"09:00","close":"18:00"}, ... },
--   "working_days": [1,2,3,4,5],
--   "avg_service_duration": 45,
--   "timezone": "Europe/Paris",
--   "greeting_message": "Bonjour ! Je suis l'assistante de ...",
--   "language": "fr"
-- }
```

```sql
-- Secrets stockés séparément (jamais dans config JSONB)
CREATE TABLE business_credentials (
  business_id UUID PRIMARY KEY REFERENCES businesses(id) ON DELETE CASCADE,
  provider    VARCHAR(50) NOT NULL, -- whatsapp
  token_enc   TEXT NOT NULL,        -- token chiffré AES-256-GCM
  key_version INTEGER NOT NULL DEFAULT 1,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### Table: `salon_services`

```sql
CREATE TABLE salon_services (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
  name        VARCHAR(255) NOT NULL,
  description TEXT,
  duration    INTEGER NOT NULL,   -- en minutes
  price       DECIMAL(10,2),
  category    VARCHAR(100),       -- coupe | couleur | barbe | soin
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### Table: `clients`

```sql
CREATE TABLE clients (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id     UUID REFERENCES businesses(id) ON DELETE CASCADE,
  whatsapp_number VARCHAR(20) NOT NULL,
  name            VARCHAR(255),
  phone           VARCHAR(20),
  notes           TEXT,
  last_visit      TIMESTAMPTZ,
  visit_count     INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id, whatsapp_number)
);
```

### Table: `appointments`

```sql
CREATE TABLE appointments (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id  UUID REFERENCES businesses(id) ON DELETE CASCADE,
  client_id    UUID REFERENCES clients(id),
  service_id   UUID REFERENCES salon_services(id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  end_at       TIMESTAMPTZ NOT NULL,
  status       VARCHAR(50) DEFAULT 'confirmed',
  -- confirmed | cancelled | completed | no_show
  notes        TEXT,
  booked_via   VARCHAR(50) DEFAULT 'whatsapp',  -- whatsapp | dashboard
  reminder_sent BOOLEAN DEFAULT false,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
```

### Table: `conversations`

```sql
CREATE TABLE conversations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id     UUID REFERENCES businesses(id) ON DELETE CASCADE,
  client_id       UUID REFERENCES clients(id),
  client_phone    VARCHAR(20) NOT NULL,
  messages        JSONB DEFAULT '[]'::jsonb, -- Historique complet [{role, content, ts}]
  current_intent  VARCHAR(100),              -- book | cancel | info | other
  booking_context JSONB DEFAULT '{}'::jsonb, -- Données collectées par l'IA
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### Table: `webhook_events` (idempotence)

```sql
CREATE TABLE webhook_events (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider   VARCHAR(50) NOT NULL,   -- whatsapp
  event_id   VARCHAR(255) NOT NULL,  -- message_id Meta
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(provider, event_id)
);
```

### Row Level Security — Isolation Multi-Tenant

```sql
-- Activer RLS sur toutes les tables
ALTER TABLE appointments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients         ENABLE ROW LEVEL SECURITY;
ALTER TABLE salon_services  ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations   ENABLE ROW LEVEL SECURITY;

-- Policy universelle: chaque salon ne voit que ses données
CREATE POLICY "business_isolation" ON appointments
  FOR ALL USING (
    business_id = (
      SELECT id FROM businesses WHERE owner_id = auth.uid()
    )
  );
-- Répliquer sur toutes les tables
```

### Index critiques

```sql
CREATE INDEX idx_businesses_whatsapp    ON businesses(whatsapp_number);
CREATE INDEX idx_appointments_biz_date  ON appointments(business_id, scheduled_at);
CREATE INDEX idx_clients_biz_phone      ON clients(business_id, whatsapp_number);
CREATE INDEX idx_conversations_active   ON conversations(business_id, client_id, is_active);
```

---

## 5. Services (Business Logic)

### WhatsApp Service — Réception et routage des messages

```js
// modules/whatsapp/whatsapp.service.js
class WhatsAppService {

  async processIncomingMessage(webhookPayload) {
    const { messageId, from, to, message } = this.parsePayload(webhookPayload);

    // Idempotence: ignorer les retries Meta déjà traités
    const isDuplicate = await this.webhookEventService.isProcessed(messageId);
    if (isDuplicate) return;

    // 1. Identifier le salon via le numéro destinataire
    const business = await this.businessService.findByWhatsappNumber(to);
    if (!business) throw new Error(`Salon introuvable pour ${to}`);

    // 2. Trouver ou créer le client
    const client = await this.clientService.findOrCreate(business.id, from);

    // 3. Déléguer à l'agent IA
    const reply = await this.aiService.processMessage({ business, client, message: message.text });

    // 4. Envoyer la réponse WhatsApp
    const token = await this.credentialsService.getWhatsappToken(business.id);
    await this.sendMessage(from, reply, token);
    await this.webhookEventService.markProcessed(messageId);
  }

  async sendMessage(to, text, token) {
    await axios.post(
      `https://graph.facebook.com/v18.0/${PHONE_ID}/messages`,
      { messaging_product: 'whatsapp', to, type: 'text', text: { body: text } },
      { headers: { Authorization: `Bearer ${token}` } }
    );
  }
}
```

### AI Service — Agent Conversationnel

```js
// modules/ai/ai.service.js
class AIService {

  async processMessage({ business, client, message }) {
    // 1. Charger/créer la conversation active
    const conversation = await this.getActiveConversation(business.id, client.id);

    // 2. Construire le prompt système dynamique
    const systemPrompt = this.buildSystemPrompt(business);

    // 3. Historique messages + nouveau message
    const messages = [
      ...conversation.messages,
      { role: 'user', content: message }
    ];

    // 4. Appel LLM avec réponse structurée imposée (JSON schema)
    const response = await this.callLLMWithSchema({
      systemPrompt,
      messages,
      schema: this.bookingSchema
    });

    // 5. Validation stricte avant exécution métier
    const parsed = bookingSchemaValidator.parse(response);
    const { reply, intent, data } = parsed;

    // 6. Actions selon l'intention détectée
    if (intent === 'BOOK_APPOINTMENT' && data.isComplete) {
      await this.appointmentService.create({ business, client, ...data });
      return this.buildConfirmationMessage(data);
    }

    if (intent === 'CANCEL_APPOINTMENT') {
      await this.appointmentService.cancel(data.appointmentId);
      return 'Votre rendez-vous a été annulé. À bientôt !';
    }

    // 7. Sauvegarder la conversation
    await this.updateConversation(conversation.id, message, reply, intent);

    return reply;
  }

  buildSystemPrompt(business) {
    const services = business.services
      .map(s => `- ${s.name} (${s.duration}min, ${s.price}€)`)
      .join('\n');
    const hours = this.formatWorkingHours(business.config.working_hours);

    return [
      `Tu es l'assistante IA du salon "${business.name}".`,
      `Tu gères UNIQUEMENT les réservations de ce salon.`,
      `Services disponibles:\n${services}`,
      `Horaires d'ouverture: ${hours}`,
      `Ne propose JAMAIS de créneaux en dehors des horaires d'ouverture.`,
      `Réponds uniquement via le schéma JSON fourni par l'API.`,
    ].join('\n');
  }
}
```

### Appointment Service — Gestion des créneaux

```js
// modules/appointments/appointments.service.js
class AppointmentService {

  async checkAvailability(businessId, dateTime, duration) {
    const endTime = new Date(dateTime.getTime() + duration * 60000);

    const { data: conflicts } = await supabase
      .from('appointments')
      .select('id')
      .eq('business_id', businessId)
      .eq('status', 'confirmed')
      .lt('scheduled_at', endTime.toISOString())
      .gt('end_at', dateTime.toISOString());

    return conflicts.length === 0;
  }

  async getAvailableSlots(businessId, date) {
    const business  = await this.businessService.findById(businessId);
    const { working_hours, avg_service_duration, timezone = 'Europe/Paris' } = business.config;
    const dayOfWeek = new Date(date).getDay();
    const hours     = working_hours[dayOfWeek];

    if (!hours) return []; // Jour fermé

    const slots     = this.generateTimeSlots(hours.open, hours.close, avg_service_duration, timezone);
    const available = await this.filterBooked(businessId, date, slots);
    return available;
  }

  async create({ businessId, clientId, serviceId, scheduledAt, bookedVia = 'whatsapp' }) {
    const service = await this.serviceService.findById(serviceId);
    const endAt   = new Date(new Date(scheduledAt).getTime() + service.duration * 60000);

    const isAvailable = await this.checkAvailability(businessId, new Date(scheduledAt), service.duration);
    if (!isAvailable) throw new ConflictError('Ce créneau est déjà réservé');

    const { data } = await supabase
      .from('appointments')
      .insert({ business_id: businessId, client_id: clientId, service_id: serviceId,
                scheduled_at: scheduledAt, end_at: endAt.toISOString(), booked_via: bookedVia })
      .select()
      .single();

    return data;
  }
}
```

---

## 6. Routes & API Endpoints

### Auth

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `POST` | `/api/v1/auth/register` | Inscription nouveau salon |
| `POST` | `/api/v1/auth/login` | Connexion (retourne JWT) |
| `POST` | `/api/v1/auth/logout` | Déconnexion |

### Business

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/businesses/me` | Profil salon connecté |
| `PUT` | `/api/v1/businesses/me` | Mettre à jour la configuration |
| `POST` | `/api/v1/businesses/me/setup` | Configuration initiale (WhatsApp, horaires) |

### Services du Salon

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/services` | Lister les services |
| `POST` | `/api/v1/services` | Créer un service |
| `PUT` | `/api/v1/services/:id` | Modifier un service |
| `DELETE` | `/api/v1/services/:id` | Supprimer un service |

### Rendez-vous

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/appointments` | Lister (filtres: date, status) |
| `POST` | `/api/v1/appointments` | Créer manuellement |
| `PUT` | `/api/v1/appointments/:id` | Modifier (status, heure) |
| `DELETE` | `/api/v1/appointments/:id` | Annuler |
| `GET` | `/api/v1/appointments/slots` | Créneaux disponibles (`?date=`) |

### Clients

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/clients` | Lister les clients |
| `GET` | `/api/v1/clients/:id` | Détail + historique |

### Statistiques

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/v1/stats/overview` | KPIs dashboard |

### Webhook WhatsApp

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/webhook/whatsapp` | Vérification Meta (handshake) |
| `POST` | `/webhook/whatsapp` | Réception messages entrants |

### Exemple de Controller

```js
// modules/appointments/appointments.controller.js
class AppointmentsController {

  async list(req, res) {
    const { date, status, page = 1 } = req.query;
    const result = await this.service.list({
      businessId: req.business.id,  // injecté par auth middleware
      date, status, page
    });
    res.json({ success: true, data: result });
  }

  async create(req, res) {
    const { clientId, serviceId, scheduledAt } = req.body;
    const appointment = await this.service.create({
      businessId: req.business.id,
      clientId, serviceId, scheduledAt,
      bookedVia: 'dashboard'
    });
    res.status(201).json({ success: true, data: appointment });
  }

  async update(req, res) {
    const { id } = req.params;
    const updated = await this.service.update(id, req.body, req.business.id);
    res.json({ success: true, data: updated });
  }
}
```

---

## 7. Global Error Handling

```js
// shared/errors.js — Classes d'erreurs métier typées
class AppError extends Error {
  constructor(message, statusCode, code) {
    super(message);
    this.statusCode  = statusCode;
    this.code        = code;
    this.isOperational = true;
  }
}

class NotFoundError    extends AppError {
  constructor(r)   { super(`${r} introuvable`, 404, 'NOT_FOUND'); }
}
class ValidationError  extends AppError {
  constructor(msg) { super(msg, 400, 'VALIDATION_ERROR'); }
}
class UnauthorizedError extends AppError {
  constructor()    { super('Non autorisé', 401, 'UNAUTHORIZED'); }
}
class ConflictError    extends AppError {
  constructor(msg) { super(msg, 409, 'CONFLICT'); }
}
```

```js
// middleware/errorHandler.js
function globalErrorHandler(err, req, res, next) {
  const requestId = req.headers['x-request-id'];

  logger.error({ requestId, message: err.message, stack: err.stack });

  if (err.isOperational) {
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message },
      requestId
    });
  }

  // Erreur inattendue — ne pas exposer les détails internes
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'Une erreur est survenue' },
    requestId
  });
}
```

---

## 8. Configuration & Environment

```bash
# .env.example

# === Server ===
NODE_ENV=production
PORT=3000
API_VERSION=v1

# === Supabase ===
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...

# === WhatsApp Business API ===
WHATSAPP_VERIFY_TOKEN=smartsalon_verify_secret
WHATSAPP_APP_SECRET=fb_app_secret

# === AI Provider ===
AI_PROVIDER=openai             # openai | anthropic
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
AI_MODEL=gpt-4o-mini

# === Security ===
JWT_SECRET=super_secret_key_min_32_chars
CORS_ORIGINS=https://app.smartsalon.ai,https://www.smartsalon.ai

# === Rate Limiting ===
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=100

# === Redis (optionnel — cache + queues) ===
REDIS_URL=redis://localhost:6379
```

```js
// config/env.js — Validation au démarrage
const required = [
  'SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY',
  'WHATSAPP_VERIFY_TOKEN', 'WHATSAPP_APP_SECRET',
  'AI_PROVIDER', 'JWT_SECRET'
];

required.forEach(key => {
  if (!process.env[key]) {
    throw new Error(`Variable d'environnement manquante: ${key}`);
  }
});
```

---

## 9. Testing Strategy

| Type | Outil | Objectif |
|------|-------|----------|
| **Unit** | Jest | Services isolés, logique créneaux, parsing IA |
| **Integration** | Supertest + Supabase test DB | Routes complètes avec vraie base |
| **E2E** | Playwright | Flux: message WhatsApp → RDV créé |
| **Load** | k6 | 1000 webhooks/seconde simultanés |

```js
// tests/unit/appointments.service.test.js
describe('AppointmentService', () => {

  it('retourne false quand le créneau est déjà réservé', async () => {
    mockSupabase.from.mockReturnValue({ data: [{ id: 'existing' }] });

    const isAvailable = await service.checkAvailability(
      'business-1', new Date('2025-03-10T10:00'), 60
    );
    expect(isAvailable).toBe(false);
  });

  it('ne propose jamais de créneaux hors horaires', async () => {
    const slots = await service.getAvailableSlots('business-1', '2025-03-10');
    slots.forEach(slot => {
      expect(slot.hour).toBeGreaterThanOrEqual(9);
      expect(slot.hour).toBeLessThan(18);
    });
  });

  it('lance une ConflictError si créneau indisponible', async () => {
    jest.spyOn(service, 'checkAvailability').mockResolvedValue(false);
    await expect(service.create({ businessId: 'b1', scheduledAt: '...' }))
      .rejects.toThrow(ConflictError);
  });
});
```

```js
// tests/integration/appointments.test.js
describe('POST /api/v1/appointments', () => {
  it('crée un RDV et retourne 201', async () => {
    const res = await request(app)
      .post('/api/v1/appointments')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ clientId: 'c1', serviceId: 's1', scheduledAt: '2025-03-10T10:00:00Z' });

    expect(res.status).toBe(201);
    expect(res.body.data).toHaveProperty('id');
  });
});
```

---

## 10. Performance Optimizations

| Optimisation | Implémentation |
|-------------|----------------|
| **Cache Redis** | Config salon en cache 10 min (`business:{whatsapp_number}`) |
| **Connection Pooling** | Supabase gère automatiquement le pool PostgreSQL |
| **Conversation TTL** | Sessions IA expirées après 2h d'inactivité (cleanup job) |
| **Webhook Queue** | BullMQ pour traiter les webhooks en file d'attente asynchrone |
| **Pagination** | Cursor-based pagination pour listes longues |
| **Indexation DB** | Index sur `whatsapp_number`, `business_id`, `scheduled_at` |

```js
// Cache config salon — évite N requêtes DB par message WhatsApp
async function getBusinessByWhatsapp(whatsappNumber) {
  const cacheKey = `business:${whatsappNumber}`;
  const cached   = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  const { data } = await supabase
    .from('businesses')
    .select('*, salon_services(*)')
    .eq('whatsapp_number', whatsappNumber)
    .single();

  await redis.setEx(cacheKey, 600, JSON.stringify(data)); // TTL 10min
  return data;
}
```

```js
// jobs/cleanup.job.js — Cron toutes les heures
cron.schedule('0 * * * *', async () => {
  const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
  await supabase
    .from('conversations')
    .update({ is_active: false })
    .eq('is_active', true)
    .lt('last_message_at', twoHoursAgo.toISOString());
});
```

---

## 11. Security Best Practices

| Menace | Protection |
|--------|-----------|
| **Injection SQL** | ORM Supabase + requêtes paramétrées + RLS PostgreSQL |
| **CSRF / XSS** | `helmet.js`, CORS strict, sanitisation des inputs |
| **Brute Force** | Rate limiting `/auth` (10 req/min), Supabase lockout automatique |
| **Webhook spoofing** | Vérification signature HMAC-SHA256 sur body brut + comparaison timing-safe |
| **Webhook duplicate delivery** | Idempotence sur `message_id` (table événements traités) |
| **Secrets exposés** | Tokens WhatsApp chiffrés en base (AES-256) |
| **Accès cross-tenant** | RLS Supabase + vérification `business_id` dans chaque service |
| **DDoS** | Cloudflare WAF + rate limiter global par IP |

```js
// Vérification signature webhook Meta WhatsApp (body brut)
function verifyWhatsAppSignature(req, res, next) {
  const signature = req.headers['x-hub-signature-256'];
  if (!signature) return res.status(401).json({ error: 'Signature manquante' });

  const expectedHex = crypto
    .createHmac('sha256', process.env.WHATSAPP_APP_SECRET)
    .update(req.rawBody) // IMPORTANT: body brut non modifié
    .digest('hex');

  const receivedHex = signature.replace('sha256=', '');
  const expected = Buffer.from(expectedHex, 'hex');
  const received = Buffer.from(receivedHex, 'hex');

  if (expected.length !== received.length || !crypto.timingSafeEqual(expected, received)) {
    return res.status(403).json({ error: 'Signature invalide — requête rejetée' });
  }
  next();
}
```

```js
// Idempotence webhook
async function ensureNotProcessed(messageId) {
  const { data } = await supabase
    .from('webhook_events')
    .insert({ provider: 'whatsapp', event_id: messageId })
    .select('event_id')
    .single();
  return !!data; // insertion unique => déjà traité si conflit
}
```

```js
// Chiffrement des tokens WhatsApp en base
const algorithm = 'aes-256-gcm';

function encryptToken(token) {
  const iv         = crypto.randomBytes(16);
  const cipher     = crypto.createCipheriv(algorithm, Buffer.from(ENCRYPTION_KEY, 'hex'), iv);
  const encrypted  = Buffer.concat([cipher.update(token, 'utf8'), cipher.final()]);
  const authTag    = cipher.getAuthTag();
  return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted.toString('hex')}`;
}
```

---

## 12. Deployment

| Composant | Solution recommandée |
|-----------|---------------------|
| **Backend API** | Railway / Render / AWS ECS — container Docker |
| **Base de données** | Supabase Cloud (PostgreSQL managé) |
| **Queue jobs** | Redis Cloud + BullMQ (Railway add-on) |
| **Webhook proxy** | Domaine fixe HTTPS obligatoire (Meta exige HTTPS) |
| **CI/CD** | GitHub Actions → Docker build → Deploy auto |
| **Monitoring** | Sentry (erreurs) + Datadog APM |
| **Logs** | Papertrail ou Logtail (centralisé) |

```dockerfile
# Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY src/ ./src/
ENV NODE_ENV=production
EXPOSE 3000
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "src/server.js"]
```

```yaml
# .github/workflows/deploy.yml
name: Deploy Backend
on:
  push:
    branches: [backend]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm ci && npm test
      - name: Build & Push Docker image
        run: |
          docker build -t smartsalon-backend .
          docker push registry/smartsalon-backend:latest
      - name: Deploy to Railway
        run: railway up --service backend
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## 13. Conclusion

L'architecture backend SmartSalon AI repose sur quatre piliers fondamentaux :

**Multi-tenancy propre** — L'identification des agents IA via le numéro WhatsApp (`whatsapp_number` unique) combinée aux RLS Supabase garantit une isolation totale entre salons sans complexité applicative supplémentaire.

**Séparation des responsabilités** — L'architecture en couches (Routes → Controller → Service → Data) permet de tester chaque composant indépendamment et de faire évoluer la logique métier sans toucher aux routes.

**Scalabilité** — Un seul backend Node.js sert N salons grâce au routing dynamique par numéro WhatsApp, au cache Redis et à la queue BullMQ pour absorber les pics de webhooks.

**Sécurité by design** — Vérification HMAC sur body brut, idempotence des webhooks, chiffrement AES-256 des tokens, RLS PostgreSQL, rate limiting par couche et CORS strict forment une défense en profondeur.

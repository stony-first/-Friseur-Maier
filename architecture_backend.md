# ⚙️ Architecture Backend — SaaS Chatbot WhatsApp IA Multi-Entreprises

---

## 1. Vue d'ensemble

Le backend est une **API REST** construite avec **Node.js + Fastify**. Il constitue le cœur métier de la plateforme : gestion multi-tenant, orchestration des messages WhatsApp, appels IA, gestion des quotas et des abonnements. Il communique avec **n8n** pour la réception des webhooks et avec **Supabase** comme couche de données.

---

## 2. Stack Technique

| Couche | Technologie | Justification |
|---|---|---|
| Runtime | Node.js 20 LTS | Stabilité, performance async |
| Framework | Fastify | 2x plus rapide qu'Express, plugins robustes |
| Langage | TypeScript | Typage, maintenabilité, sécurité |
| Base de données | Supabase (PostgreSQL) | RLS natif, Auth, Realtime |
| ORM | Prisma | Migrations, type-safety, DX excellent |
| Cache | Redis (Upstash) | Cache prompts, rate limiting, sessions |
| Queue | BullMQ | Traitement asynchrone messages, retries |
| IA | OpenAI / Google Gemini | API interchangeable via abstraction |
| Validation | Zod | Schémas partagés backend/frontend |
| Logs | Pino (natif Fastify) | Logs structurés JSON haute performance |
| Tests | Vitest + Supertest | Tests unitaires et d'intégration |
| Orchestration | n8n (self-hosted) | Réception webhook WhatsApp |

---

## 3. Structure des Répertoires

```
src/
├── server.ts                     # Point d'entrée, démarrage Fastify
├── app.ts                        # Instance Fastify, enregistrement plugins
│
├── config/
│   ├── env.ts                    # Validation variables d'env (Zod)
│   ├── database.ts               # Initialisation Prisma
│   ├── redis.ts                  # Connexion Redis
│   ├── queue.ts                  # Initialisation BullMQ
│   └── ai.ts                     # Configuration providers IA
│
├── modules/
│   ├── auth/
│   │   ├── auth.routes.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.schema.ts
│   │
│   ├── entreprises/
│   │   ├── entreprises.routes.ts
│   │   ├── entreprises.controller.ts
│   │   ├── entreprises.service.ts
│   │   └── entreprises.schema.ts
│   │
│   ├── whatsapp/
│   │   ├── whatsapp.routes.ts        # Endpoints webhook + config
│   │   ├── whatsapp.controller.ts
│   │   ├── whatsapp.service.ts       # Envoi messages via Cloud API
│   │   ├── whatsapp.verify.ts        # Vérification signature Meta
│   │   └── whatsapp.schema.ts
│   │
│   ├── conversations/
│   │   ├── conversations.routes.ts
│   │   ├── conversations.controller.ts
│   │   ├── conversations.service.ts
│   │   └── conversations.schema.ts
│   │
│   ├── messages/
│   │   ├── messages.routes.ts
│   │   ├── messages.controller.ts
│   │   ├── messages.service.ts       # Logique principale traitement message
│   │   └── messages.schema.ts
│   │
│   ├── ai/
│   │   ├── ai.service.ts             # Abstraction OpenAI / Gemini
│   │   ├── ai.prompt.ts              # Construction prompt dynamique
│   │   └── providers/
│   │       ├── openai.provider.ts
│   │       └── gemini.provider.ts
│   │
│   ├── subscriptions/
│   │   ├── subscriptions.routes.ts
│   │   ├── subscriptions.controller.ts
│   │   ├── subscriptions.service.ts
│   │   └── subscriptions.schema.ts
│   │
│   ├── billing/
│   │   ├── billing.routes.ts
│   │   ├── billing.controller.ts
│   │   ├── billing.service.ts        # Intégration Stripe / CinetPay
│   │   └── stripe.webhook.ts         # Handler webhook Stripe
│   │
│   └── analytics/
│       ├── analytics.routes.ts
│       ├── analytics.controller.ts
│       └── analytics.service.ts
│
├── workers/
│   ├── message.worker.ts         # Traitement asynchrone messages IA
│   ├── notification.worker.ts    # Alertes quota dépassé
│   └── cleanup.worker.ts         # Nettoyage données anciennes
│
├── middleware/
│   ├── authenticate.ts           # Vérification JWT
│   ├── authorize.ts              # Vérification rôle/plan
│   ├── rateLimiter.ts            # Rate limiting par IP et entreprise
│   ├── tenantResolver.ts         # Résolution tenant depuis JWT
│   ├── requestLogger.ts          # Log des requêtes
│   └── errorHandler.ts           # Gestionnaire erreurs centralisé
│
├── shared/
│   ├── types/
│   │   ├── entreprise.types.ts
│   │   ├── message.types.ts
│   │   └── ai.types.ts
│   ├── errors/
│   │   ├── AppError.ts           # Classe erreur custom
│   │   ├── HttpError.ts
│   │   └── errorCodes.ts
│   └── utils/
│       ├── logger.ts
│       ├── crypto.ts             # Chiffrement données sensibles
│       └── pagination.ts
│
└── prisma/
    ├── schema.prisma
    └── migrations/
```

---

## 4. Schéma de Base de Données (Prisma)

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─── Entreprises ─────────────────────────────────────────
model Entreprise {
  id                String         @id @default(uuid())
  name              String
  description       String?
  sector            String?
  whatsappNumber    String         @unique @map("whatsapp_number")
  whatsappToken     String?        @map("whatsapp_token")    // chiffré
  webhookVerifyToken String?       @map("webhook_verify_token")
  onboardingDone    Boolean        @default(false) @map("onboarding_done")
  createdAt         DateTime       @default(now()) @map("created_at")
  updatedAt         DateTime       @updatedAt @map("updated_at")

  users             User[]
  aiConfig          AIConfig?
  conversations     Conversation[]
  subscription      Subscription?
  usageStats        UsageStat[]

  @@map("entreprises")
}

// ─── Utilisateurs ────────────────────────────────────────
model User {
  id            String     @id @default(uuid())
  entrepriseId  String     @map("entreprise_id")
  email         String     @unique
  role          UserRole   @default(ADMIN)
  createdAt     DateTime   @default(now()) @map("created_at")

  entreprise    Entreprise @relation(fields: [entrepriseId], references: [id], onDelete: Cascade)

  @@map("users")
}

enum UserRole {
  OWNER
  ADMIN
  VIEWER
}

// ─── Configuration IA ────────────────────────────────────
model AIConfig {
  id                String     @id @default(uuid())
  entrepriseId      String     @unique @map("entreprise_id")
  systemPrompt      String     @map("system_prompt")
  tone              String     @default("formel")
  language          String     @default("fr")
  maxHistoryMessages Int       @default(10) @map("max_history_messages")
  openingHoursEnabled Boolean  @default(false) @map("opening_hours_enabled")
  openingHoursStart String?    @map("opening_hours_start")   // "08:00"
  openingHoursEnd   String?    @map("opening_hours_end")     // "18:00"
  timezone          String     @default("Africa/Ouagadougou")
  aiProvider        String     @default("openai") @map("ai_provider")
  aiModel           String     @default("gpt-4o-mini") @map("ai_model")
  faq               Json?      // Array de {question, answer}
  updatedAt         DateTime   @updatedAt @map("updated_at")

  entreprise        Entreprise @relation(fields: [entrepriseId], references: [id], onDelete: Cascade)

  @@map("ai_configs")
}

// ─── Conversations ───────────────────────────────────────
model Conversation {
  id              String     @id @default(uuid())
  entrepriseId    String     @map("entreprise_id")
  clientNumber    String     @map("client_number")
  clientName      String?    @map("client_name")
  status          ConvStatus @default(ACTIVE)
  isHandedOff     Boolean    @default(false) @map("is_handed_off")
  lastMessageAt   DateTime?  @map("last_message_at")
  createdAt       DateTime   @default(now()) @map("created_at")

  entreprise      Entreprise @relation(fields: [entrepriseId], references: [id], onDelete: Cascade)
  messages        Message[]

  @@unique([entrepriseId, clientNumber])
  @@map("conversations")
}

enum ConvStatus {
  ACTIVE
  CLOSED
  HANDED_OFF
}

// ─── Messages ────────────────────────────────────────────
model Message {
  id             String      @id @default(uuid())
  conversationId String      @map("conversation_id")
  role           MessageRole
  content        String
  tokensUsed     Int         @default(0) @map("tokens_used")
  latencyMs      Int?        @map("latency_ms")
  whatsappMsgId  String?     @unique @map("whatsapp_msg_id")
  createdAt      DateTime    @default(now()) @map("created_at")

  conversation   Conversation @relation(fields: [conversationId], references: [id], onDelete: Cascade)

  @@map("messages")
}

enum MessageRole {
  USER
  ASSISTANT
  SYSTEM
}

// ─── Abonnements ─────────────────────────────────────────
model Subscription {
  id                 String    @id @default(uuid())
  entrepriseId       String    @unique @map("entreprise_id")
  plan               PlanType  @default(BASIC)
  status             SubStatus @default(ACTIVE)
  messageLimit       Int       @map("message_limit")
  messagesUsed       Int       @default(0) @map("messages_used")
  currentPeriodStart DateTime  @map("current_period_start")
  currentPeriodEnd   DateTime  @map("current_period_end")
  stripeCustomerId   String?   @map("stripe_customer_id")
  stripeSubId        String?   @map("stripe_sub_id")
  cancelAtPeriodEnd  Boolean   @default(false) @map("cancel_at_period_end")
  updatedAt          DateTime  @updatedAt @map("updated_at")

  entreprise         Entreprise @relation(fields: [entrepriseId], references: [id], onDelete: Cascade)

  @@map("subscriptions")
}

enum PlanType {
  BASIC
  PRO
  PREMIUM
}

enum SubStatus {
  ACTIVE
  PAST_DUE
  CANCELLED
  TRIALING
}

// ─── Statistiques quotidiennes ───────────────────────────
model UsageStat {
  id                  String     @id @default(uuid())
  entrepriseId        String     @map("entreprise_id")
  date                DateTime   @db.Date
  totalMessages       Int        @default(0) @map("total_messages")
  aiMessages          Int        @default(0) @map("ai_messages")
  humanMessages       Int        @default(0) @map("human_messages")
  totalTokens         Int        @default(0) @map("total_tokens")
  avgLatencyMs        Float?     @map("avg_latency_ms")
  uniqueConversations Int        @default(0) @map("unique_conversations")

  entreprise          Entreprise @relation(fields: [entrepriseId], references: [id], onDelete: Cascade)

  @@unique([entrepriseId, date])
  @@map("usage_stats")
}
```

---

## 5. Logique Métier — Traitement d'un Message Entrant

### 5.1 Flux Complet

```
[Client WhatsApp]
       │
       ▼
[WhatsApp Cloud API]
       │  POST webhook
       ▼
[n8n Workflow]
  1. Réception webhook
  2. Vérification signature HMAC-SHA256
  3. Extraction payload normalisé
  4. POST vers Backend /api/v1/webhook/message
       │
       ▼
[Backend Fastify]
  Module: whatsapp/webhook
  5. Authentification webhook (secret token)
  6. Déduplication (whatsapp_msg_id unique)
       │
       ▼
  Module: messages/service
  7. Identifier entreprise via numéro WhatsApp destinataire
  8. Vérifier abonnement actif (status = ACTIVE)
  9. Vérifier quota restant (messagesUsed < messageLimit)
  10. Vérifier heures d'ouverture
        │
        ├─ Hors horaires → Message automatique "Fermé"
        │
        └─ Dans horaires ──▶ Ajouter job BullMQ
                                    │
                                    ▼
                           [Worker: message.worker]
                           11. Charger AIConfig entreprise (cache Redis 5min)
                           12. Charger historique N derniers messages
                           13. Construire prompt dynamique
                           14. Appeler AI Provider (OpenAI / Gemini)
                           15. Recevoir réponse + tokens_used
                           16. Sauvegarder message IA en DB
                           17. Incrémenter messagesUsed
                           18. Mettre à jour UsageStat du jour
                                    │
                                    ▼
                           [WhatsApp Service]
                           19. Envoyer réponse via WhatsApp Cloud API
                           20. Confirmer envoi (status: sent)
```

### 5.2 Construction du Prompt Dynamique

```typescript
// modules/ai/ai.prompt.ts

export function buildPrompt(config: AIConfig, history: Message[], incomingMessage: string): ChatMessage[] {
  const systemPrompt = `
${config.systemPrompt}

Entreprise: ${config.entrepriseName}
Langue: ${config.language}
Tonalité: ${config.tone}

${config.faq ? `FAQ disponible:\n${formatFAQ(config.faq)}` : ''}

Règles:
- Réponds uniquement en ${config.language}
- Si tu ne peux pas répondre, propose de transférer à un humain
- Ne mentionne jamais que tu es une IA sauf si demandé explicitement
- Sois concis (WhatsApp = messages courts)
  `.trim();

  return [
    { role: 'system', content: systemPrompt },
    ...history.slice(-config.maxHistoryMessages).map(m => ({
      role: m.role === 'ASSISTANT' ? 'assistant' : 'user',
      content: m.content,
    })),
    { role: 'user', content: incomingMessage },
  ];
}
```

---

## 6. API REST — Endpoints

### 6.1 Authentification

```
POST   /api/v1/auth/register         Inscription entreprise + user
POST   /api/v1/auth/login            Connexion
POST   /api/v1/auth/logout           Déconnexion
POST   /api/v1/auth/refresh          Refresh token
POST   /api/v1/auth/forgot-password  Demande reset
POST   /api/v1/auth/reset-password   Confirmation reset
```

### 6.2 Entreprise & Configuration

```
GET    /api/v1/entreprise            Profil entreprise courante
PATCH  /api/v1/entreprise            Mise à jour profil
DELETE /api/v1/entreprise            Suppression compte

GET    /api/v1/entreprise/ai-config  Configuration IA
PUT    /api/v1/entreprise/ai-config  Mise à jour configuration IA

GET    /api/v1/entreprise/whatsapp   Statut connexion WhatsApp
POST   /api/v1/entreprise/whatsapp   Enregistrer numéro + token
DELETE /api/v1/entreprise/whatsapp   Déconnecter WhatsApp
```

### 6.3 Webhook WhatsApp (appelé par n8n)

```
GET    /api/v1/webhook/whatsapp      Vérification webhook Meta (challenge)
POST   /api/v1/webhook/whatsapp      Réception messages entrants
```

### 6.4 Conversations

```
GET    /api/v1/conversations                   Liste avec pagination
GET    /api/v1/conversations/:id               Détail + messages
GET    /api/v1/conversations/:id/messages      Messages paginés
POST   /api/v1/conversations/:id/handoff       Transfert humain
POST   /api/v1/conversations/:id/close         Fermer conversation
GET    /api/v1/conversations/export            Export CSV
```

### 6.5 Abonnements & Facturation

```
GET    /api/v1/subscription          Plan et quota actuels
POST   /api/v1/subscription/upgrade  Changer de plan (→ Stripe)
DELETE /api/v1/subscription/cancel   Annuler abonnement

GET    /api/v1/billing/invoices      Historique factures
GET    /api/v1/billing/portal        Portail client Stripe

POST   /api/v1/webhooks/stripe       Webhook Stripe (paiement, renouvellement)
```

### 6.6 Analytics

```
GET    /api/v1/analytics/overview         KPIs globaux (période)
GET    /api/v1/analytics/messages         Volume messages dans le temps
GET    /api/v1/analytics/response-times   Temps de réponse moyen
GET    /api/v1/analytics/ai-usage         Tokens et coût estimé
GET    /api/v1/analytics/conversations    Stats conversations
```

---

## 7. Sécurité

### 7.1 Authentification & Autorisation

```typescript
// JWT via Supabase Auth — chaque requête porte un Bearer token
// Le middleware extrait l'entreprise_id depuis le JWT claims
// Row Level Security (RLS) Supabase renforce l'isolation

// Exemple middleware tenantResolver
export async function tenantResolverMiddleware(request: FastifyRequest) {
  const token = request.headers.authorization?.split(' ')[1];
  const { data: { user } } = await supabase.auth.getUser(token);
  
  if (!user) throw new UnauthorizedError();
  
  const dbUser = await prisma.user.findUnique({
    where: { id: user.id },
    include: { entreprise: true }
  });
  
  request.entrepriseId = dbUser.entrepriseId;
  request.user = dbUser;
}
```

### 7.2 Vérification Signature Meta (Webhook)

```typescript
// modules/whatsapp/whatsapp.verify.ts
import crypto from 'crypto';

export function verifyMetaSignature(payload: string, signature: string): boolean {
  const expectedSignature = crypto
    .createHmac('sha256', process.env.META_APP_SECRET!)
    .update(payload)
    .digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(`sha256=${expectedSignature}`),
    Buffer.from(signature)
  );
}
```

### 7.3 Rate Limiting

```typescript
// 3 niveaux de rate limiting :
// 1. Global IP : 1000 req/min par IP
// 2. Par entreprise : 200 req/min (API)
// 3. Webhook WhatsApp : 500 msg/min par numéro

// Implémenté via @fastify/rate-limit + Redis comme store
```

### 7.4 Chiffrement Données Sensibles

```
Champs chiffrés en AES-256 avant stockage :
- whatsapp_token (token d'accès WhatsApp Business)
- stripe_customer_id
- Clés API IA (si stockées par entreprise)

Librairie : Node.js crypto (natif)
Clé de chiffrement : ENCRYPTION_KEY (env var, 32 bytes)
```

---

## 8. Workers & Queues (BullMQ)

### 8.1 Queues Définies

```typescript
// config/queue.ts

export const Queues = {
  MESSAGE_PROCESSING: 'message-processing',  // Traitement IA
  WHATSAPP_SEND: 'whatsapp-send',            // Envoi réponse
  NOTIFICATION: 'notification',              // Alertes email/quota
  ANALYTICS_UPDATE: 'analytics-update',      // Mise à jour stats
};
```

### 8.2 Configuration Retry

```typescript
const messageQueue = new Queue(Queues.MESSAGE_PROCESSING, {
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,  // 2s, 4s, 8s
    },
    removeOnComplete: 100,  // Garder 100 derniers jobs réussis
    removeOnFail: 500,
  },
});
```

---

## 9. Gestion Multi-Tenant

```
Stratégie : Base de données unique avec isolation logique

1. Chaque table inclut entreprise_id
2. Row Level Security (RLS) Supabase actif sur toutes les tables
3. Policies RLS : une entreprise ne peut accéder qu'à ses propres données
4. Le middleware tenantResolver injecte l'entreprise_id sur chaque requête
5. Toutes les queries Prisma filtrent sur entreprise_id

Exemple RLS Supabase :
  CREATE POLICY "tenant_isolation" ON conversations
    FOR ALL USING (entreprise_id = auth.jwt() -> 'entreprise_id');
```

---

## 10. Cache Redis — Stratégie

| Clé | TTL | Contenu |
|---|---|---|
| `ai_config:{entrepriseId}` | 5 min | Configuration IA complète |
| `subscription:{entrepriseId}` | 2 min | Plan + quota |
| `whatsapp_status:{entrepriseId}` | 10 min | Statut connexion |
| `rate_limit:{ip}` | 1 min | Compteur requêtes |
| `dedup:{whatsappMsgId}` | 24h | Déduplication messages |

---

## 11. Gestion des Erreurs

```typescript
// shared/errors/AppError.ts
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: unknown
  ) {
    super(message);
  }
}

// Codes d'erreur standardisés
export const ErrorCodes = {
  SUBSCRIPTION_EXPIRED:    'SUBSCRIPTION_EXPIRED',
  QUOTA_EXCEEDED:          'QUOTA_EXCEEDED',
  WHATSAPP_NOT_CONNECTED:  'WHATSAPP_NOT_CONNECTED',
  AI_PROVIDER_ERROR:       'AI_PROVIDER_ERROR',
  INVALID_SIGNATURE:       'INVALID_SIGNATURE',
  TENANT_NOT_FOUND:        'TENANT_NOT_FOUND',
};

// Format réponse d'erreur unifié
{
  "error": {
    "code": "QUOTA_EXCEEDED",
    "message": "Quota mensuel atteint. Passez au plan Pro.",
    "statusCode": 429,
    "requestId": "req_abc123"
  }
}
```

---

## 12. Logs (Pino)

```typescript
// Structure log standard
{
  "level": "info",
  "time": "2024-01-15T10:30:00.000Z",
  "requestId": "req_abc123",
  "entrepriseId": "ent_xyz",
  "event": "message.processed",
  "tokensUsed": 342,
  "latencyMs": 1205,
  "provider": "openai",
  "model": "gpt-4o-mini"
}

// Niveaux utilisés :
// ERROR  → Erreurs critiques (IA down, DB unreachable)
// WARN   → Quota à 90%, retry tentative
// INFO   → Message traité, abonnement mis à jour
// DEBUG  → Développement uniquement
```

---

## 13. n8n — Workflow WhatsApp

```
Workflow : "WhatsApp Message Handler"

Trigger : Webhook (POST /webhook/whatsapp)
  │
  ├─ Node: Vérifier signature Meta (Function node)
  │     Calcul HMAC-SHA256, rejet si invalide (HTTP 403)
  │
  ├─ Node: Parser payload WhatsApp
  │     Extraire : from, body, type, whatsappMsgId
  │     Filtrer : ignorer status updates (delivered, read)
  │
  ├─ Node: HTTP Request → Backend
  │     POST https://api.domain.com/api/v1/webhook/whatsapp
  │     Headers: X-Webhook-Secret: {secret}
  │     Body: payload normalisé
  │
  └─ Node: Gestion erreurs
        Retry sur 5xx (3 fois, backoff 2s)
        Alert Slack sur échec définitif
```

---

## 14. Monitoring & Observabilité

```
APM : Sentry (erreurs + performance)
Métriques : Prometheus + Grafana (optionnel Phase 2)
Uptime : UptimeRobot (alertes downtime)
Logs centralisés : Logtail ou Datadog (Phase 2)

Alertes automatiques :
  - Taux d'erreur IA > 5% → alerte email
  - Latence moyenne > 5s → alerte Slack
  - Quota Redis plein > 80% → alerte
```

---

## 15. Variables d'Environnement

```bash
# .env

# App
NODE_ENV=production
PORT=3000
API_BASE_URL=https://api.mondomaine.com

# Supabase
DATABASE_URL=postgresql://...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Redis
REDIS_URL=rediss://...

# IA
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=AIza...
DEFAULT_AI_PROVIDER=openai
DEFAULT_AI_MODEL=gpt-4o-mini

# WhatsApp
META_APP_SECRET=abc123...           # Vérification signature webhook
WEBHOOK_VERIFY_TOKEN=random_string  # Token vérification Meta

# Stripe
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Sécurité
JWT_SECRET=supersecret256bits
ENCRYPTION_KEY=32byteshexstring

# Webhook interne
INTERNAL_WEBHOOK_SECRET=secret_n8n_to_backend

# Sentry
SENTRY_DSN=https://...@sentry.io/...
```

---

## 16. Déploiement

### Infrastructure Recommandée

```
Production :
  Backend API      → VPS Hetzner CAX21 (4 vCPU, 8GB RAM) — ~12€/mois
  n8n              → VPS Hetzner CX22 (2 vCPU, 4GB RAM)  —  ~6€/mois
  Redis            → Upstash (serverless, pay-per-use)    —  ~0-20€/mois
  Base de données  → Supabase Pro                          — ~25€/mois
  
  Total fixe estimé : ~43-63€/mois (hors IA et WhatsApp API)
```

### Docker Compose (Développement)

```yaml
version: '3.8'
services:
  api:
    build: .
    ports: ["3000:3000"]
    environment:
      - NODE_ENV=development
    depends_on: [redis]
    volumes: ["./src:/app/src"]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  n8n:
    image: n8nio/n8n
    ports: ["5678:5678"]
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
```

### CI/CD

```
GitHub Actions :
  1. Push sur main → tests automatiques (Vitest)
  2. Build Docker image
  3. Push image vers registry (GHCR)
  4. Deploy sur VPS via SSH (docker pull + restart)
  5. Health check endpoint /api/v1/health
```

---

## 17. Tests

```
Tests unitaires (Vitest) :
  - Services (ai.service, messages.service)
  - Utilitaires (buildPrompt, verifySignature)
  - Validation schémas Zod

Tests d'intégration (Vitest + Supertest) :
  - Flux message entrant complet (mock IA + WhatsApp)
  - Gestion quota dépassé
  - Authentification et isolation tenant

Tests de charge (k6) :
  - 100 messages simultanés
  - Vérifier latence < 3s au 95e percentile

Seuil couverture cible : > 75%
```

---

*Document généré pour le projet SaaS Chatbot WhatsApp IA — Version 1.0*

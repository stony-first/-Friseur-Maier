mindmap
  root((Backend Architecture))
    Stack
      Node.js
      Express
      Supabase
      WhatsApp Business API
      NLP Engine
    Config
      env.js
      supabaseClient.js
      whatsappConfig.js
    Controllers
      auth.controller.js
      service.controller.js
      appointment.controller.js
      client.controller.js
      webhook.controller.js
    Routes
      auth.routes.js
      service.routes.js
      appointment.routes.js
      client.routes.js
      webhook.routes.js
    Services
      appointment.service.js
      availability.service.js
      reminder.service.js
      whatsapp.service.js
      ai.service.js
    AI Layer
      intentClassifier.js
      entityExtractor.js
      conversationManager.js
      promptTemplates.js
    Middlewares
      auth.middleware.js
      error.middleware.js
      validation.middleware.js
    Utils
      date.utils.js
      logger.js
      constants.js
    Jobs
      reminder.job.js
    Processing Flow
      WhatsApp Webhook
      NLP Analysis
      Business Decision
      Availability Check
      Supabase Write
      WhatsApp Response
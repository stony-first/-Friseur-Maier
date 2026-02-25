mindmap
  root((Frontend Architecture))
    Stack
      React.js
      Axios
      Supabase Auth
    Public
      static assets
    Src
      api
        axiosConfig.js
        auth.api.js
        service.api.js
        appointment.api.js
        client.api.js
      components
        layout
          Sidebar.jsx
          Navbar.jsx
          Layout.jsx
        dashboard
          StatsCard.jsx
          Charts.jsx
        appointments
          AppointmentList.jsx
          AppointmentForm.jsx
          CalendarView.jsx
        services
          ServiceList.jsx
          ServiceForm.jsx
        clients
          ClientList.jsx
      pages
        Login.jsx
        Dashboard.jsx
        Appointments.jsx
        Services.jsx
        Clients.jsx
      context
        AuthContext.jsx
      hooks
        useAuth.js
      utils
        dateFormatter.js
      App.jsx
      main.jsx
    Admin Flow
      Login
      Dashboard
      Appointment Management
      Service Management
      Client Management
      Analytics
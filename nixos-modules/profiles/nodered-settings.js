module.exports = {
  flowFile: 'flows.json',
  flowFilePretty: true,
  uiPort: process.env.PORT || 1880,
  diagnostics: {
    enabled: true,
    ui: true,
  },
  runtimeState: {
    enabled: false,
    ui: false,
  },
  logging: {
    console: {
      level: "warn",
      metrics: false,
      audit: false
    }
  },
  exportGlobalContextKeys: false,
  externalModules: {},
  editorTheme: {
    palette: {},
    projects: {
      enabled: false,
      workflow: {
        mode: "manual"
      }
    },
    codeEditor: {
      lib: "monaco",
      options: {
      }
    },
    markdownEditor: {
      mermaid: {
        enabled: true
      }
    },
  },
  functionExternalModules: true,
  functionTimeout: 0,
  functionGlobalContext: {},
  debugMaxLength: 1000,
  mqttReconnectTime: 15000,
  serialReconnectTime: 15000,
  adminAuth: {
    type: 'strategy',
    strategy: {
      name: "openidconnect",
      label: 'Sign in with authentik',
      icon: "fa-cloud",
      strategy: require("passport-openidconnect").Strategy,
      options: {
        issuer: 'https://authentik.adama.lan/application/o/node-red/',
        authorizationURL: 'https://authentik.adama.lan/application/o/authorize/',
        tokenURL: 'https://authentik.adama.lan/application/o/token/',
        userInfoURL: 'https://authentik.adama.lan/application/o/userinfo/',
        clientID: 'node-red',
        clientSecret: 'secret',
        callbackURL: 'https://node-red.adama.lan/auth/strategy/callback/',
        scope: ['email', 'profile', 'openid'],
        proxy: true,
        verify: function (issuer, profile, done) {
          done(null, profile)
        }
      },
    },
    users: function (user) {
      return Promise.resolve({ username: user, permissions: "*" });
    }
  },
}

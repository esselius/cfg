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
      label: 'Sign in with Kanidm',
      icon: "fa-cloud",
      strategy: require("passport-openidconnect").Strategy,
      options: {
        issuer: 'https://idm.int.esselius.dev/oauth2/openid/node-red',
        authorizationURL: 'https://idm.int.esselius.dev/ui/oauth2',
        tokenURL: 'https://idm.int.esselius.dev/oauth2/token',
        userInfoURL: 'https://idm.int.esselius.dev/oauth2/openid/node-red/userinfo',
        clientID: 'node-red',
        clientSecret: require('fs').readFileSync(process.env.NODE_RED_OIDC_SECRET_FILE, 'utf8').trim(),
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

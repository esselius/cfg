let
  home-peteresselius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoqhLqzuQJEyn/M4WmBkpPlMou2zIXoJUikAcFgvx4C";

  adama = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfILv+PA582KwZYcJRX2yCcQVBlh7T9uWUieLBFXHo/";
in
{
  "home-email.age".publicKeys = [ home-peteresselius ];
  "github-token.age".publicKeys = [ home-peteresselius ];
  "authentik-env.age".publicKeys = [ home-peteresselius adama ];
  "z2m.age".publicKeys = [ home-peteresselius adama ];
  "step-ca.age".publicKeys = [ home-peteresselius adama ];
  "grafana-env.age".publicKeys = [ home-peteresselius adama ];
}

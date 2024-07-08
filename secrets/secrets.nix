let
  home-peteresselius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoqhLqzuQJEyn/M4WmBkpPlMou2zIXoJUikAcFgvx4C";
  work-peteresselius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmUlguPPHN+XxAvF9OEmF8mnn7mXSWez5PjkG04ECL2";

  adama = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTzyGpnD7Zlfj/7oxOq3ZQ1URPtRP60UaxOKyOm7Mgn";
in
{
  "work-email.age".publicKeys = [ work-peteresselius ];
  "home-email.age".publicKeys = [ home-peteresselius ];
  "github-token.age".publicKeys = [ work-peteresselius home-peteresselius ];
  "authentik-env.age".publicKeys = [ home-peteresselius adama ];
}

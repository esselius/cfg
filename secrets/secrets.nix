let
  peteresselius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoqhLqzuQJEyn/M4WmBkpPlMou2zIXoJUikAcFgvx4C";
in
{
  "work-email.age".publicKeys = [ peteresselius ];
  "home-email.age".publicKeys = [ peteresselius ];
}

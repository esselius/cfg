{
  nix.linux-builder = {
    enable = true;
    systems = [ "aarch64-linux" ];
    maxJobs = 4;
    ephemeral = true;
    config = {
      # boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
      virtualisation = {
        darwin-builder = {
          diskSize = 100 * 1024;
          memorySize = 16 * 1024;
        };
        cores = 8;
      };
    };
  };
}

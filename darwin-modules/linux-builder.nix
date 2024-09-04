{
  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
    ephemeral = true;
    config = {
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

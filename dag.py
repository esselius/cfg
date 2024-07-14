import os
import re

import networkx as nx

moduleSystems = ["darwin", "home", "nixos"]
moduleTypes = ["configurations", "modules", "tests"]
ezModulePattern = re.compile(r"ezModules.([a-zA-Z-1-9]+)")
inputsModulePattern = re.compile(r"[^-]inputs.([a-zA-Z-1-9]+)")

G = nx.Graph()

for ms in moduleSystems:
    for mt in moduleTypes:
        folder = f"{ms}-{mt}"

        if os.path.exists(folder):
            for fd in os.scandir(folder):
                module = folder + "/" + fd.name.removesuffix(".nix")

                if mt == "configurations":
                    defaultModule = f"{ms}-modules/default"
                    G.add_edge(module, defaultModule)

                if fd.name.endswith(".nix"):
                    with open(fd, encoding="utf-8") as f:
                        data = f.read()
                        for match in re.finditer(ezModulePattern, data):
                            dep = f"{ms}-modules/{match.group(1)}"
                            G.add_edge(module, dep)

                        for match in re.finditer(inputsModulePattern, data):
                            dep = f"inputs/{match.group(1)}"
                            G.add_edge(module, dep)
                else:
                    for sub_fd in os.scandir(fd.path):
                        with open(sub_fd, encoding="utf-8") as f:
                            data = f.read()
                            for match in re.finditer(ezModulePattern, data):
                                dep = f"{ms}-modules/{match.group(1)}"
                                G.add_edge(module, dep)

print(G.nodes)
print(nx.shortest_path(G, "darwin-configurations/Fox", "inputs/nixpkgs-unstable"))

# This file has been generated by node2nix 1.11.1. Do not edit!

{ nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? [ ], fetchFromGitHub }:

let
  sources = {
    "oauth-0.10.0" = {
      name = "oauth";
      packageName = "oauth";
      version = "0.10.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/oauth/-/oauth-0.10.0.tgz";
        sha512 = "1orQ9MT1vHFGQxhuy7E/0gECD3fd2fCC+PIX+/jgmU/gI3EpRocXtmtvxCO5x3WZ443FLTLFWNDjl5MPJf9u+Q==";
      };
    };
    "passport-strategy-1.0.0" = {
      name = "passport-strategy";
      packageName = "passport-strategy";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/passport-strategy/-/passport-strategy-1.0.0.tgz";
        sha512 = "CB97UUvDKJde2V0KDWWB3lyf6PC3FaZP7YxZ2G8OAtn9p4HI9j9JLP9qjOGZFvyl8uwNT8qM+hGnz/n16NI7oA==";
      };
    };
  };
  args = rec {
    name = "passport-openidconnect";
    packageName = "passport-openidconnect";
    version = "0.1.2";
    src = fetchFromGitHub {
      owner = "jaredhanson";
      repo = "passport-openidconnect";
      rev = "v${version}";
      hash = "sha256-jaeEoJNcAoczZhcuhb2Uw2LKXXARBKkPDYhIDUblWRk=";
    };
    dependencies = [
      sources."oauth-0.10.0"
      sources."passport-strategy-1.0.0"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "OpenID Connect authentication strategy for Passport.";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
in
{
  args = args;
  sources = sources;
  tarball = nodeEnv.buildNodeSourceDist args;
  package = nodeEnv.buildNodePackage args;
  shell = nodeEnv.buildNodeShell args;
  nodeDependencies = nodeEnv.buildNodeDependencies (lib.overrideExisting args {
    src = stdenv.mkDerivation {
      name = args.name + "-package-json";
      src = nix-gitignore.gitignoreSourcePure [
        "*"
        "!package.json"
        "!package-lock.json"
      ]
        args.src;
      dontBuild = true;
      installPhase = "mkdir -p $out; cp -r ./* $out;";
    };
  });
}
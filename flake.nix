{
  description = "Beutl nix package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
  flake-utils.lib.eachDefaultSystem (
    system: 
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.Beutl = pkgs.buildDotnetModule {
        pname = "Beutl";
        version = "2.0.0";
        src = pkgs.fetchFromGitHub {
          owner = "b-editor";
          repo = "beutl";
          rev = "a24a93c211001f05eeb626691b9ae89cb1780390";
          hash = "sha256-peWRmgjhQD+DGz7k8Wiydzvu73I1EIRAGSZKw296f7Y=";
        };
        projectFile = "src/Beutl/Beutl.csproj";
        dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0_3xx;
        dotnet-runtime = pkgs.dotnetCorePackages.runtime_10_0-bin;
        nugetDeps = ./deps.json;
        selfContainedBuild = true;
        dotnetBuildFlags = [ "-p:TargetFramework=net10.0" ];
        dotnetRestoreFlags = [ "-p:TragetFramework=net10.0" ];
        dotnetInstallFlags = [ "-p:TargetFramework=net10.0" ];
      };
    }
  );
}

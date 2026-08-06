{
  description = "Beutl nix package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildDotnetModule {
        pname = "Beutl";
        version = "2.0.0-preview.6+7abb69ab71";
        src = pkgs.fetchFromGitHub {
          owner = "b-editor";
          repo = "beutl";
          rev = "7abb69ab71eedc936f4887ca10f42f1f616cddb5";
          hash = "sha256-iwZJL4lhNz3HAr2kR6ezFXwcoErW6eOUiQ3XVW9/Q7M=";
          fetchSubmodules = true;
        };
        projectFile = [
          "src/Beutl/Beutl.csproj"
          "src/Beutl.FFmpegWorker/Beutl.FFmpegWorker.csproj"
        ];
        dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0_3xx;
        dotnet-runtime = pkgs.dotnetCorePackages.runtime_10_0-bin;
        nugetDeps = ./deps.json;
        selfContainedBuild = true;
        dotnetBuildFlags = [ "-p:TargetFramework=net10.0" ];
        dotnetInstallFlags = [ "-p:TargetFramework=net10.0" ];

        nativeBuildInputs = with pkgs; [ makeWrapper ];

        runtimeDeps = with pkgs; [
          libx11
          libxcursor
          libxext
          ffmpeg
          openal
        ];

        postInstall = ''
          mkdir -p $out/share/applications
          substitute packages/ubuntu22.04_amd64/usr/share/applications/beutl.desktop $out/share/applications/beutl.desktop \
            --replace "Exec=/usr/bin/beutl" "Exec=$out/bin/Beutl" \
            --replace "Icon=/usr/share/pixmaps/beutl_icon.png" "Icon=$out/share/icons/hicolor/256x256/apps/beutl.png"

          mkdir -p $out/share/icons/hicolor/256x256/apps
          cp packages/ubuntu22.04_amd64/usr/share/pixmaps/beutl_icon.png $out/share/icons/hicolor/256x256/apps/beutl.png
        '';
      };
      apps.${system}.update-deps = {
        type = "app";
        program =
          let
            updateScript = pkgs.writeShellScriptBin "update-deps" ''
              nix flake update
              ${self.packages.${system}.default.fetch-deps} deps.json
            '';
          in
          "${updateScript}/bin/update-deps";
      };
      formatter.${system} = pkgs.nixfmt;
    };
}

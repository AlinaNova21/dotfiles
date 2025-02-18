{
  flake,
  buildFHSEnv,
  buildDotnetModule,
  dotnetCorePackages,
}: let
  # rev = flake.rev or "dirty";
  rev = "35422b84c2f6b6668361576dd916d8520b2c9761";
  dotnet-sdk = with dotnetCorePackages;
    combinePackages [sdk_9_0 aspnetcore_9_0];
  admin = buildDotnetModule {
    inherit dotnet-sdk;
    name = "space-station-14-admin-${rev}";

    src = fetchGit {
      url = "https://github.com/space-wizards/SS14.Admin";
      inherit rev;
    };

    projectFile = ["SS14.Admin/SS14.Admin.csproj"];

    buildType = "Release";
    selfContainedBuild = false;

    # Generated using "fetch-deps" flake app output.
    nugetDeps = ./deps.json;

    runtimeDeps = [];

    dotnet-runtime = with dotnetCorePackages;
      combinePackages [runtime_9_0 aspnetcore_9_0];

    executables = ["SS14.Admin"];
  };
in
  buildFHSEnv {
    name = "SS14.Admin";

    targetPkgs = pkgs: [admin git python3 dotnet-sdk zstd];

    runScript = "SS14.Admin";

    passthru =
      admin.passthru
      // {
        name = "space-station-14-admin-wrapped-${rev}";
      };
  }

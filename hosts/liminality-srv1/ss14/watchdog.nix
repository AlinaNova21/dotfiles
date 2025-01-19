{
  config,
  lib,
  ...
}: {
  imports = [
    ./instances
  ];
  services.space-station-14-watchdog = {
    enable = true;
    directory = "/persist/var/lib/space-station-14";
    openApiFirewall = true;
    settings = {
      Serilog = {
        # Using: [ "Serilog.Sinks.Console", "Serilog.Sinks.Loki" ]
        Using = ["Serilog.Sinks.Console"];
        MinimumLevel = {
          Default = "Debug";
          Override = {
            SS14 = "Debug";
            Microsoft = "Warning";
            "Microsoft.Hosting.Lifetime" = "Information";
            "Microsoft.AspNetCore" = "Warning";
          };
        };
        WriteTo = [
          {
            Name = "Console";
            Args.OutputTemplate = "[{Timestamp:HH:mm:ss} {Level:u3} {SourceContext}] {Message:lj}{NewLine}{Exception}";
          }
        ];

        #Enrich: [ "FromLogContext" ]

        #Loki:
        #  Address: "http://localhost:3100"
        #  Name: "Test"
      };
      BaseUrl = "http://127.0.0.1:5000/";
      Urls = "http://127.0.0.1:5000";
      AllowedHosts = "*";
    };
  };
}

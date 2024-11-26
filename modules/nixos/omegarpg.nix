flake:  # the package self
{
  config,
  lib,
  pkgs, ...
}:

with lib;

let
  flakePkgs = flake.packages.${pkgs.stdenv.hostPlatform.system};
  cfg = config.services.omegarpg;
  serverSettings = {
    CertificateFilepath = builtins.toString cfg.certFile;
    KeyFilepath = builtins.toString cfg.keyFile;
    MetaServer = cfg.additionalMetaServers;
    MetaServerHeartbeat = 3600000;
    NofityMetaServer = cfg.registerServer;
    Port = cfg.port;
    ServerName = cfg.name;
    ServerUrl = cfg.domain;
    adminPassword = cfg.adminPassword;
    serverMessage = "";
    type = "OmegaRPG Server Settings File";
  };
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "orpg_serversettings.json" serverSettings;
  wrappedOmega = flakePkgs.omegarpg-server-with-config.override {
    omegarpg = cfg.package;
  };
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.omegarpg = {
      description = "OmegaRPG Server";
      documentation = [ "https://foundryvtt.com/kb/" ];

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Restart = "always";
        ExecStart = "${lib.getBin wrappedOmega}/bin/omega-rpg-server-with-config";
        Environment = ''OMEGARPG_SERVER_CONFIG="${settingsFile}"'';
        # hardening
        DynamicUser = true;
        PrivateTmp = true;
        PrivateDevices = true;
        DevicePolicy= "closed";
        ProtectSystem = "full";
        ProtectHome = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies= "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        NoNewPrivileges = true;
      };
    };
  };
  options = with types; {
    services.omegarpg = {
      enable = mkEnableOption ''
        OmegaRPG is a free, open-source Virtual Tabletop application.
        This enables a server to host games.
      '';
      package = mkOption {
        type = package;
        default = flakePkgs.omegarpg;
        description = ''
          The key file for the cert. Is generated dynamically if not set. 
        '';
      };
      port = mkOption {
        type = port;
        default = 7001;
        description = ''
          The diplay name of the server.
        '';
      };
      openFirewall = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to open ports in the firewall for OmegaRPG Server.
          Opens the port under {option}`services.omegarpg.port`.
        '';
      };
      name = mkOption {
        type = str;
        default = "";
        description = ''
          The name of the server
        '';
      };
      registerServer = mkOption {
        type = bool;
        default = false;
        description = ''
          Register the server with a meta server.
        '';
      };
      domain = mkOption {
        type = str;
        default = "";
        description = ''
          The domain the server is using.
        '';
      };
      additionalMetaServers = mkOption {
        type = types.separatedString " ";
        default = "";
        description = ''
          List of additional meta servers to register with, separated by space.
        '';
      };
      # can the certificate handling be done by the acme module?
      certFile = mkOption {
        type = nullOr path;
        default = null;
        description = ''
          The cert file. Is generated dynamically if not set.
        '';
      };
      keyFile = mkOption {
        type = nullOr path;
        default = null;
        description = ''
          The key file for the cert. Is generated dynamically if not set. 
        '';
      };
      # Find a way to implement an alternative
      adminPassword = mkOption {
        type = str;
        default = "";
        description = ''
          The admin password. NOTE: Setting the password this way is insecure.
        '';
      };
    };
  };
}
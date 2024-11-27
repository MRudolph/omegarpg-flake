# Omega RPG Nix flake

This repository contains a flake to run [OmegaRPG](https://github.com/R-Rudolph/OmegaRPG) using nix(os).

## Running ad-hoc

You can execute the executables directly using

Client:

    nix run github:MRudolph/omegarpg-flake 

Server (CLI):

    nix run github:MRudolph/omegarpg-flake#omegarpg-server-cli

Server (GUI):

    nix run github:MRudolph/omegarpg-flake#omegarpg-server-gui

## Server module

You can configure a systemd service to run the server like this:

    {
        inputs = {
            omegarpg = {
                url = "github:MRudolph/omegarpg-flake";
                # add this line to minimize different system depdencies
                inputs.nixpkgs.follows = "nixpkgs";
            };
        };
        outputs = {
            # ...
            nixosConfigurations =  {
                host = nixpkgs.lib.nixosSystem {
                    modules = [         
                        # ...       
                        omegarpg.nixosModules.omegarpg # provide the service entry
                        # configure the service (might also be put in configuration.nix or another file)
                        {
                            services.omegarpg = {
                                enable = true; # enable service
                                openFirewall = true; # open port
                                # additional configuration (optional)
                                domain = "host";
                                port = 7001;
                                name = "";
                                # ... (see modules/nixos/omegarpg.nix for all options)
                            };
                        }
                    ];
                };
            };
        };
    }
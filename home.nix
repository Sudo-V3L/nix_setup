{config, pkgs, ...}:

{
	home.username = "sudo-v3l";
	home.homeDirectory = "/home/sudo-v3l";
	home.stateVersion = "26.05";

	programs.fish = {
		enable = true;

		shellAliases = {
			config = "cd /etc/nixos && sudo nvim configuration.nix";
		};

		interactiveShellInit = ''
			set fish_greeting
		'';

		# Enable plugins from Nixpkgs
		plugins = [
      		  {
        	    name = "grc";
        	    src = pkgs.fishPlugins.grc.src;
      		  }
    		];
	};
}

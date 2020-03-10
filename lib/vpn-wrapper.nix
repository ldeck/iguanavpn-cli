with import <nixpkgs> {};
with pkgs.python37Packages;

let
    
    python = python37;
    vpn-slice = buildPythonPackage rec {
      name = "vpn-slice";
      version = "v0.13";

      src = pkgs.fetchFromGitHub {
      	 owner = "dlenski";
	 repo = "${name}";
	 rev = "${version}";
	 sha256 = "1ibrwal80z27c2mh9hx85idmzilx6cpcmgc15z3lyz57bz0krigb";
      };

      propagatedBuildInputs = [ setproctitle ];

      meta = {
        homepage = "https://github.com/dlenski/vpn-slice";
        description = "vpnc-script replacement for easy and secure split-tunnel VPN setup";
        license = stdenv.lib.licenses.gpl3Plus;
        maintainers = with maintainers; [ dlenski ];
      };
    };

in mkShell {
   name = "vpn-env";
   buildInputs = [ numpy toolz vpn-slice openconnect ];
   shellHook = ''
     echo "Ready to slice your vpn!"
   '';
}
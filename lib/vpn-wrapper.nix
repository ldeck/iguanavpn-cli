with import <nixpkgs> {};
with pkgs.python37Packages;

let

    python = python37;
    openconnect = pkgs.openconnect.overrideAttrs (oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs ++ [ libproxy ];
      configureFlags = oldAttrs.configureFlags ++ [ "--with-libproxy" ];
    });
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
        license = lib.licenses.gpl3Plus;
        maintainers = with maintainers; [ dlenski ];
      };
    };

in mkShell {
   name = "vpn-env";
   buildInputs = [ vpn-slice openconnect libproxy ];
   shellHook = ''
     echo "Welcome to iguana-vpn!"
   '';
}

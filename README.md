# IguanaVPN wrapper for openconnect and vpn-slice #

This is cli tool for setting up VPN on macOS / linux with [openconnect](https://www.infradead.org/openconnect/) and [vpn-slice](https://github.com/dlenski/vpn-slice).

## PREREQUISITES ##

  * Nix - The purely functional package manager [here](https://nixos.org/nix/)
  * Git
  * Terminal

NB: Nix is used to build a shell with known dependencies.

## Setup ##

  1. Install Nix via its [quick start guide](https://nixos.org/nix/manual/#chap-quick-start).
  1. Clone this repo where you choose.
  1. Run `./iguana-vpn --config` to configure a vpn connection configuration in `~/.vpn`.

NB: simply run this again to configure another connection to choose from at runtime.

## Run / Connect ##

   ./iguana-vpn --run

OR

   sudo -E ./iguana-vpn -r

## External docs ##

  * [vpn-slice](https://github.com/dlenski/vpn-slice)
  * [openconnect](https://www.infradead.org/openconnect/)
  * [nix](https://nixos.org/nix/)
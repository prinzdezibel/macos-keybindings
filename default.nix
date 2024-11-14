{ pkgs ? import <nixpkgs> { } }:

{

  nixos = import ./modules;

  path = ./.;
}
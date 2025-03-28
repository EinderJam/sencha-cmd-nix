{
  description = "Sencha CMD, packaged for Nix";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; };

  outputs = { self, nixpkgs }:
    let system = "x86_64-linux";
    in {
      packages.${system}.default = with import nixpkgs { inherit system; };
        let shortVersion = "7.8.0";
        in let version = "${shortVersion}.59";
        in stdenv.mkDerivation rec {
          pname = "Sencha CMD";
          meta.mainProgram = "sencha";

          inherit version;
          nativeBuildInputs = [ makeWrapper ];
          buildInputs = [ temurin-jre-bin-8 ];

          src = fetchzip {
            url =
              "https://trials.sencha.com/cmd/${shortVersion}/SenchaCmd-${version}-linux-amd64.sh.zip";
            sha256 = "sha256-YXWeqjiBGIr1d6NqbC2h0VW5e68cETAtJI5GmZsUD6U=";
          };

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin

            echo $PATH
            echo Starting installer!
            ./SenchaCmd-${version}-linux-amd64.sh -Dinstall4j.logToStderr=true -q
            cp -a /build/bin/. $out/bin
            ln -s $out/bin/Sencha/Cmd/${version}/sencha $out/bin/sencha
            ln -s /var/cache/sencha-cmd/repo $out/bin/Sencha/Cmd/repo
            echo Installed successfully

            runHook postInstall
          '';

          wrapperPath = with nixpkgs.lib; makeBinPath (buildInputs);

          postFixup = ''
            wrapProgram $out/bin/Sencha/Cmd/${version}/sencha \
             --prefix PATH "${wrapperPath}"
            export PATH=$out/bin/Sencha/Cmd:$PATH
          '';
        };

    };
}

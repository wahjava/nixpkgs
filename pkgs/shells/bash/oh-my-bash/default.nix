# This derivation was inspired by the oh-my-zsh nixpkgs derivation

# This script was inspired by the ArchLinux User Repository package:
#
#   https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=oh-my-zsh-git
{ lib, stdenv, fetchFromGitHub, nixosTests, writeScript, common-updater-scripts
, git, nix, nixfmt, jq, coreutils, gnused, curl, cacert }:

stdenv.mkDerivation rec {
  version = "2021-02-03";
  pname = "oh-my-bash";
  rev = "4db7436384e0ddfa62911a101b69dd03a0df53fe";

  src = fetchFromGitHub {
    inherit rev;
    owner = "ohmybash";
    repo = "oh-my-bash";
    sha256 = "sha256-F8ibVqfV8i4PCQWNO9YdmOMA2R9VK4jVRpWpiEnUjtY=";
  };

  installPhase = ''
    runHook preInstall

    outdir=$out/share/oh-my-bash
    template=templates/bashrc.osh-template

    mkdir -p $outdir
    cp -r * $outdir
    cd $outdir

    rm LICENSE.md
    rm -rf .git*

    chmod -R +w templates

    # Change the path to oh-my-zsh dir and disable auto-updating.
    sed -i -e "s#OSH=\$HOME/.oh-my-bash#OSH=$outdir#" \
           -e 's/\# \(DISABLE_AUTO_UPDATE="true"\)/\1/' \
     $template

    chmod +w oh-my-bash.sh

    # Both functions expect oh-my-zsh to be in ~/.oh-my-zsh and try to
    # modify the directory.
    cat >> oh-my-bash.sh <<- EOF

    # Undefine functions that don't work on Nix.
    unset -f uninstall_oh_my_bash
    unset -f upgrade_oh_my_bash
    EOF

    runHook postInstall
  '';

  passthru = {
    tests = { inherit (nixosTests) oh-my-zsh; };

    updateScript = writeScript "update.sh" ''
      #!${stdenv.shell}
      set -o errexit
      PATH=${
        lib.makeBinPath [
          common-updater-scripts
          curl
          cacert
          git
          nixfmt
          nix
          jq
          coreutils
          gnused
        ]
      }

      oldVersion="$(nix-instantiate --eval -E "with import ./. {}; lib.getVersion oh-my-bash" | tr -d '"')"
      latestSha="$(curl -L -s https://api.github.com/repos/ohmybash/oh-my-bash/commits\?sha\=master\&since\=$oldVersion | jq -r '.[0].sha')"

      if [ ! "null" = "$latestSha" ]; then
        nixpkgs="$(git rev-parse --show-toplevel)"
        default_nix="$nixpkgs/pkgs/shells/bash/oh-my-bash/default.nix"
        latestDate="$(curl -L -s https://api.github.com/repos/ohmybash/oh-my-bash/commits/$latestSha | jq '.commit.committer.date' | sed 's|"\(.*\)T.*|\1|g')"
        update-source-version oh-my-bash "$latestSha" --version-key=rev
        update-source-version oh-my-bash "$latestDate" --ignore-same-hash
        nixfmt "$default_nix"
      else
        echo "${pname} is already up-to-date"
      fi
    '';
  };

  meta = with lib; {
    description = "A framework for managing your bash configuration";
    longDescription = ''
      Oh My Bash is a framework for managing your bash configuration.

      To copy the Oh My Bash configuration file to your home directory, run
      the following command:

        $ cp -v $(nix-env -q --out-path oh-my-bash | cut -d' ' -f3)/share/oh-my-bash/templates/bashrc.bash-template ~/.bashrc
    '';
    homepage = "https://ohmybash.github.io/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ abbe ];
  };
}

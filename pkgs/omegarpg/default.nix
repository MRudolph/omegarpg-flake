{
  stdenv,
  omegarpgSrc,
  qt
}:
stdenv.mkDerivation {

  src = omegarpgSrc;
  
  buildInputs = with qt; [ qtbase qtmultimedia qmake];
  nativeBuildInputs = with qt; [ wrapQtAppsHook ];
  name = "omegarpg";
  installPhase = ''
    mkdir -p $out/bin
    cp OmegaRPG/OmegaRPG $out/bin
    cp OmegaRPG-Server-CLI/OmegaRPG-Server-CLI $out/bin
    cp OmegaRPG-Server-GUI/OmegaRPG-Server-GUI $out/bin
    mkdir -p $out/share/pixmaps
    cp icons/omegarpg.png $out/share/pixmaps/omegarpg.png
    mkdir -p $out/share/applications
    cp distribution/OmegaRPG.desktop $out/share/applications/OmegaRPG.desktop
  '';
}
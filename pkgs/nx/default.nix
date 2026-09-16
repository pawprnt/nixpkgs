{ lib
, rustPlatform
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage {
  pname = "nx";
  version = "0.1.0";

  src = ../../nx;

  cargoLock.lockFile = ../../nx/Cargo.lock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "A nix helper CLI";
    homepage = "https://github.com/foxinwinter/nx";
    license = licenses.mit;
    mainProgram = "nx";
  };
}

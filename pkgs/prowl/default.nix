{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  bountyData = fetchFromGitHub {
    owner = "arkadiyt";
    repo = "bounty-targets-data";
    rev = "b5a63896f664fb4a6086a0d098e9b7d14abfc340";
    hash = "sha256-xsdPXVJzIN7TipNCa+ELnCNu0W6QxsUaQSyalyzIM0k=";
  };
in
buildGoModule {
  pname = "prowl";
  version = "1.0.0";
  vendorHash = null;

  src = fetchFromGitHub {
    owner = "pawprnt";
    repo = "prowl";
    rev = "master";
    hash = "sha256-Z7OPYKDcV4lmWoAvIisi1GFIbCFx4fQPbBnVpCpxI54=";
  };

  postPatch = ''
    rm -rf data/bounty-data
    cp -r ${bountyData} data/bounty-data
  '';

  ldflags = [
    "-s" "-w"
    "-X" "main.version=1.0.0"
  ];

  meta = with lib; {
    description = "Comprehensive security research CLI tool with 175+ commands and 42+ scanner modules";
    homepage = "https://github.com/pawprnt/prowl";
    license = licenses.mit;
    mainProgram = "prowl";
  };
}

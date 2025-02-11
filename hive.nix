{
  inputs,
  outputs,
  ...
}: {
  meta = {
    nixpkgs = import inputs {
      system = "x86_64-linux";
    };
    specialArgs = {inherit inputs outputs;};
  };
  lab = {
    deployment = {
      targetHost = "192.168.2.87";
      targetUser = "root";
    };
    # imports = nixosSystems.lab.modules;
  };
  mobile-lab = {
    deployment = {
      targetHost = "192.168.2.110";
      targetUser = "root";
    };
  };
  nixos-testing = {
    deployment = {
      targetHost = "192.168.2.114";
      targetUser = "root";
    };
    # imports = nixosSystems.nixos-testing.modules;
  };
  liminality-srv1 = {
    deployment = {
      targetHost = "152.53.82.201";
      targetUser = "root";
    };
    # imports = nixosSystems.liminality-srv1.modules;
  };
  monitoring = {
    deployment = {
      targetHost = "192.168.2.63";
      targetUser = "root";
    };
    # imports = nixosSystems.liminality-srv1.modules;
  };
}

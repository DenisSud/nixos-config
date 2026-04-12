{
  description = "Local flake templates";
  outputs =
    { self }:
    {
      templates = {
        # django = {
        #   path = ./django;
        #   description = "Django + postgres + redis dev environment";
        # };
      };
    };
}

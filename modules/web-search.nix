{
  pkgs,
  ...
}:

{
  # ── SearXNG: local metasearch for the pi web_search tool ───────────────
  # Self-hosted so concurrent agents never hit an API quota. The pi
  # extension (pi-setup extensions/web-search) queries 127.0.0.1:8888.
  # Engines: keep_only trims the default set to sources reachable from this
  # network; bing/privacywall are enabled on top (off by default upstream).
  services.searx = {
    enable = true;
    settings = {
      use_default_settings.engines.keep_only = [
        "google cse"
        "bing"
        "brave"
        "duckduckgo"
        "privacywall"
        "wikipedia"
      ];
      server = {
        bind_address = "127.0.0.1";
        port = 8888;
        secret_key = "pi-local-searx";
        limiter = false;
      };
      search = {
        formats = [
          "html"
          "json"
        ];
        safe_search = 0;
      };
      engines = [
        {
          name = "bing";
          disabled = false;
        }
        {
          name = "privacywall";
          disabled = false;
        }
      ];
    };
  };

  # Extraction backends for the pi web_fetch tool.
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: [ ps.trafilatura ])) # HTML → markdown
    poppler-utils # pdftotext (PDF → text)
  ];
}

{ pkgs, ... }:

{
  # ── Printing: CUPS + the home Epson ───────────────────
  # One declaratively provisioned queue for the Epson L3271
  # (L3270 series) on the home LAN. Jobs go over IPP to the
  # printer's stable mDNS name; avahi + nss-mdns resolve it.
  services.printing = {
    enable = true;
    # ESC/P-R driver — ships the L3270 Series PPD. Unlike the
    # driverless "everywhere" model, queue setup needs no contact
    # with the printer (and it keeps full 1440x720 dpi).
    drivers = [ pkgs.epson-escpr ];

    # Deterministic single queue: cups-browsed follows
    # services.avahi.enable by default and would add a second,
    # driverless queue for the same printer.
    browsed.enable = false;
  };

  # mDNS so `EPSONC533DC.local` resolves (CUPS backends use getaddrinfo).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "EPSON_L3270";
        description = "Epson L3271 (L3270 Series)";
        location = "Home";
        deviceUri = "ipp://EPSONC533DC.local/ipp/print";
        # Relative to CUPS' model dir; provided by `pkgs.epson-escpr`
        # via `services.printing.drivers`.
        model = "epson-inkjet-printer-escpr/Epson-L3270_Series-epson-escpr-en.ppd";
      }
    ];
    ensureDefaultPrinter = "EPSON_L3270";
  };
}

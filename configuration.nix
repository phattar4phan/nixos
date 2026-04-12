{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.crossmacro.nixosModules.default
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.timeServers = [ "time.google.com" "time1.google.com" "pool.ntp.org" ];

  # Networking for spotify
  networking.firewall.allowedTCPPorts = [ 57621 ]; #sync local tracks from your filesystem with mobile devices in the same network
  networking.firewall.allowedUDPPorts = [ 5353 ]; #enable discovery of Google Cast devices (and possibly other Spotify Connect devices) in the same network by the Spotify app

  # Timezone
  time.timeZone = "Asia/Bangkok";
  services.timesyncd = {
    enable = true;
    servers = [ "time.google.com" "time1.google.com" "pool.ntp.org" ];
  };

  # Locales
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "th_TH.UTF-8";
    LC_IDENTIFICATION = "th_TH.UTF-8";
    LC_MEASUREMENT = "th_TH.UTF-8";
    LC_MONETARY = "th_TH.UTF-8";
    LC_NAME = "th_TH.UTF-8";
    LC_NUMERIC = "th_TH.UTF-8";
    LC_PAPER = "th_TH.UTF-8";
    LC_TELEPHONE = "th_TH.UTF-8";
    LC_TIME = "th_TH.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
    ];
  };

  #github configs
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "pxzc1";
        email = "phattar4phan@gmail.com";
      };
    };
  };

  # Users
  users.users.phattaraphan = {
    isNormalUser = true;
    description = "Phattaraphan";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "uinput" "crossmacro"]; # added video for NVIDIA
    packages = with pkgs; [];
  };

  users.groups.uinput = {};

  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  programs.crossmacro = {
    enable = true;
    users = [ "phattaraphan" ];
  };

  # Allow unfree packages (required for NVIDIA, VSCode)
  nixpkgs.config.allowUnfree = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "hyprland";
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      ubuntu-classic       # Provides Ubuntu Mono
      noto-fonts   # Thai fallback
    ];

    fontconfig = {
      defaultFonts = {
        # This sets the order of preference for monospace (used by Kitty)
        monospace = [ "Ubuntu Mono" "Noto Sans Thai" ];
        serif     = [ "Ubuntu" "Noto Serif Thai" ];
        sansSerif = [ "Ubuntu" "Noto Sans Thai" ];
      };
    };
  };
  
  services.asusd.enable = true;
  # services.supergfxd.enable = true; (remove # if want hybrid graphics, iGPU + dGPU)

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";

    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    LIBVA_DRIVER_NAME = "nvidia";

    OBS_USE_EGL = "1";
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # shell aliases
  environment.shellAliases = {
    brightset = "brightnessctl set";
    firefox = "setsid firefox >/dev/null 2>&1 &";
    mute = "pamixer -m";
    unmute = "pamixer -u";
    prism = "setsid prismlauncher >/dev/null 2>&1 &";
    px = "pamixer";
    discord = "setsid discord >/dev/null 2>&1 &";
    roblox = "setsid flatpak run org.vinegarhq.Sober >/dev/null 2>&1 &";
    nautilus = "setsid nautilus >/dev/null 2>&1 &";
    davinci = "setsid davinci-resolve >/dev/null 2>&1 &";
    vlc = "setsid vlc >/dev/null 2>&1 &";
    loupe = "setsid loupe >/dev/null 2>&1 &";
    blender = "setsid blender >/dev/null 2>&1 &";
    deact = "deactivate"; #only for deactivate from python virtualenv
    libreoffice = "setsid libreoffice >/dev/null 2>&1 &";
    cm = "setsid crossmacro >/dev/null 2>&1 &";
    gimp = "setsid gimp >/dev/null 2>&1 &";
    krita = "setsid krita >/dev/null 2>&1 &";
    pinta = "setsid pinta >/dev/null 2>&1 &";
    steam = "setsid steam >/dev/null 2>&1 &";
    antigravity = "setsid antigravity >/dev/null 2>&1 &";
    tradingview = "setsid tradingview >/dev/null 2>&1 &";
    chrome = "setsid google-chrome-stable >/dev/null 2>&1 &";
    mt5 = "setsid wine ~/.wine/drive_c/Program\ Files/MetaTrader\ 5/terminal.exe >/dev/null 2>&1 &";
  };

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # for nautilus file manager to avoid no mount, no trash, slow startup
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;

  # steam
  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
  };

  # System packages
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    vscode-fhs
    kitty
    firefox
    gcc
    cmake
    gdb
    ninja
    python313
    python313Packages.pip
    git
    hyprpaper
    polkit_gnome
    brightnessctl
    prismlauncher
    unzip
    btop
    pamixer
    discord
    asusctl
    nautilus
    acpi
    tuigreet
    tree
    vlc
    loupe #eog (gnome) / feh (terminal-friendly)
    mako
    libnotify
    blender
    davinci-resolve
    xxd
    bat
    fastfetch
    grim
    slurp
    libreoffice-fresh
    nodejs
    lsof
    rustup
    appimage-run
    gimp
    krita
    pinta
    webkitgtk_4_1
    gtk3
    gsettings-desktop-schemas
    antigravity-fhs
    gamescope
    claude-code
    gemini-cli
    wineWowPackages.waylandFull
    winetricks
    wget
    bibata-cursors
    tradingview
    google-chrome
    ffmpeg-full
    obs-studio
    fx
    jq
  ];
  
  # enable polkit (PolicyKit) agent
  security.polkit.enable = true;

  # Kernel & NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1" 
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  # Greetd login manager with session choice
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Use tuigreet to ask for credentials before starting Hyprland
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter"; 
      };
    };
  };

  swapDevices = [
    { device = "/swapfile"; size = 8*1024; }
  ];

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
  };

  # Enable experimental Nix features
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 5368709120; # 5GB in bytes
    auto-optimise-store = true; # Merges identical files to save space
    substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ]; #for binary cache
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.kernelModules = [ "uinput" ];

  # hides old stuff from the boot menu but keeps them on disk for 7 days.
  boot.loader.systemd-boot.configurationLimit = 5;

  system.stateVersion = "25.11";
}

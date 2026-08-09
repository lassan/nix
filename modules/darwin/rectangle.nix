{lib, ...}: let
  # NSEvent.ModifierFlags, the encoding Rectangle stores in its plist.
  modifiers = {
    shift = 131072;
    control = 262144;
    option = 524288;
    command = 1048576;
  };

  # ANSI virtual key codes.
  keys = {
    A = 0;
    B = 11;
    C = 8;
    D = 2;
    E = 14;
    F = 3;
    G = 5;
    H = 4;
    I = 34;
    J = 38;
    K = 40;
    L = 37;
    M = 46;
    N = 45;
    O = 31;
    P = 35;
    Q = 12;
    R = 15;
    S = 1;
    T = 17;
    U = 32;
    V = 9;
    W = 13;
    X = 7;
    Y = 16;
    Z = 6;
  };

  shortcut = mods: key: {
    keyCode = keys.${key};
    modifierFlags = lib.foldl' (total: mod: total + modifiers.${mod}) 0 mods;
  };

  # An empty dict is how Rectangle records a deliberately unbound action.
  # Omitting the key restores its default binding instead.
  unbound = {};

  hyper = ["control" "option" "command"];
  meh = ["control" "option"];
in {
  system.defaults.CustomUserPreferences."com.knollsoft.Rectangle" = {
    center = shortcut hyper "M";
    larger = shortcut hyper "L";
    smaller = shortcut hyper "H";
    lastThreeFourths = shortcut hyper "F";
    topLeftSixth = shortcut hyper "D";

    centerHalf = shortcut meh "S";
    firstFourth = shortcut meh "F";
    reflowTodo = shortcut meh "N";
    toggleTodo = shortcut meh "B";

    almostMaximize = unbound;
    centerThird = unbound;

    # Everything not bound above falls back to this set, so the bindings here
    # are only reproducible alongside it.
    alternateDefaultShortcuts = 1;

    allowAnyShortcut = 0;
    hapticFeedbackOnSnap = 2;
    hideMenubarIcon = 1;
    launchOnLogin = 1;
    subsequentExecutionMode = 1;
    footprintAnimationDurationMultiplier = "0.75";

    SUEnableAutomaticChecks = 0;
  };
}

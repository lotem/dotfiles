import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog

main = xmonad =<< xmobar desktopConfig
     { terminal = "gnome-terminal"
     , modMask = mod4Mask
     }

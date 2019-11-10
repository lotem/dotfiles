import XMonad
import XMonad.Config.Desktop

main = xmonad desktopConfig
     { terminal = "gnome-terminal"
     , modMask = mod4Mask
     }

import XMonad
import XMonad.Config.Desktop

main = xmonad desktopConfig
     { modMask = mod4Mask
     }

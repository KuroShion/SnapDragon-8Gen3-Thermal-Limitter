SKIPUNZIP=0

ui_print "**********************************************"
ui_print "  MIX Flip Thermal Limiter (V1.0 Normal Mode) "
ui_print "               Author: Kuro Shion             "
ui_print "         GitHub: https://github.com/KuroShion "
ui_print "          Telegram: https://t.me/KuroShion    "
ui_print "**********************************************"
ui_print "- Device: Xiaomi MIX Flip (ruyi)"
ui_print "- Target: Snapdragon 8 Gen 3 (SM8650)"
ui_print "- Mode: Normal Mode (Slight Downclock)"
ui_print "- Cortex-X4: 3.30GHz -> ~2.80GHz"
ui_print "- Cortex-A720 Big: 3.15GHz -> ~2.61GHz"
ui_print "- Cortex-A720 Mid: 2.96GHz -> ~2.47GHz"
ui_print "- Disabling swipe touch boost spikes..."
ui_print "- Locking refresh rate to 120Hz..."
ui_print "- Setting up WALT scheduler thresholds..."

set_perm $MODPATH/service.sh 0 0 0755

ui_print " "
ui_print "- Installation completed successfully!"
ui_print "- Please reboot your device to activate."
ui_print "**********************************************"

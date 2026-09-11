# ❄️ Xiaomi MIX Flip Thermal Limiter Suite (SM8650)

[![KernelSU](https://img.shields.io/badge/Root-KernelSU%20%7C%20Magisk-orange?style=flat-square)](https://github.com/KuroShion)
[![Tested On](https://img.shields.io/badge/Tested%20On-Xiaomi%20MIX%20Flip%20(ruyi)-blue?style=flat-square)](https://github.com/KuroShion)
[![SoC](https://img.shields.io/badge/SoC-Snapdragon%208%20Gen%203-red?style=flat-square)](https://github.com/KuroShion)
[![Developer](https://img.shields.io/badge/Developer-Kuro%20Shion-green?style=flat-square)](https://github.com/KuroShion)
[![Telegram](https://img.shields.io/badge/Telegram-@KuroShion-2CA5E0?style=flat-square&logo=telegram)](https://t.me/KuroShion)

> [!NOTE]
> **Tested on Xiaomi MIX Flip (`ruyi`)**, but should be fully suitable for any other rooted **Snapdragon 8 Gen 3 (SM8650)** device running KernelSU or Magisk. Test with your own **RISKS!**

---

## 🧐 The Problem: Why Does the MIX Flip Overheat?

1. **The Snapdragon 8 Gen 3 "Touchboost Trap":**
   The Cortex-X4 prime core boosts up to 3.30 GHz (pulling 5W+ alone) on every screen touch. When scrolling short videos (TikTok, Instagram Reels, YouTube Shorts), you swipe every 10–15 seconds—meaning the CPU **never returns to idle** and runs at peak wattage continuously.
2. **Compact Clamshell Form Factor:**
   All heat-generating components (SoC, cameras, PMIC, fast-charging IC) are crammed into the small top half behind the cover display. Heat cannot easily dissipate across the hinge, causing the top half to reach 45°C+ quickly.
3. **HyperOS Refresh Rate Inconsistencies:**
   HyperOS often drops the screen refresh rate to 60Hz during video playback while simultaneously over-boosting CPU clocks.

---

## ⚡ The Solution

This suite intercepts Qualcomm's governor and powerHAL to:
* **Cap Peak Frequencies:** Keeps the Cortex-X4 and A720 cores at their sweet-spot efficiency curve.
* **Kill Aggressive Touchboost:** Thumb swipes will no longer trigger 3.3 GHz power spikes.
* **Lock All-Time 120Hz:** Forces 120Hz display refresh rate everywhere without frame drops.
* **Tune Qualcomm WALT Scheduler:** Biases UI and video decoding threads to efficiency cores.
* **Watchdog Protection:** A low-overhead background daemon restores limits if HyperOS thermal services attempt to reset them.

---

## 📦 Release Editions

Choose the edition that fits your workflow:

| Edition | Cortex-X4 (Prime) | Cortex-A720 (Big) | Cortex-A720 (Mid) | Target Use-Case |
| :--- | :---: | :---: | :---: | :--- |
| **Normal Mode (V1.0)** | **2.80 GHz** | **2.61 GHz** | **2.47 GHz** | **Default / Recommended.** Retains ~95% flagship power while eliminating high-wattage thermal spikes. |
| **Power Mode** | **2.57 GHz** | **2.30 GHz** | **2.18 GHz** | **Daily Driver.** Enhanced battery life and cooler chassis during multitasking. |
| **Extreme Mode** | **2.26 GHz** | **2.09 GHz** | **1.95 GHz** | **Cool Thermals.** Zero overheating under warm weather or direct sunlight. |
| **Ultra Mode** | **1.95 GHz** | **1.78 GHz** | **1.65 GHz** | **Maximum Battery.** Ice-cold phone, extreme Screen-On Time (SOT). |
| **Flip Device Mode** | **2.26 GHz** | **2.40 GHz** | **2.18 GHz** | **Clamshell Tuned.** 0ms touchboost + task isolation away from the top hinge. |

---

## 📲 Installation Guide

### Requirements:
* Xiaomi MIX Flip (or other Snapdragon 8 Gen 3 device).
* Bootloader unlocked.
* **KernelSU** or **Magisk** installed.

### Steps:
1. Go to the [**Releases**](https://github.com/KuroShion) section.
2. Download the `.zip` edition you want to use.
3. Open **KernelSU** or **Magisk** app on your phone.
4. Go to **Modules** ➔ **Install from storage**.
5. Select the `.zip` file and let it flash.
6. **Reboot** your device.

---

## 🔍 How to Verify It's Working

Connect your phone to your PC via USB or open a terminal app (like Termux) as root (`su`):

```bash
# Check Cortex-X4 max frequency
cat /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq

# Check display refresh rate setting
settings get system min_refresh_rate

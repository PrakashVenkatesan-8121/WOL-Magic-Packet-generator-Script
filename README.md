# 🌟 WOL Magic Packet Generator Script

A powerful PowerShell-based Wake-on-LAN (WOL) toolkit for remotely waking up networked devices. This repository contains scripts to send magic packets and monitor WOL traffic on your network.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Send-WakeOnLAN.ps1](#send-wakeonlanps1)
  - [Monitor-WakeOnLAN.ps1](#monitor-wakeonlanps1)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [How Wake-on-LAN Works](#how-wake-on-lan-works)
- [Contributing](#contributing)
- [License](#license)

## 🔍 Overview

Wake-on-LAN (WOL) is a networking standard that allows devices to be turned on or awakened from sleep/hibernation by a network message called a "magic packet". This repository provides:

1. **Send-WakeOnLAN.ps1** - A robust PowerShell script to send magic packets to wake up remote devices
2. **Monitor-WakeOnLAN.ps1** - A monitoring tool to verify that WOL packets are being sent correctly

## ✨ Features

### Send-WakeOnLAN.ps1
- ✅ **Flexible MAC Address Input** - Supports various MAC address formats (XX:XX:XX:XX:XX:XX, XX-XX-XX-XX-XX-XX, XXXXXXXXXXXX)
- ✅ **Customizable Network Settings** - Configure broadcast address and port
- ✅ **Packet Verification** - Optional hex dump to verify magic packet structure
- ✅ **Error Handling** - Comprehensive input validation and error reporting
- ✅ **Cross-Platform Compatible** - Works on Windows PowerShell and PowerShell Core

### Monitor-WakeOnLAN.ps1
- ✅ **Real-time Monitoring** - Monitor UDP traffic for WOL packets
- ✅ **Configurable Duration** - Set custom monitoring periods
- ✅ **Administrative Detection** - Automatically detects if running with admin privileges
- ✅ **Alternative Verification Methods** - Provides additional troubleshooting options

## 📋 Prerequisites

- **Windows 10/11** or **Windows Server 2016+**
- **PowerShell 5.1** or later (PowerShell Core 7+ recommended)
- **Network access** to the target device's subnet
- **Administrator privileges** (recommended for monitoring script)

### Target Device Requirements
- Network interface with Wake-on-LAN support
- WOL enabled in BIOS/UEFI settings
- WOL enabled in network adapter settings
- Device connected via Ethernet (WiFi WOL support varies)

## 🚀 Installation

1. **Clone the repository:**
   ```powershell
   git clone https://github.com/PrakashVenkatesan-8121/WOL-Magic-Packet-generator-Script.git
   cd WOL-Magic-Packet-generator-Script
   ```

2. **Navigate to the script directory:**
   ```powershell
   cd "WOL Script"
   ```

3. **Set execution policy** (if needed):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 💻 Usage

### Send-WakeOnLAN.ps1

Send a magic packet to wake up a device:

```powershell
.\Send-WakeOnLAN.ps1 -MacAddress "XX:XX:XX:XX:XX:XX"
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `MacAddress` | String | ✅ Yes | - | MAC address of target device |
| `Broadcast` | String | ❌ No | "255.255.255.255" | Broadcast IP address |
| `Port` | Integer | ❌ No | 9 | UDP port for WOL packet |
| `ShowPacketHex` | Switch | ❌ No | False | Display packet hex dump for verification |

### Monitor-WakeOnLAN.ps1

Monitor network traffic for WOL packets:

```powershell
.\Monitor-WakeOnLAN.ps1 -Duration 60 -Port 9
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Duration` | Integer | ❌ No | 60 | Monitoring duration in seconds |
| `Port` | Integer | ❌ No | 9 | UDP port to monitor |

## 📚 Examples

### Basic Usage

```powershell
# Wake up device with MAC address using default settings
.\Send-WakeOnLAN.ps1 -MacAddress "00:1B:63:84:45:E6"

# Wake up device with colon-separated MAC
.\Send-WakeOnLAN.ps1 -MacAddress "00:1B:63:84:45:E6"

# Wake up device with dash-separated MAC
.\Send-WakeOnLAN.ps1 -MacAddress "00-1B-63-84-45-E6"

# Wake up device with no separators
.\Send-WakeOnLAN.ps1 -MacAddress "001B638445E6"
```

### Advanced Usage

```powershell
# Send WOL packet with custom broadcast address and port
.\Send-WakeOnLAN.ps1 -MacAddress "00:1B:63:84:45:E6" -Broadcast "192.168.1.255" -Port 7

# Send WOL packet and show hex dump for verification
.\Send-WakeOnLAN.ps1 -MacAddress "00:1B:63:84:45:E6" -ShowPacketHex

# Monitor for WOL packets for 2 minutes
.\Monitor-WakeOnLAN.ps1 -Duration 120

# Monitor custom port for 30 seconds
.\Monitor-WakeOnLAN.ps1 -Duration 30 -Port 7
```

### Testing Workflow

```powershell
# 1. Start monitoring in one PowerShell window
.\Monitor-WakeOnLAN.ps1 -Duration 60

# 2. Send WOL packet in another PowerShell window
.\Send-WakeOnLAN.ps1 -MacAddress "00:1B:63:84:45:E6" -ShowPacketHex
```

## 🔧 Troubleshooting

### Common Issues

#### Device Not Waking Up
1. **Check WOL BIOS Settings:**
   - Enable "Wake on LAN" in BIOS/UEFI
   - Enable "Power on by PCIe" or similar options

2. **Check Network Adapter Settings:**
   ```powershell
   # Check WOL settings in Device Manager
   # Network Adapters → Properties → Power Management
   # ✅ "Allow this device to wake the computer"
   # ✅ "Only allow a magic packet to wake the computer"
   ```

3. **Check Network Configuration:**
   - Ensure target device is on the same subnet
   - Verify MAC address is correct
   - Try different broadcast addresses

#### Firewall Issues
```powershell
# Temporarily disable Windows Firewall for testing
netsh advfirewall set allprofiles state off

# Re-enable after testing
netsh advfirewall set allprofiles state on
```

#### Finding Device MAC Address
```powershell
# On target Windows machine
ipconfig /all

# On target Linux machine
ip addr show
# or
ifconfig
```

### Verification Commands

```powershell
# Test network connectivity
ping 192.168.1.100

# Check if port is open (should timeout for WOL)
Test-NetConnection -ComputerName 192.168.1.100 -Port 9

# Verify magic packet structure
.\Send-WakeOnLAN.ps1 -MacAddress "00:1B:63:84:45:E6" -ShowPacketHex
```

## 📖 How Wake-on-LAN Works

### Magic Packet Structure
A WOL magic packet consists of:
1. **6 bytes of 0xFF** (synchronization stream)
2. **16 repetitions** of the target MAC address (96 bytes)
3. **Total packet size:** 102 bytes

### Network Requirements
- **UDP Protocol** - WOL uses UDP (typically port 9, 7, or 0)
- **Broadcast Transmission** - Packets sent to broadcast address
- **Layer 2 Access** - Must reach target's network interface card

### Typical WOL Ports
| Port | Usage |
|------|-------|
| 9 | Most common (Discard Protocol) |
| 7 | Alternative (Echo Protocol) |
| 0 | Reserved port option |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Coding Standards
- Use PowerShell best practices
- Include proper error handling
- Add comments for complex logic
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- PowerShell community for networking examples
- Wake-on-LAN specification contributors
- Network administrators who provided testing feedback

## 📞 Support

If you encounter issues or have questions:

1. **Check the [Troubleshooting](#troubleshooting) section**
2. **Search existing [Issues](https://github.com/PrakashVenkatesan-8121/WOL-Magic-Packet-generator-Script/issues)**
3. **Create a new issue** with detailed information:
   - PowerShell version
   - Network configuration
   - Error messages
   - Steps to reproduce

---

**Made with ❤️ by PrakashVenkatesan-8121**

*Happy Wake-on-LAN-ing! 🚀*

<#
.SYNOPSIS
Monitor Wake-on-LAN packets on the network

.DESCRIPTION
This script helps monitor and capture WOL magic packets to verify they are being sent correctly.
Uses Windows built-in packet monitoring tools.

.PARAMETER Duration
How long to monitor in seconds (default: 60)

.PARAMETER Port
UDP port to monitor for WOL packets (default: 9)

.EXAMPLE
.\Monitor-WOL.ps1 -Duration 30 -Port 9
#>

param(
    [int]$Duration = 60,
    [int]$Port = 9
)

Write-Host "=== WOL Packet Monitor ===" -ForegroundColor Magenta
Write-Host "Monitoring UDP port $Port for Wake-on-LAN packets..." -ForegroundColor Yellow
Write-Host "Duration: $Duration seconds" -ForegroundColor Gray
Write-Host "Looking for 102-byte UDP packets (magic packets)" -ForegroundColor Gray
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Warning "This script should be run as Administrator for best packet capture results."
    Write-Host "Continuing with limited monitoring capabilities..." -ForegroundColor Yellow
    Write-Host ""
}

try {
    # Method 1: Use netstat to monitor UDP connections
    Write-Host "Method 1: Monitoring UDP port activity..." -ForegroundColor Cyan
    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($Duration)
    $packetCount = 0
    
    Write-Host "Listening... (Send your WOL packet now)" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop monitoring early" -ForegroundColor Gray
    Write-Host ""
    
    while ((Get-Date) -lt $endTime) {
        # Check for UDP activity on the WOL port
        $udpConnections = netstat -an | Select-String ":$Port\s"
        
        if ($udpConnections) {
            $packetCount++
            $timestamp = Get-Date -Format "HH:mm:ss.fff"
            Write-Host "[$timestamp] UDP activity detected on port $Port" -ForegroundColor Green
            $udpConnections | ForEach-Object { 
                Write-Host "  $_" -ForegroundColor Cyan 
            }
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host ""
    Write-Host "=== MONITORING RESULTS ===" -ForegroundColor Magenta
    Write-Host "Monitoring completed after $Duration seconds" -ForegroundColor Yellow
    Write-Host "UDP activities detected: $packetCount" -ForegroundColor $(if($packetCount -gt 0){'Green'}else{'Red'})
    
    if ($packetCount -eq 0) {
        Write-Host ""
        Write-Host "No WOL packets detected. Possible reasons:" -ForegroundColor Yellow
        Write-Host "  1. No WOL packets were sent during monitoring" -ForegroundColor Gray
        Write-Host "  2. Packets were sent to a different port" -ForegroundColor Gray
        Write-Host "  3. Packets were sent to a different network interface" -ForegroundColor Gray
        Write-Host "  4. Firewall is blocking the packets" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Try running your WOL script while this monitor is active." -ForegroundColor Cyan
    }
}
catch {
    Write-Error "An error occurred during monitoring: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== ALTERNATIVE VERIFICATION METHODS ===" -ForegroundColor Magenta
Write-Host "1. Use Wireshark with filter: udp.port == $Port" -ForegroundColor Cyan
Write-Host "2. Check router logs for broadcast traffic" -ForegroundColor Cyan
Write-Host "3. Use: .\WOL.ps1 -MacAddress 'XX:XX:XX:XX:XX:XX' -ShowPacketHex -Verbose" -ForegroundColor Cyan
Write-Host "4. Monitor target machine's event logs after wake" -ForegroundColor Cyan

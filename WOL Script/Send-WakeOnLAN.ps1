param(
    [Parameter(Mandatory=$true)]
    [string]$MacAddress,
    [string]$Broadcast = "255.255.255.255",
    [int]$Port = 9,
    [switch]$ShowPacketHex
)

function Send-WOLPacket {
    param(
        [string]$Mac,
        [string]$Broadcast,
        [int]$Port,
        [bool]$ShowHex = $false
    )

    Write-Host "Attempting to wake machine with MAC: $Mac" -ForegroundColor Yellow
    
    $macClean = $Mac -replace '[:-]', ''
    if ($macClean.Length -ne 12) {
        Write-Error "Invalid MAC address format."
        return $false
    }

    $macBytes = [byte[]]::new(6)
    for ($i=0; $i -lt 6; $i++) {
        $macBytes[$i] = [Convert]::ToByte($macClean.Substring($i*2,2),16)
    }

    $packet = [byte[]]::new(102)
    for ($i=0; $i -lt 6; $i++) { $packet[$i] = 0xFF }
    for ($i=1; $i -le 16; $i++) {
        [Array]::Copy($macBytes, 0, $packet, $i*6, 6)
    }

    # Show packet verification if requested
    if ($ShowHex) {
        Write-Host ""
        Write-Host "=== PACKET VERIFICATION ===" -ForegroundColor Magenta
        Write-Host "Packet size: $($packet.Length) bytes" -ForegroundColor Yellow
        
        Write-Host "First 32 bytes:" -ForegroundColor Yellow
        $hexStr = ""
        for ($i = 0; $i -lt 32; $i++) {
            $hexStr += "{0:X2} " -f $packet[$i]
            if (($i + 1) % 16 -eq 0) { 
                Write-Host $hexStr -ForegroundColor Cyan
                $hexStr = ""
            }
        }
        if ($hexStr) { Write-Host $hexStr -ForegroundColor Cyan }
        
        $syncOK = $true
        for ($i = 0; $i -lt 6; $i++) {
            if ($packet[$i] -ne 0xFF) { $syncOK = $false; break }
        }
        Write-Host "Sync pattern (6x FF): $(if($syncOK){'CORRECT'}else{'INCORRECT'})" -ForegroundColor $(if($syncOK){'Green'}else{'Red'})
        Write-Host ""
    }

    $udp = New-Object System.Net.Sockets.UdpClient
    $udp.Connect($Broadcast, $Port)
    $udp.Send($packet, $packet.Length) | Out-Null
    $udp.Close()
    
    Write-Host "Magic packet sent to $Mac via ${Broadcast}:${Port}" -ForegroundColor Green
    return $true
}

Send-WOLPacket -Mac $MacAddress -Broadcast $Broadcast -Port $Port -ShowHex $ShowPacketHex

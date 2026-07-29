param(
    [Parameter(Position=0)]
    [string]$param
)

# Definisci le risoluzioni supportate
$risoluzioniSupportate = @(
    '1024x768',
    '1280x800',
    '1366x768',
    '1440x900',
    '1600x900',
    '1680x1050',
    '1920x1080'
)

# Se nessun parametro fornito, mostra la sintassi
if ([string]::IsNullOrWhiteSpace($param)) {
    Write-Host "ntsetres - Imposta la risoluzione dello schermo" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Sintassi:" -ForegroundColor Cyan
    Write-Host "  .\ntsetres.ps1 <risoluzione>" -ForegroundColor White
    Write-Host ""
    Write-Host "Parametri supportati:" -ForegroundColor Cyan
    foreach ($res in $risoluzioniSupportate) {
        Write-Host "  $res" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Esempio:" -ForegroundColor Cyan
    Write-Host "  .\ntsetres.ps1 1920x1080" -ForegroundColor White
    exit 1
}

# Valida il parametro
$xyres = $param
if ($xyres -notin $risoluzioniSupportate) {
    Write-Host "Errore: Risoluzione '$xyres' non supportata" -ForegroundColor Red
    Write-Host ""
    Write-Host "Risoluzioni disponibili:" -ForegroundColor Yellow
    foreach ($res in $risoluzioniSupportate) {
        Write-Host "  $res" -ForegroundColor White
    }
    exit 1
}

# Funzione per impostare la risoluzione
function Set-ScreenResolution {
    param(
        [int]$Width,
        [int]$Height
    )
    
    try {
        # Definisci P/Invoke per le API Windows
        $pinvokeCode = @"
        [DllImport("user32.dll")]
        public static extern bool EnumDisplaySettings(string lpszDeviceName, uint iModeNum, ref DEVMODE lpDevMode);
        
        [DllImport("user32.dll")]
        public static extern int ChangeDisplaySettings(ref DEVMODE devMode, uint dwFlags);
        
        [StructLayout(LayoutKind.Sequential)]
        public struct DEVMODE
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
            public string dmDeviceName;
            public ushort dmSpecVersion;
            public ushort dmDriverVersion;
            public ushort dmSize;
            public ushort dmDriverExtra;
            public uint dmFields;
            public short dmOrientation;
            public short dmPaperSize;
            public short dmPaperLength;
            public short dmPaperWidth;
            public short dmScale;
            public short dmCopies;
            public short dmDefaultSource;
            public short dmPrintQuality;
            public short dmColor;
            public short dmDuplex;
            public short dmYResolution;
            public short dmTTOption;
            public short dmCollate;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
            public string dmFormName;
            public ushort dmLogPixels;
            public uint dmBitsPerPel;
            public uint dmPelsWidth;
            public uint dmPelsHeight;
            public uint dmDisplayFlags;
            public uint dmDisplayFrequency;
            public uint dmICMMethod;
            public uint dmICMIntent;
            public uint dmMediaType;
            public uint dmDitherType;
            public uint dmReserved1;
            public uint dmReserved2;
            public uint dmPanningWidth;
            public uint dmPanningHeight;
        }
"@
        
        Add-Type -MemberDefinition $pinvokeCode -Name Win32 -Namespace Win32 -ErrorAction Stop
        
        # Ottieni le impostazioni di visualizzazione correnti
        $devMode = New-Object Win32.Win32+DEVMODE
        $devMode.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($devMode)
        
        # Enum della prima modalità di visualizzazione
        [Win32.Win32]::EnumDisplaySettings($null, 0, [ref]$devMode) | Out-Null
        
        # Imposta i nuovi valori di risoluzione
        $devMode.dmPelsWidth = $Width
        $devMode.dmPelsHeight = $Height
        $devMode.dmFields = 0x80000 -bor 0x100000  # DM_PELSWIDTH | DM_PELSHEIGHT
        
        # Applica le impostazioni
        $result = [Win32.Win32]::ChangeDisplaySettings([ref]$devMode, 0)
        
        if ($result -eq 0) {
            return $true
        } else {
            Write-Host "Errore nel cambio risoluzione. Codice errore: $result" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Errore: $_" -ForegroundColor Red
        return $false
    }
}

# Estrai larghezza e altezza dal parametro
$resolution = $xyres -split 'x'
$width = [int]$resolution[0]
$height = [int]$resolution[1]

Write-Host "Impostazione risoluzione schermo a $width x $height..." -ForegroundColor Cyan

# Imposta la risoluzione
$success = Set-ScreenResolution -Width $width -Height $height

if ($success) {
    Write-Host "Risoluzione impostata con successo a $width x $height" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errore nell'impostazione della risoluzione" -ForegroundColor Red
    exit 1
}
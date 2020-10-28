function Get-RoboSize {
    [cmdletbinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $Path,

        [Parameter(
        Mandatory = $false
        )]
        [int]
        $DecimalPrecision = 2,

        [Parameter(
        Mandatory = $false
        )]
        [int]
        $Threads = 16
    )

    if (Get-Command -Name 'robocopy') {

        Write-Verbose -Message "Using robocopy to get size of path -> [$Path]"

        $args = @(
            "/L",
            "/S",
            "/NJH",
            "/BYTES",
            "/FP",
            "/NC",
            "/NDL",
            "/NFL",
            "/TS",
            "/XJ",
            "/R:0",
            "/W:0",
            "/MT:$Threads"
        )

        [DateTime]$startTime = [DateTime]::Now

        Write-Verbose "Running -> [robocopy $($Path) NULL $($args)] <-"
        [string]$summary     = robocopy $Path NULL $args
        [DateTime]$endTime   = [DateTime]::Now
        [regex]$headerRegex  = '\s+Total\s*Copied\s+Skipped\s+Mismatch\s+FAILED\s+Extras'
        [regex]$dirRegex     = 'Dirs\s*:\s*(?<DirCount>\d+)(?:\s+\d+){3}\s+(?<DirFailed>\d+)\s+\d+'
        [regex]$fileRegex    = 'Files\s*:\s*(?<FileCount>\d+)(?:\s+\d+){3}\s+(?<FileFailed>\d+)\s+\d+'
        [regex]$byteRegex    = 'Bytes\s*:\s*(?<ByteCount>\d+)(?:\s+\d+){3}\s+(?<BytesFailed>\d+)\s+\d+'
        [regex]$timeRegex    = 'Times\s*:\s*(?<TimeElapsed>\d+).*'
        [regex]$endRegex     = 'Ended\s*:\s*(?<EndedTime>.+)'

        Write-Verbose "Raw summary:"
        Write-Verbose ($summary | Out-String)

        $expectedSummary = "$headerRegex\s+$dirRegex\s+$fileRegex\s+$byteRegex\s+$timeRegex\s+$endRegex"
        if ($summary -match $expectedSummary) {

            $roboObject = [PSCustomObject]@{
                
                Path        = $Path
                TotalBytes  = [decimal]$Matches['ByteCount']
                TotalKB     = [math]::Round(([decimal] $Matches['ByteCount'] / 1KB), $DecimalPrecision)
                TotalMB     = [math]::Round(([decimal] $Matches['ByteCount'] / 1MB), $DecimalPrecision)
                TotalGB     = [math]::Round(([decimal] $Matches['ByteCount'] / 1GB), $DecimalPrecision)
                TimeElapsed = [math]::Round([decimal] ($endTime - $startTime).TotalSeconds, $DecimalPrecision)

            }

            return $roboObject

        }

    } else {

        throw "Robocopy command is not available... cannot continue!"

    }
}

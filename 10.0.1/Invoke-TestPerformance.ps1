$ErrorActionPreference = "STOP"

function Run
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Iterations
    )

    function Warmup
    {
        $response = Invoke-WebRequest -Method GET -Uri "http://localhost:44080/healthz/live" -ErrorAction SilentlyContinue -TimeoutSec 120 -SkipHttpErrorCheck

        if ($response.StatusCode -eq 200)
        {
            Write-Host "HTTP 200 OK."

            return
        }

        throw ("Warmup failed, response status code was {0}." -f $response.StatusCode)
    }

    for ($i = 0; $i -lt ($Iterations + 1); $i++)
    {
        # prepare
        Write-Host "### [$i of $Iterations] Preparing..."

        docker-compose --no-ansi down --volumes --remove-orphans

        $watch = [System.Diagnostics.Stopwatch]::StartNew()

        # measure build
        Write-Host "### [$i of $Iterations] Building..."

        $watch.Restart()

        docker-compose --no-ansi build | Write-Host

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }

        $buildTime = $watch.Elapsed.TotalMilliseconds

        # measure start
        Write-Host "### [$i of $Iterations] Starting..."

        $watch.Restart()

        docker-compose --no-ansi up --detach --remove-orphans | Write-Host

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }

        $startupTime = $watch.Elapsed.TotalMilliseconds

        # measure warmup
        Write-Host "### [$i of $Iterations] Warmup..."

        $watch.Restart()

        Warmup

        $warmupTime = $watch.Elapsed.TotalMilliseconds

        # measure recycle
        Write-Host "### [$i of $Iterations] Recycle..."

        $cm = (docker-compose ps --quiet cm)

        docker exec $cm powershell "(Get-Item -Path .\Web.config).LastWriteTime = Get-Date"

        $watch.Restart()

        Warmup

        $recycleTime = $watch.Elapsed.TotalMilliseconds

        # disregard interation 0 as it is considered warmup (ie. pulling images etc.)
        if ($i -eq 0)
        {
            continue;
        }

        # output timings
        Write-Output (New-Object PSObject -Property @{
                Iteration = $i;
                Build     = $buildTime;
                Startup   = $startupTime;
                Warmup    = $warmupTime;
                Recycle   = $recycleTime;
            })
    }
}

# run tests
$watch = [System.Diagnostics.Stopwatch]::StartNew()

$results = Run -Iterations 10

$total = $watch.Elapsed.TotalMinutes

# print stats
$results | Format-Table -Property Iteration, Build, Startup, Warmup, Recycle

$buildAvg = ($results | Measure-Object -Property Build -Average).Average
$startupAvg = ($results | Measure-Object -Property Startup -Average).Average
$warmupAvg = ($results | Measure-Object -Property Warmup -Average).Average
$recycleAvg = ($results | Measure-Object -Property Recycle -Average).Average

Write-Host ("Total      : {0:0.00} min" -f $total) -ForegroundColor Green
Write-Host ("Avg build  : {0:0.00} ms" -f $buildAvg) -ForegroundColor Green
Write-Host ("Avg startup: {0:0.00} ms" -f $startupAvg) -ForegroundColor Green
Write-Host ("Avg warmup : {0:0.00} ms" -f $warmupAvg) -ForegroundColor Green
Write-Host ("Avg recycle: {0:0.00} ms" -f $recycleAvg) -ForegroundColor Green
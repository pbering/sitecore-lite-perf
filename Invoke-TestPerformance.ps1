$ErrorActionPreference = "STOP"

function Run
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Iterations
    )

    # prepare
    Write-Host "### Preparing host..."

    docker-compose --no-ansi down --volumes --remove-orphans

    for ($i = 0; $i -lt ($Iterations + 1); $i++)
    {
        $watch = [System.Diagnostics.Stopwatch]::StartNew()

        # measure build
        Write-Host "### Building ($i of $Iterations)..."

        $watch.Restart()

        docker-compose --no-ansi build --no-cache | Write-Host

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }

        $buildTime = $watch.Elapsed.TotalMilliseconds

        # measure start
        Write-Host "### Starting ($i of $Iterations)..."

        $watch.Restart()

        docker-compose --no-ansi up --detach --remove-orphans | Write-Host

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }

        $startupTime = $watch.Elapsed.TotalMilliseconds

        # measure warmup
        Write-Host "### Warmup ($i of $Iterations)..."

        $watch.Restart()

        curl.exe -s "http://localhost:44080/sitecore/login" | Out-Null

        $warmupTime = $watch.Elapsed.TotalMilliseconds

        # don't count interation 0 as it is considered warmup (ie. pulling images etc.)
        if ($i -eq 0)
        {
            continue;
        }

        Write-Output (New-Object PSObject -Property @{
                Iteration = $i;
                Build     = $buildTime;
                Startup   = $startupTime;
                Warmup    = $warmupTime;
            })
    }
}

# run tests
$results = Run -Iterations 10

# print stats
$results | Format-Table -Property Iteration, Build, Startup, Warmup

$buildAvg = ($results | Measure-Object -Property Build -Average).Average
$startupAvg = ($results | Measure-Object -Property Startup -Average).Average
$warmupAvg = ($results | Measure-Object -Property Warmup -Average).Average

Write-Host ("Build  : {0:0.00} ms" -f $buildAvg) -ForegroundColor Green
Write-Host ("Startup: {0:0.00} ms" -f $startupAvg) -ForegroundColor Green
Write-Host ("Warmup : {0:0.00} ms" -f $warmupAvg) -ForegroundColor Green
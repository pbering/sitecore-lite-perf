# sitecore-lite-perf

Investigating massive increase in warmup time between 10.0.1 and 10.1.0.

10.0.1

```text
Total      :    12,77 min
Avg build  :  1501,60 ms
Avg startup: 36197,36 ms
Avg warmup : 17194,04 ms
Avg recycle:  5011,03 ms
```

10.1.0

```text
Total      :    17,13 min
Avg build  :  1516,41 ms
Avg startup: 36192,29 ms
Avg warmup : 40261,83 ms <--
Avg recycle:  6074,94 ms <--
```

To run tests, switch to each version directory and run `Invoke-TestPerformance.ps1`.

> Above numbers are tests done on the same machine, an AMD Ryzen 9 3900X CPU (3.8GHz/4.6GHz, 12 cores, 24 threads), 64 GB RAM, PCIe 4.0 NVMe SSD, you may not see the same numbers but you should see the same difference.

**UPDATE**: Here are the numbers from another machine, an Intel i7-8700K CPU (3.70GHz/4.70Ghz 6 cores, 12 threads), 32 GB RAM, PCEe 3.0 NVMe SSD:

10.0.1

```text
Total      :    13,25 min
Avg build  :  1216,60 ms
Avg startup: 37941,71 ms
Avg warmup : 18837,35 ms
Avg recycle:  5669,84 ms
```

10.1.0

```text
Total      :    15,49 min
Avg build  :  1216,48 ms
Avg startup: 38035,04 ms
Avg warmup : 23215,88 ms <--
Avg recycle:  6751,08 ms <--
```

## Observations

1. The `<retryer />` had to be enabled on 10.1.0 just to be able to run tests else it will fail during warmup with various SQL connection exceptions, this leads be to believe that it could be somehow SQL related.

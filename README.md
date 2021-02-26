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

## Observations

1. The `<retryer />` had to be enabled on 10.1.0 just to be able to run tests else it will fail during warmup with various SQL connection exceptions, this leads be to believe that it could be somehow SQL related.

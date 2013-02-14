## Benchmarking

    $ node-bench ./bench/async-resolve_vs_other.js 
    benchmarking /Users/meettya/github/async-resolve/bench/async-resolve_vs_other
    Please be patient.
    Scores: (bigger is better)

    async-resolve
    Raw:
     > 1.539855072463768
     > 1.6865079365079365
     > 1.4164305949008498
     > 0.847457627118644
    Average (mean) 1.3725628077477996

    enhanced-resolve
    Raw:
     > 0.5660377358490566
     > 0.5571030640668524
     > 0.5258545135845749
     > 0.6416131989000916
    Average (mean) 0.5726521281001439

    localizer
    Raw:
     > 0.42955326460481097
     > 0.6386861313868614
     > 0.6060606060606061
     > 0.4942339373970346
    Average (mean) 0.5421334848623283

    node-resolve *sync*
    Raw:
     > 0.4084967320261438
     > 0.19665683382497542
     > 0.3968253968253968
     > 0.45126353790613716
    Average (mean) 0.3633106251456633

    Winner: async-resolve
    Compared with next highest (enhanced-resolve), it's:
    58.28% faster
    2.4 times as fast
    0.38 order(s) of magnitude faster
    QUITE A BIT FASTER

    Compared with the slowest (node-resolve *sync*), it's:
    73.53% faster
    3.78 times as fast
    0.58 order(s) of magnitude faster
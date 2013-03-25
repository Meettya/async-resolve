## Benchmarking

    $ node-bench ./bench/async-resolve_vs_other.js 
    benchmarking /Users/meettya/github/async-resolve/bench/async-resolve_vs_other
    Please be patient.
     Scores: (bigger is better)

    async-resolve
    Raw:
     > 1.7769002961500493
     > 1.744186046511628
     > 1.7424975798644724
     > 1.7126546146527117
    Average (mean) 1.7440596342947152

    node-resolve *async*
    Raw:
     > 0.5703422053231939
     > 0.6151142355008787
     > 0.5808325266214908
     > 0.5695687550854354
    Average (mean) 0.5839644306327497

    enhanced-resolve
    Raw:
     > 0.591715976331361
     > 0.6776379477250726
     > 0.47664442326024786
     > 0.5853658536585366
    Average (mean) 0.5828410502438045

    localizer
    Raw:
     > 0.535475234270415
     > 0.363901018922853
     > 0.6364922206506365
     > 0.3776435045317221
    Average (mean) 0.4783779945939066

    node-resolve *sync*
    Raw:
     > 0.4668534080298786
     > 0.42771599657827203
     > 0.45167118337850043
     > 0.44923629829290207
    Average (mean) 0.44886922156988834

    Winner: async-resolve
    Compared with next highest (node-resolve *async*), it's:
    66.52% faster
    2.99 times as fast
    0.48 order(s) of magnitude faster
    QUITE A BIT FASTER

    Compared with the slowest (node-resolve *sync*), it's:
    74.26% faster
    3.89 times as fast
    0.59 order(s) of magnitude faster
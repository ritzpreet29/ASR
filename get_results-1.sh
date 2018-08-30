#!/usr/bin/env bash

ROOTDIR=~/asrworkdir
PRJDIR=$ROOTDIR/my-local
EXPDIR=$ROOTDIR/exp

# CSV
#

prefix=tri_t2
result=log_likelihood_for_task2

echo -n "" > $result

for d in `ls -d1 $EXPDIR/$prefix*`; do

    best_wer=$d/decode_test/scoring_kaldi/best_wer
    tr_dir=$d/log
    ts_dir=$d/decode_test/log
    if [ -f $best_wer ] && [ -d $ts_dir ]; then
        n=${d#$EXPDIR/${prefix}_}

        wer=`more $best_wer | sed -n -r "s/%.*WER ([[:digit:]]+\.[[:digit:]]+).*/\1/p"`
        g=$(gmm-info $d/final.mdl |\
            sed -n -r "s/number of gaussians.* ([[:digit:]]+).*/\1/p")
        l=$(sed -n -r "s/.*Num-leaves is now ([[:digit:]]+).*/\1/p" \
            $d/log/build_tree.log)

        tr_prob=0
        #tr_time=0
        tr_frames=0
        for j in `seq 1 4`; do
            fp=$(\
                sed -n -r \
                "s/.*Overall log-likelihood per frame is (-?[[:digit:]]+\.[[:digit:]]+) over ([[:digit:]]+) frames.*/\1,\2/p" \
                $tr_dir/align.30.$j.log\
            )
            f=$(echo $fp | cut -d , -f 2)
            p=$(echo $fp | cut -d , -f 1)
            tr_frames=$(echo "$tr_frames + $f" | bc -l)
            tr_prob=$(echo "$tr_prob + $p * $f" | bc -l)
        done

        ts_prob=0
        ts_time=0
        ts_frames=0
        for j in `seq 1 4`; do
            fp=$(\
                sed -n -r \
                "s/.*Overall log-likelihood per frame is (-?[[:digit:]]+\.[[:digit:]]+) over ([[:digit:]]+) frames.*/\1,\2/p" \
                $ts_dir/decode.$j.log\
            )
            f=$(echo $fp | cut -d , -f 2)
            p=$(echo $fp | cut -d , -f 1)
            ts_frames=$(echo "$ts_frames + $f" | bc -l)
            ts_prob=$(echo "$ts_prob + $p * $f" | bc -l)
            ts_time=$(echo "$ts_time + $(\
                sed -n -r \
                "s/.*real-time factor assuming 100 frames\/sec is ([[:digit:]]+\.[[:digit:]]+).*/\1/p" \
                $ts_dir/decode.$j.log\
            )" | bc -l)
        done

        echo "$n,$g,$l,$wer,$(echo "$tr_prob / $tr_frames" | bc -l),$(echo "$ts_prob / $ts_frames" | bc -l),$ts_time" >> $result
    fi
done

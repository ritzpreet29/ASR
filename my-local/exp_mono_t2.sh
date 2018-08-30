#!/usr/bin/env bash

ROOTDIR=~/asrwd
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
PRJDIR=$ROOTDIR/my-local
EXPDIR=$PRJDIR/exp
LOGFILE=$PRJDIR/t2_log.txt

totgauss=7793

echo -n "" > $LOGFILE

for f in mfcc fbank plp; do
    for d in $TRAINDIR $TESTDIR; do
        cp -f $d/feats/feats_$f.scp $d/feats.scp
        cp -f $d/cmvn/cmvn_$f.scp $d/cmvn.scp        
    done
    
    x=$EXPDIR/mono_t2_${f}_$totgauss
    $ROOTDIR/steps/train_mono.sh --nj 4 --totgauss $totgauss $TRAINDIR $LANGDIR $x
    $ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $x $x/graph
    $ROOTDIR/steps/decode.sh --nj 4 $x/graph $TESTDIR $x/decode_test
    $ROOTDIR/local/score_words.sh $TESTDIR $x/graph $x/decode_test
    echo "$f: " $(more $x/decode_test/scoring_kaldi/best_wer) >> $LOGFILE
done
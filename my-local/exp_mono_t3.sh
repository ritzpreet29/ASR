#!/usr/bin/env bash

ROOTDIR=~/asrwd
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
PRJDIR=$ROOTDIR/my-local
EXPDIR=$PRJDIR/exp
LOGFILE=$PRJDIR/t3_log.txt

totgauss=7785

echo -n "" > $LOGFILE

for d in $TRAINDIR $TESTDIR; do
	cp -f $d/feats/feats_mfcc.scp $d/feats.scp
	cp -f $d/cmvn/cmvn_mfcc.scp $d/cmvn.scp
done

#for order in `seq 0 1`; do
for order in `seq 0 6`; do
    x=$EXPDIR/mono_t3_${order}_$totgauss
    $PRJDIR/train_mono.sh --nj 4 --delta_opts "--delta-order=$order" --totgauss $totgauss $TRAINDIR $LANGDIR $x || exit 1
    $ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $x $x/graph || exit 1
    $PRJDIR/decode.sh --nj 4 $x/graph $TESTDIR $x/decode_test || exit 1
    $ROOTDIR/local/score_words.sh $TESTDIR $x/graph $x/decode_test || exit 1
done

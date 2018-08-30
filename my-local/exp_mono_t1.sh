#!/usr/bin/env bash

ROOTDIR=~/asrwd
PRJDIR=$ROOTDIR/my-local
EXPDIR=$PRJDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
LANGTESTDIR=$DATADIR/lang_wsj_test_bg

for d in $TRAINDIR $TESTDIR; do
	if [ -f  $d/feats.scp ]; then
		rm -f $d/feats.scp
	fi
	cp $d/feats/feats_mfcc.scp $d/feats.scp

	if [ -f $d/cmvn.scp ]; then
		rm -f $d/cmvn.scp
	fi
	cp $d/cmvn/cmvn_mfcc.scp $d/cmvn.scp
done

for n in `cat $PRJDIR/exp_mono_t1_params.txt`; do
	totgauss=$n
	EXP=$EXPDIR/mono_t1a_$totgauss
	if [ ! -f $EXP/decode_test/scoring_kaldi/best_wer ]; then
		$PRJDIR/train_mono.sh --nj 4 --totgauss $totgauss $TRAINDIR $LANGDIR $EXP
		$ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $EXP $EXP/graph
		$PRJDIR/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test
		$ROOTDIR/local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test
	 	more $EXP/decode_test/scoring_kaldi/best_wer
	fi
done

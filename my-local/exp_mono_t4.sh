#!/usr/bin/env bash

ROOTDIR=~/asrwd
PRJDIR=$ROOTDIR/my-local
EXPDIR=$PRJDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
LOGFILE=$PRJDIR/t4_log.txt

totgauss=7785

for d in $TRAINDIR $TESTDIR; do
	if [ -f $d/feats.scp ]; then
		rm -f $d/feats.scp
	fi
	cp $d/feats/feats_mfcc.scp $d/feats.scp

	if [ -f $d/cmvn.scp ]; then
		rm -f $d/cmvn.scp
	fi
	cp $d/cmvn/cmvn_mfcc.scp $d/cmvn.scp
done

echo -n "" > $LOGFILE

x=$EXPDIR/mono_t4_none_$totgauss
$ROOTDIR/steps/train_mono.sh --nj 4 --totgauss $totgauss\
	--cmvn-opts "--norm-vars=false --norm-means=false" $TRAINDIR $LANGDIR $x
$ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $x $x/graph
$ROOTDIR/steps/decode.sh --nj 4 $x/graph $TESTDIR $x/decode_test
$ROOTDIR/local/score_words.sh $TESTDIR $x/graph $x/decode_test
more $x/decode_test/scoring_kaldi/best_wer >> $LOGFILE

x=$EXPDIR/mono_t4_mean_$totgauss
$ROOTDIR/steps/train_mono.sh --nj 4 --totgauss $totgauss\
	--cmvn-opts "--norm-vars=false --norm-means=true" $TRAINDIR $LANGDIR $x
$ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $x $x/graph
$ROOTDIR/steps/decode.sh --nj 4 $x/graph $TESTDIR $x/decode_test
$ROOTDIR/local/score_words.sh $TESTDIR $x/graph $x/decode_test
more $x/decode_test/scoring_kaldi/best_wer >> $LOGFILE

# x=$EXPDIR/mono_t4_var
# $ROOTDIR/steps/train_mono.sh --nj 4 --totgauss $totgauss\
# 	--cmvn-opts "--norm-vars=true --norm-means=false" $TRAINDIR $LANGDIR $x
# $ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $x $x/graph
# $ROOTDIR/steps/decode.sh --nj 4 $x/graph $TESTDIR $x/decode_test
# $ROOTDIR/local/score_words.sh $TESTDIR $x/graph $x/decode_test
# more $x/decode_test/scoring_kaldi/best_wer >> $LOGFILE

x=$EXPDIR/mono_t4_both_$totgauss
$ROOTDIR/steps/train_mono.sh --nj 4 --totgauss $totgauss\
	--cmvn-opts "--norm-vars=true --norm-means=true" $TRAINDIR $LANGDIR $x
$ROOTDIR/utils/mkgraph.sh --mono $LANGTESTDIR $x $x/graph
$ROOTDIR/steps/decode.sh --nj 4 $x/graph $TESTDIR $x/decode_test
$ROOTDIR/local/score_words.sh $TESTDIR $x/graph $x/decode_test
more $x/decode_test/scoring_kaldi/best_wer >> $LOGFILE

#!/bin/bash

ROOTDIR=~/asrworkdir
EXPDIR=$ROOTDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
ALIGNDIR=$EXPDIR/word/mono_t1_ali
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
RESULTDIR=$ROOTDIR/result

# BEST

for numleaves in 9000; do
  for totgauss in 15848; do
    EXP=$EXPDIR/tri_t2_$numleaves\_$totgauss
    #$ROOTDIR/steps/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP
    $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $EXP $EXP/graph
    $ROOTDIR/steps/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test
    $ROOTDIR/local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test
    echo $numleaves $totgauss ::: >> $ROOTDIR/best_score_task2.log
    more $EXP/decode_test/scoring_kaldi/best_wer >> $ROOTDIR/best_score_task2.log
    cp $EXP/decode_test/scoring_kaldi/best_wer $RESULTDIR/best_wer_tri_t1_best_$numleaves\_$totgauss
    #cp $EXP/decode_test/scoring_kaldi/wer_details $RESULTDIR/wer_details_tri_t1_best_$numleaves\_$totgauss
    #rm -rf $EXP
  done
done

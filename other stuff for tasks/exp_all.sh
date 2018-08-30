#!/bin/bash

ROOTDIR=~/asrworkdir
EXPDIR=$ROOTDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
ALIGNDIR=$EXPDIR/word/mono_ali
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
RESULTDIR=$ROOTDIR/result

for ((numleaves=100;numleaves<=5001;numleaves+=100)); do
  for ((totgauss=1000;totgauss<=30001;totgauss+=1000)); do
    EXP=$EXPDIR/tri_t1_$numleaves\_$totgauss
    $ROOTDIR/steps/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP
    $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $EXP $EXP/graph
    $ROOTDIR/steps/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test
    $ROOTDIR/local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test
    echo $numleaves $totgauss ::: >> $ROOTDIR/remote.log
    more $EXP/decode_test/scoring_kaldi/best_wer >> $ROOTDIR/remote.log
    cp $EXP/decode_test/scoring_kaldi/best_wer $RESULTDIR/best_wer_tri_t1_$numleaves\_$totgauss
    #cp -r $EXP/decode_test/scoring_kaldi/wer_details $RESULTDIR/wer_details_tri_t1_$numleaves\_$totgauss
    rm -rf $EXP
  done
done

# steps/train_mono.sh data/train_words data/lang_wsj my-local/exp/word/mono
# utils/mkgraph.sh --mono data/lang_wsj_test_bg my-local/exp/word/mono my-local/exp/word/mono/graph
# steps/decode.sh --nj 4 exp/word/mono/graph data/test_words exp/word/mono/decode_test
# local/score_words.sh data/test_words exp/word/mono/graph exp/word/mono/decode_test

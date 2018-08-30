#!/usr/bin/env bash

ROOTDIR=my-local
EXPDIR=$ROOTDIR/exp
DATADIR=data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
ALIGNDIR=$EXPDIR/mono
LANGTESTDIR=$DATADIR/lang_wsj_test_bg

for numleaves in 500 1000 2000 2500 3500 4000 5000; do
  for totgauss in 500 5000 10000 15000 20000 25000 30000; do
    EXP=$EXPDIR/tri_t2_$numleaves_$totgauss
    my-local/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP
    utils/mkgraph.sh $LANGTESTDIR $EXP $EXP/graph
    steps/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test
    local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test
    more $EXP/decode_test/scoring_kaldi/best_wer
  done
done

# steps/train_mono.sh data/train_words data/lang_wsj my-local/exp/word/mono
# utils/mkgraph.sh --mono data/lang_wsj_test_bg my-local/exp/word/mono my-local/exp/word/mono/graph
# steps/decode.sh --nj 4 exp/word/mono/graph data/test_words exp/word/mono/decode_test
# local/score_words.sh data/test_words exp/word/mono/graph exp/word/mono/decode_test

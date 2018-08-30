#!/bin/bash

# FOR DIALECT
#subset_data_dir.sh --spk-list data/train_words/dr1_list_train data/train_words data/train_words/dr1_subdir_train
#subset_data_dir.sh --spk-list data/test_words/dr1_list_test data/train_words data/test_words/dr1_subdir_test
#subset_data_dir.sh --spk-list data/test_words/dr5_list_test data/train_words data/test_words/dr5_subdir_test

ROOTDIR=~/asrworkdir
EXPDIR=$ROOTDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words/dr1_subdir_train
#TESTDIR=$DATADIR/test_words/dr5_subdir_test
LANGDIR=$DATADIR/lang_wsj
ALIGNDIR=$EXPDIR/word/mono_t1_ali
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
RESULTDIR=$ROOTDIR/result

numleaves=2600
totgauss=17000

EXP=$EXPDIR/tri_t2_$numleaves\_$totgauss
$ROOTDIR/steps/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP

for dialect in 1 5; do
#for TESTDIR in $DATADIR/test_words/dr5_subdir_test $DATADIR/test_words/dr1_subdir_test; do
    TESTDIR=$DATADIR/test_words/dr${dialect}_subdir_test
    GRAPHDIR=$EXP/graph_$dialect
    DECODEDIR=$EXP/decode_test_$dialect
    $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $EXP $GRAPHDIR
    $ROOTDIR/steps/decode.sh --skip-scoring true --nj 4 $GRAPHDIR $TESTDIR $DECODEDIR|| exit 1
    $ROOTDIR/local/score_words.sh $TESTDIR $GRAPHDIR $DECODEDIR


    more $DECODEDIR/scoring_kaldi/best_wer >> $ROOTDIR/best_score_t3_dialect.log
    cp $DECODEDIR/scoring_kaldi/best_wer $RESULTDIR/t3_dialect_best_wer_$numleaves\_$totgauss
    #cp $EXP/decode_test/scoring_kaldi/wer_details $RESULTDIR/wer_details_tri_t2_$numleaves\_$totgauss
    #rm -rf $EXP
done

echo $DATADIR/test_words/dr5_subdir_test $DATADIR/test_words/dr1_subdir_test ::: >> $ROOTDIR/best_score_t3_dialect.log

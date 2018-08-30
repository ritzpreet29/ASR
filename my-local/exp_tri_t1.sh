#!/bin/bash

# ROOTDIR=~/asrworkdir
EXPDIR=$ROOTDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words
TESTDIR=$DATADIR/test_words
LANGDIR=$DATADIR/lang_wsj
ALIGNDIR=$EXPDIR/mono_t1_ali
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
RESULTDIR=$ROOTDIR/result

# COURSE RESOLUTION

# for numleaves in `cat t2_numleaves.txt`; do
#   for totgauss in `cat t2_totgauss.txt`; do
#     EXP=$EXPDIR/tri_t2_$numleaves\_$totgauss
#     if [ ! -f $EXP/decode_test/scoring_kaldi/best_wer ]; then
#       $ROOTDIR/steps/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP || exit 1
#       $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $EXP $EXP/graph || exit 1
#       $ROOTDIR/steps/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test || exit 1
#       $ROOTDIR/local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test || exit 1
#       echo $numleaves $totgauss ::: >> $ROOTDIR/t2_wer_scores.log || exit 1
#       more $EXP/decode_test/scoring_kaldi/best_wer >> $ROOTDIR/t2_wer_scores.log || exit 1
#       cp $EXP/decode_test/scoring_kaldi/best_wer $RESULTDIR/best_wer_tri_t2_$numleaves\_$totgauss
#       cp $EXP/decode_test/scoring_kaldi/wer_details $RESULTDIR/wer_details_tri_t2_$numleaves\_$totgauss
#       #rm -rf $EXP
#     fi
#   done
# done

# FINER RESOLUTION 1

for ((numleaves=2000;numleaves<=9000;numleaves+=500)); do
  for totgauss in 15848; do
    EXP=$EXPDIR/tri_t2_f0_$numleaves\_$totgauss
    if [ ! -f $EXP/decode_test/scoring_kaldi/best_wer ]; then
      $ROOTDIR/steps/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP || exit 1
      $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $EXP $EXP/graph || exit 1
      $ROOTDIR/steps/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test || exit 1
      $ROOTDIR/local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test || exit 1
      echo $numleaves $totgauss ::: >> $ROOTDIR/t2_wer_scores_finer1.log || exit 1
      more $EXP/decode_test/scoring_kaldi/best_wer >> $ROOTDIR/t2_wer_scores_finer1.log || exit 1
      cp $EXP/decode_test/scoring_kaldi/best_wer $RESULTDIR/best_wer_tri_t2_finer1_$numleaves\_$totgauss
      cp $EXP/decode_test/scoring_kaldi/wer_details $RESULTDIR/wer_details_tri_t2_finer_001_$numleaves\_$totgauss
      #rm -rf $EXP
    fi
  done
done

# FINER RESOLUTION 2

# for numleaves in 2000; do
#   for ((totgauss=15000;totgauss<=64000;totgauss+=1000)); do
#     EXP=$EXPDIR/tri_t2_f1_$numleaves\_$totgauss
#     $ROOTDIR/steps/train_deltas.sh $numleaves $totgauss $TRAINDIR $LANGDIR $ALIGNDIR $EXP
#     $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $EXP $EXP/graph
#     $ROOTDIR/steps/decode.sh --nj 4 $EXP/graph $TESTDIR $EXP/decode_test
#     $ROOTDIR/local/score_words.sh $TESTDIR $EXP/graph $EXP/decode_test
#     echo $numleaves $totgauss ::: >> $ROOTDIR/t2_wer_scores_finer2.log
#     more $EXP/decode_test/scoring_kaldi/best_wer >> $ROOTDIR/t2_wer_scores_finer2.log
#     cp $EXP/decode_test/scoring_kaldi/best_wer $RESULTDIR/best_wer_tri_t2_finer2_$numleaves\_$totgauss
#     #cp $EXP/decode_test/scoring_kaldi/wer_details $RESULTDIR/wer_details_tri_t2_$numleaves\_$totgauss
#     #rm -rf $EXP
#   done
# done

#Best scores from course sweep
# 9000_15848 - 43.07
#
# 2000_15848 - 43.71
#
# 2000_63095 - 43.96

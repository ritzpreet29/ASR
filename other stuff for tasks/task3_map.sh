#!/bin/bash

ROOTDIR=~/asrworkdir
EXPDIR=$ROOTDIR/exp
DATADIR=$ROOTDIR/data
TRAINDIR=$DATADIR/train_words/dr1_subdir_train
#TESTDIR=$DATADIR/test_words/dr5_subdir_test
LANGDIR=$DATADIR/lang_wsj
numleaves=3500
totgauss=25000
ALIGNDIR=$EXPDIR/mono_t1_ali
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
RESULTDIR=$ROOTDIR/result

EXP=${ALIGNDIR}_map

# TRAIN SET
subset_data_dir.sh --utt-list $DATADIR/train_words/dr5_si_list1 data/train_words data/train_words/train_dr5_si_l1
#subset_data_dir.sh --utt-list $DATADIR/train_words/dr5_si_list2 data/train_words data/train_words/train_dr5_si_l2
#subset_data_dir.sh --utt-list $DATADIR/train_words/dr5_si_list3 data/train_words data/train_words/train_dr5_si_l3

$ROOTDIR/steps/train_map.sh $DATADIR/train_words/train_dr5_si_l1 $LANGDIR $ALIGNDIR $EXP

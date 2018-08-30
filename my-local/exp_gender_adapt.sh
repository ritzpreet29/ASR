#!/usr/bin/env bash


ROOTDIR=~/asrwd
DATADIR=$ROOTDIR/data
LANGTRAINDIR=$DATADIR/lang_wsj
LANGTESTDIR=$DATADIR/lang_wsj_test_bg
PRJDIR=$ROOTDIR/my-local
EXPDIR=$PRJDIR/exp

# Use MFCC
for d in train test; do
    cp -f $DATADIR/${d}_words/feats/feats_mfcc.scp $DATADIR/feats.scp || exit 1
    cp -f $DATADIR/${d}_words/cmvn/cmvn_mfcc.scp $DATADIR/cmvn.scp || exit 1
done

# Create datasets
subset_data_dir.sh --spk-list $DATADIR/train_words_f.spk $DATADIR/train_words $DATADIR/train_words_f || exit 1
subset_data_dir.sh --spk-list $DATADIR/test_words_f.spk $DATADIR/test_words $DATADIR/test_words_f || exit 1
subset_data_dir.sh --spk-list $DATADIR/test_words_m.spk $DATADIR/test_words $DATADIR/test_words_m || exit 1

mono_totgauss=7785
tri_numleaves=9000
tri_totgauss=15848

# In domain
subset_data_dir.sh --spk-list $DATADIR/train_words_m.spk $DATADIR/train_words $DATADIR/train_words_m || exit 1

# Train monophone model
mono_exp=$EXPDIR/mono_adv_m
$ROOTDIR/steps/train_mono.sh --totgauss $mono_totgauss $DATADIR/train_words_m $LANGTRAINDIR $mono_exp || exit 1

# Train triphone model
tri_exp=$EXPDIR/tri_adv_m
$ROOTDIR/steps/train_deltas.sh $tri_numleaves $tri_totgauss $DATADIR/train_words_m $LANGTRAINDIR $mono_exp $tri_exp || exit 1

# Test on males
$ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $tri_exp $tri_exp/graph || exit 1
$PRJDIR/decode.sh --nj 1 $tri_exp/graph $DATADIR/test_words_m $tri_exp/decode_test || exit 1
$ROOTDIR/local/score_words.sh $DATADIR/test_words_m $tri_exp/graph $tri_exp/decode_test || exit 1

# SI
subset_data_dir.sh --spk-list $DATADIR/train_words_m.spk $DATADIR/train_words $DATADIR/train_words_m || exit 1

# Train monophone model
mono_exp=$EXPDIR/mono_adv_si
$ROOTDIR/steps/train_mono.sh --totgauss $mono_totgauss $DATADIR/train_words $LANGTRAINDIR $mono_exp || exit 1

# Train triphone model
tri_exp=$EXPDIR/tri_adv_si
$ROOTDIR/steps/train_deltas.sh $tri_numleaves $tri_totgauss $DATADIR/train_words $LANGTESTDIR $mono_exp $tri_exp || exit 1

# Test on males
$ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $tri_exp $tri_exp/graph || exit 1
$PRJDIR/decode.sh --nj 1 $tri_exp/graph $DATADIR/test_words_m $tri_exp/decode_test || exit 1
$ROOTDIR/local/score_words.sh $DATADIR/test_words_m $tri_exp/graph $tri_exp/decode_test || exit 1

# Adaptation
# Align model to male subset
#for size in 4 16 64 256 326; do
for size in 4 8 16 32 64; do
    size="$size"
    head -n $size $DATADIR/train_words_m.spk > $DATADIR/train_words_m_$size.spk
    subset_data_dir.sh --spk-list $DATADIR/train_words_m_$size.spk $DATADIR/train_words $DATADIR/train_words_m || exit 1
    
    ali_exp=$EXPDIR/ali_adv_si-m_$size
    $ROOTDIR/steps/align_si.sh $DATADIR/train_words_m $LANGTRAINDIR $tri_exp $ali_exp || exit 1
    
    # MAP adaptation (tau = 2 and 20)
    for tau in 2 20; do
        map_exp=$EXPDIR/map_adv_si-m_${tau}_$size
        $ROOTDIR/steps/train_map.sh --tau $tau $DATADIR/train_words_m $LANGTRAINDIR $ali_exp $map_exp || exit 1
        $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $map_exp $map_exp/graph || exit 1
        $PRJDIR/decode.sh --nj 1 $map_exp/graph $DATADIR/test_words_m $map_exp/decode_test || exit 1
        $ROOTDIR/local/score_words.sh $DATADIR/test_words_m $map_exp/graph $map_exp/decode_test || exit 1
    done
   
    # SAT
    sat_exp=$EXPDIR/sat_adv_si-m_$size
    $ROOTDIR/steps/train_sat.sh $tri_numleaves $tri_totgauss $DATADIR/train_words_m $LANGTRAINDIR $ali_exp $sat_exp || exit 1
    $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $sat_exp $sat_exp/graph || exit 1
    $ROOTDIR/steps/decode_fmllr.sh --nj 1 $sat_exp/graph $DATADIR/test_words_m $sat_exp/decode_test || exit 1
    $ROOTDIR/local/score_words.sh $DATADIR/test_words_m $sat_exp/graph $sat_exp/decode_test || exit 1
done

# Out of domain
# Train monophone model
mono_exp=$EXPDIR/mono_adv_f
$ROOTDIR/steps/train_mono.sh --totgauss $mono_totgauss $DATADIR/train_words_f $LANGTRAINDIR $mono_exp || exit 1

# Train triphone model
tri_exp=$EXPDIR/tri_adv_f

#$ROOTDIR/steps/train_deltas.sh $tri_numleaves $tri_totgauss $DATADIR/train_words_f $LANGTRAINDIR $mono_exp $tri_exp || exit 1
#$ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $tri_exp $tri_exp/graph || exit 1
#for gender in m f; do
#    $PRJDIR/decode.sh --nj 1 $tri_exp/graph $DATADIR/test_words_$gender $tri_exp/decode_test_$gender || exit 1
#    $ROOTDIR/local/score_words.sh $DATADIR/test_words_$gender $tri_exp/graph $tri_exp/decode_test_$gender || exit 1
#done

# Align model to male subset
#for size in 4 16 64 256 326; do
for size in 4 8 16 32 64; do
    head -n $size $DATADIR/train_words_m.spk > $DATADIR/train_words_m_$size.spk
    subset_data_dir.sh --spk-list $DATADIR/train_words_m_$size.spk $DATADIR/train_words $DATADIR/train_words_m || exit 1
    
    ali_exp=$EXPDIR/ali_adv_f-m_$size
    $ROOTDIR/steps/align_si.sh $DATADIR/train_words_m $LANGTRAINDIR $tri_exp $ali_exp || exit 1
    
    # MAP adaptation (tau = 2 and 20)
    for tau in 2 20; do
        map_exp=$EXPDIR/map_adv_f-m_${tau}_$size
        $ROOTDIR/steps/train_map.sh --tau $tau $DATADIR/train_words_m $LANGTRAINDIR $ali_exp $map_exp || exit 1
        $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $map_exp $map_exp/graph || exit 1
        $PRJDIR/decode.sh --nj 1 $map_exp/graph $DATADIR/test_words_m $map_exp/decode_test || exit 1
        $ROOTDIR/local/score_words.sh $DATADIR/test_words_m $map_exp/graph $map_exp/decode_test || exit 1
    done
    
    # SAT
    sat_exp=$EXPDIR/sat_adv_f-m_$size
    $ROOTDIR/steps/train_sat.sh $tri_numleaves $tri_totgauss $DATADIR/train_words_m $LANGTRAINDIR $ali_exp $sat_exp || exit 1
    $ROOTDIR/utils/mkgraph.sh $LANGTESTDIR $sat_exp $sat_exp/graph || exit 1
    $ROOTDIR/steps/decode_fmllr.sh --nj 1 $sat_exp/graph $DATADIR/test_words_m $sat_exp/decode_test || exit 1
    $ROOTDIR/local/score_words.sh $DATADIR/test_words_m $sat_exp/graph $sat_exp/decode_test || exit 1
done


# SGMMs starting from non-SAT triphone system, both with and without 
# speaker vectors.
for L in $GP_LANGUAGES; do
  (
    mkdir -p exp/$L/tri1_ali
    steps/align_si.sh --nj 10 --cmd "$train_cmd" \
      data/$L/train data/$L/lang exp/$L/tri1 exp/$L/tri1_ali \
      >& exp/$L/tri1_ali/align.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/tri1_ali >& exp/$L/tri1_ali/get_pron.log 

    mkdir -p exp/$L/ubm2a
    steps/train_ubm.sh --cmd "$train_cmd" \
      400 data/$L/train data/$L/lang exp/$L/tri1_ali exp/$L/ubm2a \
      >& exp/$L/ubm2a/train.log || exit 1;

    num_states=$(grep "^$L" conf/sgmm.conf | cut -f2)
    num_substates=$(grep "^$L" conf/sgmm.conf | cut -f3)
    mkdir -p exp/$L/sgmm2a
    steps/train_sgmm.sh --cmd "$train_cmd" --cluster-thresh 100 --spk-dim 0 \
      $num_states $num_substates data/$L/train data/$L/lang exp/$L/tri1_ali \
      exp/$L/ubm2a/final.ubm exp/$L/sgmm2a >& exp/$L/sgmm2a/train.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/sgmm2a >& exp/$L/sgmm2a/get_pron.log 

    mkdir -p exp/$L/sgmm2b
    steps/train_sgmm.sh --cmd "$train_cmd" --cluster-thresh 100 \
      $num_states $num_substates data/$L/train data/$L/lang exp/$L/tri1_ali \
      exp/$L/ubm2a/final.ubm exp/$L/sgmm2b >& exp/$L/sgmm2b/train.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/sgmm2b >& exp/$L/sgmm2b/get_pron.log 
  ) &
done
wait


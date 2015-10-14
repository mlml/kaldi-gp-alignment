


# Train SGMMs using SAT features
for L in $GP_LANGUAGES; do
  (
    mkdir -p exp/$L/ubm2c
    steps/train_ubm.sh --cmd "$train_cmd" \
      400 data/$L/train data/$L/lang exp/$L/tri1_ali_fmllr exp/$L/ubm2c \
      >& exp/$L/ubm2c/train.log || exit 1;

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/ubm2c >& exp/$L/ubm2c/get_pron.log 

    num_states=$(grep "^$L" conf/tri.conf | cut -f2)
    num_gauss=$(grep "^$L" conf/tri.conf | cut -f3)
    mkdir -p exp/$L/sgmm2c
    steps/train_sgmm.sh --cmd "$train_cmd" --cluster-thresh 100 \
      $num_states $num_gauss data/$L/train data/$L/lang exp/$L/tri1_ali_fmllr \
      exp/$L/ubm2c/final.ubm exp/$L/sgmm2c >& exp/$L/sgmm2c/train.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/sgmm2c >& exp/$L/sgmm2c/get_pron.log 
  ) &
done
wait;


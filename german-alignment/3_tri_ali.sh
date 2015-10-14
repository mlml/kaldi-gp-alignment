

# SAT-trained triphone systems: MFCC feats
for L in $GP_LANGUAGES; do
  (
    mkdir -p exp/$L/tri1_ali_fmllr
    steps/align_fmllr.sh --nj 10 --cmd "$train_cmd" \
      data/$L/train data/$L/lang exp/$L/tri1 exp/$L/tri1_ali_fmllr \
      >& exp/$L/tri1_ali_fmllr/align.log  || exit 1;

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/tri1_ali_fmllr >& exp/$L/tri1_ali_fmllr/get_pron.log 

    num_states=$(grep "^$L" conf/tri.conf | cut -f2)
    num_gauss=$(grep "^$L" conf/tri.conf | cut -f3)
    mkdir -p exp/$L/tri2a
    steps/train_sat.sh --cmd "$train_cmd" --cluster-thresh 100 \
      $num_states $num_gauss data/$L/train data/$L/lang exp/$L/tri1_ali_fmllr \
      exp/$L/tri2a >& exp/$L/tri2a/train.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/tri2a >& exp/$L/tri2a/get_pron.log 
  ) &
done
wait;

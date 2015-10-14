

for L in $GP_LANGUAGES; do
  (
    mkdir -p exp/$L/mono_ali
    steps/align_si.sh --nj 10 --cmd "$train_cmd" \
      data/$L/train data/$L/lang exp/$L/mono exp/$L/mono_ali \
      >& exp/$L/mono_ali/align.log 

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/mono_ali >& exp/$L/mono_ali/get_pron.log 

    num_states=$(grep "^$L" conf/tri.conf | cut -f2)
    num_gauss=$(grep "^$L" conf/tri.conf | cut -f3)
    mkdir -p exp/$L/tri1
    steps/train_deltas.sh --cmd "$train_cmd" --cluster-thresh 100 \
      $num_states $num_gauss data/$L/train data/$L/lang exp/$L/mono_ali \
      exp/$L/tri1 >& exp/$L/tri1/train.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/tri1 >& exp/$L/tri1/get_pron.log 
    ) &
done
wait;

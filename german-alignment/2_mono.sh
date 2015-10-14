for L in $GP_LANGUAGES; do
  mkdir -p exp/$L/mono;
  steps/train_mono.sh --nj 10 --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/mono >& exp/$L/mono/train.log

  steps/get_train_ctm.sh --cmd "$train_cmd" \
    data/$L/train data/$L/lang exp/$L/mono >& exp/$L/mono/get_pron.log &
done
wait;


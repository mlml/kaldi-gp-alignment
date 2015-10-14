

for L in $GP_LANGUAGES; do
  for lm_suffix in tgpr; do
    (
      graph_dir=exp/$L/tri2a/graph_${lm_suffix}
      mkdir -p $graph_dir
      $highmem_cmd $graph_dir/mkgraph.log \
	utils/mkgraph.sh data/$L/lang_test_${lm_suffix} exp/$L/tri2a $graph_dir

      steps/decode_fmllr.sh --nj 5 --cmd "$decode_cmd" $graph_dir data/$L/dev \
	exp/$L/tri2a/decode_dev_${lm_suffix} 
    ) &
  done
done
wait;

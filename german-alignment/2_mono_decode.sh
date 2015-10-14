
for L in $GP_LANGUAGES; do
  for lm_suffix in tgpr; do
    (
      graph_dir=exp/$L/mono/graph_${lm_suffix}
      mkdir -p $graph_dir
      $highmem_cmd $graph_dir/mkgraph.log \
	utils/mkgraph.sh --mono data/$L/lang_test_${lm_suffix} exp/$L/mono \
	$graph_dir

      steps/decode.sh --nj 5 --cmd "$decode_cmd" $graph_dir data/$L/dev \
	exp/$L/mono/decode_dev_${lm_suffix} 
    ) &
  done
done
wait;


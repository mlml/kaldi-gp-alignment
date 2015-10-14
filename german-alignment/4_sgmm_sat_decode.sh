

for L in $GP_LANGUAGES; do
  for lm_suffix in tgpr; do
    (
      graph_dir=exp/$L/sgmm2c/graph_${lm_suffix}
      mkdir -p $graph_dir
      $highmem_cmd $graph_dir/mkgraph.log \
	utils/mkgraph.sh data/$L/lang_test_${lm_suffix} exp/$L/sgmm2c $graph_dir

      steps/decode_sgmm.sh --nj 5 --cmd "$decode_cmd" \
	--transform-dir exp/$L/tri2a/decode_dev_${lm_suffix} \
	$graph_dir data/$L/dev exp/$L/sgmm2c/decode_dev_${lm_suffix} 
    ) &
  done
done
wait;





for L in $GP_LANGUAGES; do
  # Need separate decoding graphs for models with and without speaker vectors,
  # since the trees may be different.
  for sgmm in sgmm2a sgmm2b; do
    for lm_suffix in tgpr; do
      (
	graph_dir=exp/$L/$sgmm/graph_${lm_suffix}
	mkdir -p $graph_dir
	$highmem_cmd $graph_dir/mkgraph.log \
	  utils/mkgraph.sh data/$L/lang_test_${lm_suffix} exp/$L/$sgmm $graph_dir

	steps/decode_sgmm.sh --nj 5 --cmd "$decode_cmd" $graph_dir data/$L/dev \
	  exp/$L/$sgmm/decode_dev_${lm_suffix} 
      ) &
    done  # loop over LMs
  done    # loop over model with and without speaker vecs
done      # loop over languages
wait;


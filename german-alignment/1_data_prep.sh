
[ -f cmd.sh ] && source ./cmd.sh \
  || echo "cmd.sh not found. Jobs may not execute properly."

#local/gp_check_tools.sh $PWD path.sh

. path.sh || { echo "Cannot source path.sh"; exit 1; }

GP_CORPUS=/home/michael/Documents/Data/GlobalPhone
GP_LM=$PWD/language_models
export GP_LANGUAGES="GE"

local/gp_data_prep.sh --config-dir=$PWD/conf --corpus-dir=$GP_CORPUS \
  --languages="$GP_LANGUAGES"
local/gp_dict_prep.sh --config-dir $PWD/conf $GP_CORPUS $GP_LANGUAGES

for L in $GP_LANGUAGES; do
  utils/prepare_lang.sh --position-dependent-phones true \
    data/$L/local/dict "<unk>" data/$L/local/lang_tmp data/$L/lang \
    >& data/$L/prepare_lang.log;
done

for L in $GP_LANGUAGES; do
   $highmem_cmd data/$L/format_lm.log \
     local/gp_format_lm.sh --filter-vocab-sri false $GP_LM $L & 
  #$highmem_cmd data/$L/format_lm.log \
  #  local/gp_format_lm.sh --filter-vocab-sri true $GP_LM $L & 
done
wait

for L in $GP_LANGUAGES; do
  mfccdir=mfcc/$L
  for x in train dev eval; do
    ( 
      steps/make_mfcc.sh --nj 6 --cmd "$train_cmd" data/$L/$x \
	exp/$L/make_mfcc/$x $mfccdir;
      steps/compute_cmvn_stats.sh data/$L/$x exp/$L/make_mfcc/$x $mfccdir; 
    ) &
  done
done
wait;



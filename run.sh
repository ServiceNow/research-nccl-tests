source .env

BASE_JOB_NAME="all_reduce_perf_2n" \
NUM_NODES=2 \
CONFIG=./jobspec.yaml \
COMMAND="\
/app/build/all_reduce_perf -b8 -e8G -f2 -b8 -e16G -f2 -g1 | tee ~/LOG_ALLREDUCE_N4n32.$(date +%Y%m%d-%H%M).txt \
" make -f Makefile.toolkit launch

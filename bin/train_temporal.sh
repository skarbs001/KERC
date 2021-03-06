#!/usr/bin/env bash

set -e

PYTHONPATH=$(pwd):$PYTHONPATH
export PYTHONPATH

echo "Training..."

# densenet121 fishnet99 inceptionresnetv2 inception_v3 inception_v4 resnet18 resnet34 resnet50 se_resnet50 se_resnext50_32x4d vggresnet
for model in inceptionresnetv2 ; do

    if [ $model == 'densenet121' ]
    then
        n_features=1024
    elif [ $model == 'se_resnet50' ] || [ $model == 'se_resnext50_32x4d' ] || [ $model == 'inception_v3' ] || [ $model == 'vggresnet' ] || [ $model == 'resnet50' ]
    then
        n_features=2048
    elif [ $model == 'fishnet99' ]
    then
        n_features=1056
    elif [ $model == 'resnet18' ] || [ $model == 'resnet34' ]
    then
        n_features=512
    elif [ $model == 'inception_v4' ] || [ $model == 'inceptionresnetv2' ]
    then
        n_features=1536
    fi

    POOL_FEATURE_DIR=/media/ngxbac/DATA/logs_kerc/features/

    for hidden_size in $(seq 32 32 512); do
        LOGDIR=/media/ngxbac/DATA/logs_kerc/lstm/${model}_${hidden_size}
        catalyst-dl run --config=./configs/config_lstm.yml \
                        --logdir=$LOGDIR \
                        --model_params/n_features=$n_features:int \
                        --model_params/hidden_size=$hidden_size:int \
                        --stages/data_params/train_pool=$POOL_FEATURE_DIR/$model/train/pooled_features.pkl:str \
                        --stages/data_params/valid_pool=$POOL_FEATURE_DIR/$model/valid/pooled_features.pkl:str \
                        --out_dir=$LOGDIR:str \
                        --verbose
    done
done
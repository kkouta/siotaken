#!/bin/bash

# 対象の親ディレクトリ（このスクリプトを実行する際に引数として指定可能）
parent_dir="/home/kkouta/so-vits-svc/dataset_raw"

# 合計ファイル数を初期化
total_files=0

# findコマンドを使って、すべてのディレクトリを取得し、ループ処理
while IFS= read -r dir; do
    # ASV-DB-voxcelebとtts-vc-attackを除外
    if [[ "$dir" =~ "ASV-DB-voxceleb" || "$dir" =~ "tts-vc-attack" ]]; then
        continue
    fi
    
    # 合計時間を秒で初期化
    total_duration=0

    # 指定ディレクトリ内のすべてのwavファイルに対してループ処理
    while IFS= read -r -d '' file; do
        # ファイル名に "in-sil" が含まれている場合にのみ処理を行う
        if [[ "$file" =~ "in-air" ]]; then
            # soxを使ってファイルの長さを秒単位で取得
            duration=$(sox --i -D "$file")
            # 合計時間に加算
            total_duration=$(echo "$total_duration + $duration" | bc)
            # ファイル数をカウントアップ
            ((total_files++))
        fi
    done < <(find "$dir" -maxdepth 1 -type f -name "*.wav" -print0)

    # 各ディレクトリの合計時間を表示
    echo "Total duration of files containing 'in-sil' in $dir: $total_duration seconds"
done < <(find "$parent_dir" -type d -not -path "*ASV-DB-voxceleb*" -not -path "*tts-vc-attack*")

# 合計ファイル数を表示
echo "Total number of files processed: $total_files"

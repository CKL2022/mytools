#!/bin/bash

source_dir="./ubt18"
target_dir="./ubt20"

# 比较源目录和目标目录的差异
diff_output=$(diff -qr "$source_dir" "$target_dir")

if [ -z "$diff_output" ]; then
  echo "目录已经是一致的，无需修改。"
else
  echo "以下是不同的文件列表："
  echo "$diff_output"

  # 删除目标目录中多余的文件
  delete_output=$(comm -23 <(ls -A "$target_dir") <(ls -A "$source_dir"))
  if [ -n "$delete_output" ]; then
    echo "以下文件将被删除："
    echo "$delete_output"
    rm -rf "$target_dir/$delete_output"
  fi

  # 将源目录的文件替换为目标目录的文件
  cp -rf "$source_dir"/* "$target_dir"

  echo "文件已更新为和ubt18目录一致。"
fi


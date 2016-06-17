#!/usr/bin/env bash

assert_equal() {
  if [ "$1" != "$2" ]; then
    echo "expected: $1"
    echo "actual:   $2"
    return 1
  fi
}

assert_output() {
  assert_equal "$1" "$output"
}

assert_fail() {
  if [ "$status" -eq 0 ]; then
    echo "command successful, but should fail"
    return 1
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

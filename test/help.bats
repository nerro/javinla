#!/usr/bin/env bats

@test "no arguments prints usage instructions" {
  run ./javinla.sh
  [ "$status" -eq 1 ]
}

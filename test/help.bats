#!/usr/bin/env bats

@test "no arguments prints usage instructions" {
  run javinla
  [ "$status" -eq 1 ]
}

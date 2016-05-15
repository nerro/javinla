#!/usr/bin/env bats

@test "without args shows summary of common commands" {
  result=$(run javinla.sh)
  [ "$result" -eq 1 ]
}

#!/usr/bin/env bats

load test_helper

@test "no arguments prints usage instructions" {
  run javinla
  assert_fail
}

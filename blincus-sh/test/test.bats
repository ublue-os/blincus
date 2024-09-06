bats_load_library 'bats-support'
bats_load_library 'bats-assert'

@test "incus starts with one profile" {
	run bash -c "incus profile ls --format json | jq '. | length'"
	assert_output "1"
}

@test "can run blincus" {
	./blincus help
}

@test "blincus is installed in PATH" {
	blincus help
}

@test "blincus installs profiles" {
	run bash -c "incus profile ls --format json | jq '. | length'"
	clouds=$(ls -1 cloud-init | wc -l)
	profiles=$(ls -1 profiles | wc -l)
	# cloud-init plus profiles plus the default profile
	total=$((clouds + profiles + 1))
	assert_output $total
}

@test "blincus personalizes profiles" {
	run bash -c "incus profile show debian"
	refute_output --partial 'BLINCUS'
	refute_output --partial 'SSHKEY'
}

@test "blincus launches instances" {
	blincus launch -t debian mydeb
}

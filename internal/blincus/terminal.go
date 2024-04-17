package blincus

import (
	"os/exec"
)

// LaunchRootTerminal launches a terminal on the host that is connected
// to 'instance' for instance user 'root'
func LaunchRootTerminal(termCommand string, instance string) error {

	args := []string{}

	args = append(args, "--")
	// subcommand
	args = append(args, "incus")
	// image
	args = append(args, "shell")
	args = append(args, instance)

	return exec.Command(termCommand, args...).Run()

}

// LaunchUserTerminal launches a terminal on the host that is connected
// to 'instance' for the specified instance user
func LaunchUserTerminal(termCommand string, instance string, user string) error {

	args := []string{}

	args = append(args, "--")
	// subcommand
	args = append(args, "incus")
	// image
	args = append(args, "exec")
	args = append(args, instance)
	args = append(args, "--")
	args = append(args, "su")
	args = append(args, "-l")
	args = append(args, user)

	return exec.Command(termCommand, args...).Run()

}

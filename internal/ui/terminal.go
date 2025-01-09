package ui

import (
	"os"
	"os/exec"
)

func LaunchRootTerminal(term TerminalOption, instance string) error {

	var termCommand string
	args := []string{}
	if IsFlatpak() {
		termCommand = "flatpak-spawn"
		args = append(args, "--host")
		args = append(args, term.Executable)
	} else {
		termCommand = term.Executable
	}

	args = append(args, term.SeparatorArg)

	// subcommand
	args = append(args, "incus")
	// image
	args = append(args, "shell")
	args = append(args, instance)

	return exec.Command(termCommand, args...).Run()

}
func LaunchUserTerminal(term TerminalOption, instance string, user string) error {

	var termCommand string
	args := []string{}
	if IsFlatpak() {
		termCommand = "flatpak-spawn"
		args = append(args, "--host")
		args = append(args, term.Executable)
	} else {
		termCommand = term.Executable
	}

	args = append(args, term.SeparatorArg)
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

func IsFlatpak() bool {
	fpEnv := os.Getenv("FLATPAK_ID")
	if fpEnv != "" {
		return true
	}
	_, err := os.Stat("/.flatpak-info")
	return err == nil

}

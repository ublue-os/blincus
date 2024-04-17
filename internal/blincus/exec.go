package blincus

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"os/signal"
	"strconv"
	"strings"

	"github.com/gorilla/websocket"
	incus "github.com/lxc/incus/client"
	"github.com/lxc/incus/shared/api"
	"github.com/lxc/incus/shared/logger"
	"github.com/lxc/incus/shared/termios"
	"golang.org/x/sys/unix"
)

func (c *Client) sendTermSize(control *websocket.Conn) error {
	width, height, err := termios.GetSize(getStdoutFd())
	if err != nil {
		return err
	}

	logger.Debugf("Window size is now: %dx%d", width, height)

	msg := api.InstanceExecControl{}
	msg.Command = "window-resize"
	msg.Args = make(map[string]string)
	msg.Args["width"] = strconv.Itoa(width)
	msg.Args["height"] = strconv.Itoa(height)

	return control.WriteJSON(msg)
}

func (c *Client) ExecBlind(
	args []string,
	environment []string,
	flagUser uint32,
	flagGroup uint32,
	flagCwd string,
	flagForceInteractive bool,
	flagForceNonInteractive bool,
	flagDisableStdin bool,
	flagMode string,
	stdout *bytes.Buffer) (int, error) {
	conf := c.conf

	if flagForceInteractive && flagForceNonInteractive {
		return -1, fmt.Errorf("you can't pass -t and -T at the same time")
	}

	if flagMode != "auto" && (flagForceInteractive || flagForceNonInteractive) {
		return -1, fmt.Errorf("you can't pass -t or -T at the same time as --mode")
	}

	// Connect to the daemon
	remote, name, err := conf.ParseRemote(args[0])
	if err != nil {
		return -1, err
	}

	d, err := conf.GetInstanceServer(remote)
	if err != nil {
		return -1, err
	}

	// Set the environment
	env := map[string]string{}
	myTerm, ok := c.getTERM()
	if ok {
		env["TERM"] = myTerm
	}

	for _, arg := range environment {
		pieces := strings.SplitN(arg, "=", 2)
		value := ""
		if len(pieces) > 1 {
			value = pieces[1]
		}

		env[pieces[0]] = value
	}

	// Configure the terminal
	stdinFd := getStdinFd()
	stdoutFd := getStdoutFd()

	stdinTerminal := termios.IsTerminal(stdinFd)
	stdoutTerminal := termios.IsTerminal(stdoutFd)

	// Determine interaction mode
	if flagDisableStdin {
		c.interactive = false
	} else if flagMode == "interactive" || flagForceInteractive {
		c.interactive = true
	} else if flagMode == "non-interactive" || flagForceNonInteractive {
		c.interactive = false
	} else {
		c.interactive = stdinTerminal && stdoutTerminal
	}

	// Record terminal state
	var oldttystate *termios.State
	if c.interactive && stdinTerminal {
		oldttystate, err = termios.MakeRaw(stdinFd)
		if err != nil {
			return -1, err
		}

		defer func() { _ = termios.Restore(stdinFd, oldttystate) }()
	}

	// Setup interactive console handler
	handler := c.controlSocketHandler

	// Grab current terminal dimensions
	var width, height int
	if stdoutTerminal {
		width, height, err = termios.GetSize(getStdoutFd())
		if err != nil {
			return -1, err
		}
	}

	var stdin io.Reader
	stdin = os.Stdin
	if flagDisableStdin {
		stdin = bytes.NewReader(nil)
	}

	// Prepare the command
	req := api.InstanceExecPost{
		Command:     args[1:],
		WaitForWS:   true,
		Interactive: c.interactive,
		Environment: env,
		Width:       width,
		Height:      height,
		User:        flagUser,
		Group:       flagGroup,
		Cwd:         flagCwd,
	}

	execArgs := incus.InstanceExecArgs{
		Stdin:    stdin,
		Stdout:   stdout,
		Stderr:   os.Stderr,
		Control:  handler,
		DataDone: make(chan bool),
	}

	// Run the command in the instance
	op, err := d.ExecInstance(name, req, &execArgs)
	if err != nil {
		return -1, err
	}

	// Wait for the operation to complete
	err = op.Wait()
	//	opAPI := op.Get()
	// if opAPI.Metadata != nil {
	// 	exitStatusRaw, ok := opAPI.Metadata["return"].(float64)
	// 	if ok {
	// 		c.global.ret = int(exitStatusRaw)
	// 	}
	// }

	if err != nil {
		return -1, err
	}

	// Wait for any remaining I/O to be flushed
	<-execArgs.DataDone

	return 0, nil
}
func (c *Client) ExecInteractive(
	args []string,
	environment []string,
	flagUser uint32,
	flagGroup uint32,
	flagCwd string,
	stdIn io.Reader,
	stdOut, stdErr io.Writer,
) error {
	conf := c.conf

	// Connect to the daemon
	remote, name, err := conf.ParseRemote(args[0])
	if err != nil {
		return err
	}

	d, err := conf.GetInstanceServer(remote)
	if err != nil {
		return err
	}

	// Set the environment
	env := map[string]string{}
	myTerm, ok := c.getTERM()
	if ok {
		env["TERM"] = myTerm
	}

	for _, arg := range environment {
		pieces := strings.SplitN(arg, "=", 2)
		value := ""
		if len(pieces) > 1 {
			value = pieces[1]
		}

		env[pieces[0]] = value
	}

	// Setup interactive console handler
	handler := c.controlSocketHandler

	// Prepare the command
	req := api.InstanceExecPost{
		Command:     args[1:],
		WaitForWS:   true,
		Interactive: true,
		Environment: env,
		Width:       80,
		Height:      40,
		User:        flagUser,
		Group:       flagGroup,
		Cwd:         flagCwd,
	}

	execArgs := incus.InstanceExecArgs{
		Stdin:    stdIn,
		Stdout:   stdOut,
		Stderr:   stdErr,
		Control:  handler,
		DataDone: make(chan bool),
	}

	// Run the command in the instance
	op, err := d.ExecInstance(name, req, &execArgs)
	if err != nil {
		return err
	}

	// Wait for the operation to complete
	err = op.Wait()
	//	opAPI := op.Get()
	// if opAPI.Metadata != nil {
	// 	exitStatusRaw, ok := opAPI.Metadata["return"].(float64)
	// 	if ok {
	// 		c.global.ret = int(exitStatusRaw)
	// 	}
	// }

	if err != nil {
		return err
	}

	// Wait for any remaining I/O to be flushed
	<-execArgs.DataDone

	return nil
}
func (c *Client) getTERM() (string, bool) {
	return os.LookupEnv("TERM")
}
func (c *Client) controlSocketHandler(control *websocket.Conn) {
	ch := make(chan os.Signal, 10)
	signal.Notify(ch,
		unix.SIGWINCH,
		unix.SIGTERM,
		unix.SIGHUP,
		unix.SIGINT,
		unix.SIGQUIT,
		unix.SIGABRT,
		unix.SIGTSTP,
		unix.SIGTTIN,
		unix.SIGTTOU,
		unix.SIGUSR1,
		unix.SIGUSR2,
		unix.SIGSEGV,
		unix.SIGCONT)

	closeMsg := websocket.FormatCloseMessage(websocket.CloseNormalClosure, "")
	defer func() { _ = control.WriteMessage(websocket.CloseMessage, closeMsg) }()

	for {
		sig := <-ch

		switch sig {
		case unix.SIGWINCH:
			if !c.interactive {
				// Don't send SIGWINCH to non-interactive, this can lead to console corruption/crashes.
				continue
			}

			logger.Debugf("Received '%s signal', updating window geometry.", sig)
			err := c.sendTermSize(control)
			if err != nil {
				logger.Debugf("error setting term size %s", err)
				return
			}

		case unix.SIGTERM:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGTERM)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGTERM)
				return
			}

		case unix.SIGHUP:
			file, err := os.OpenFile("/dev/tty", os.O_RDONLY|unix.O_NOCTTY|unix.O_NOFOLLOW|unix.O_CLOEXEC, 0666)
			if err == nil {
				_ = file.Close()
				err = c.forwardSignal(control, unix.SIGHUP)
			} else {
				err = c.forwardSignal(control, unix.SIGTERM)
				sig = unix.SIGTERM
			}

			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", sig)
				return
			}

		case unix.SIGINT:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGINT)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGINT)
				return
			}

		case unix.SIGQUIT:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGQUIT)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGQUIT)
				return
			}

		case unix.SIGABRT:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGABRT)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGABRT)
				return
			}

		case unix.SIGTSTP:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGTSTP)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGTSTP)
				return
			}

		case unix.SIGTTIN:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGTTIN)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGTTIN)
				return
			}

		case unix.SIGTTOU:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGTTOU)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGTTOU)
				return
			}

		case unix.SIGUSR1:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGUSR1)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGUSR1)
				return
			}

		case unix.SIGUSR2:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGUSR2)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGUSR2)
				return
			}

		case unix.SIGSEGV:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGSEGV)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGSEGV)
				return
			}

		case unix.SIGCONT:
			logger.Debugf("Received '%s signal', forwarding to executing program.", sig)
			err := c.forwardSignal(control, unix.SIGCONT)
			if err != nil {
				logger.Debugf("Failed to forward signal '%s'.", unix.SIGCONT)
				return
			}
		}
	}
}

func (c *Client) forwardSignal(control *websocket.Conn, sig unix.Signal) error {
	logger.Debugf("Forwarding signal: %s", sig)

	msg := api.InstanceExecControl{}
	msg.Command = "signal"
	msg.Signal = int(sig)

	return control.WriteJSON(msg)
}

package ui

import (
	"os"
	"strings"
)

type Display struct {
	Wayland       bool
	WaylandSocket string
	X11           bool
	X11Socket     string
}

func DisplayEnvironment() (Display, error) {

	wsock, exists := os.LookupEnv("WAYLAND_DISPLAY")
	xsock, xexists := os.LookupEnv("DISPLAY")
	d := Display{
		Wayland:       exists,
		WaylandSocket: wsock,
		X11:           xexists,
		X11Socket:     xsock,
	}
	return d, nil
}

func (d Display) Profile(image string) string {
	prefix := ""
	if strings.Contains(image, "alpine") {
		prefix = "alpine"
	}
	if d.Wayland {
		if strings.Contains(d.WaylandSocket, "0") {
			return prefix + "shiftingwayland0"
		} else {
			return prefix + "shiftingwayland0"
		}
	}
	if strings.Contains(d.X11Socket, "0") {
		return prefix + "shiftingx0"
	}
	return prefix + "shiftingx1"
}

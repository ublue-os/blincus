package ui

import (
	"github.com/diamondburned/gotkit/app/prefs"
	"golang.org/x/exp/maps"
)

var terminal = prefs.NewEnumList("ptyxis", prefs.EnumListMeta{
	PropMeta: prefs.PropMeta{
		Name:        "Preferred Terminal",
		Section:     "Terminal",
		Description: "Preferred terminal for launching sessions in Instances.",
	},
	Options: maps.Keys(terminalMap),
	Validate: func(s string) error {
		return nil
	},
})

var terminalMap = map[string]TerminalOption{
	"ptyxis": TerminalOption{
		Name:         "Ptyxis",
		Executable:   "/usr/bin/ptyxis",
		SeparatorArg: "--",
	},
	"GNOME Terminal": TerminalOption{
		Name:         "GNOME Terminal",
		Executable:   "kgx",
		SeparatorArg: "--",
	},
}

var debugLog = prefs.NewBool(false, prefs.PropMeta{
	Name:        "Debug Logging",
	Section:     "Logging",
	Description: "Enable verbose logging",
})

type TerminalOption struct {
	Name         string
	Executable   string
	SeparatorArg string
}

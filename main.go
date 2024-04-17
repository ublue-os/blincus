package main

import (
	"context"

	"github.com/bketelsen/blincus/internal/ui"
	"github.com/diamondburned/adaptive"
	"github.com/diamondburned/gotk4-adwaita/pkg/adw"
	"github.com/diamondburned/gotk4/pkg/glib/v2"
	"github.com/diamondburned/gotkit/app"
	"github.com/diamondburned/gotkit/app/prefs"
	"github.com/diamondburned/gotkit/components/logui"
	"github.com/diamondburned/gotkit/components/prefui"
	"github.com/diamondburned/gotkit/gtkutil"
	"github.com/diamondburned/gotkit/gtkutil/cssutil"

	_ "github.com/diamondburned/gotkit/gtkutil/aggressivegc"
)

// Version is connected to about.SetVersion.
var Version string

//func init() { about.SetVersion(Version) }

var _ = cssutil.WriteCSS(`
	window.background,
	window.background.solid-csd {
		background-color: @theme_bg_color;
	}
`)

func main() {
	m := manager{}
	m.app = app.New(context.Background(), "dev.brian.BlincusUI", "BlincusUI")
	m.app.AddJSONActions(map[string]interface{}{
		"app.preferences": func() { prefui.ShowDialog(m.win.Context()) },
		//	"app.about":       func() { about.New(m.win.Context()).Present() },
		"app.logs":        func() { logui.ShowDefaultViewer(m.win.Context()) },
		"app.newinstance": func() { m.win.NewInstance(m.win.Context()) },

		"app.quit": func() { m.app.Quit() },
	})
	// m.app.AddActionCallbacks(map[string]gtkutil.ActionCallback{
	// 	"app.open-channel": m.forwardSignalToWindow("open-channel", gtkcord.SnowflakeVariant),
	// 	"app.open-guild":   m.forwardSignalToWindow("open-guild", gtkcord.SnowflakeVariant),
	// })
	m.app.AddActionShortcuts(map[string]string{
		"<Ctrl>Q": "app.quit",
	})
	m.app.ConnectActivate(func() { m.activate(m.app.Context()) })
	m.app.RunMain()
}

type manager struct {
	app *app.Application
	win *ui.Window
}

func (m *manager) forwardSignalToWindow(name string, t *glib.VariantType) gtkutil.ActionCallback {
	return gtkutil.ActionCallback{
		ArgType: t,
		Func:    func(args *glib.Variant) { m.win.ActivateAction(name, args) },
	}
}

func (m *manager) activate(ctx context.Context) {

	adw.Init()
	adaptive.Init()

	if m.win != nil {
		m.win.Present()
		return
	}

	m.win = ui.NewWindow(ctx)
	m.win.Show()

	prefs.AsyncLoadSaved(ctx, func(err error) {
		if err != nil {
			app.Error(ctx, err)
		}
	})
}

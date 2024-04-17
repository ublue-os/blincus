package ui

import (
	"context"
	"fmt"
	"log"
	"log/slog"
	"path/filepath"
	"slices"
	"strings"

	"github.com/adrg/xdg"
	"github.com/ublue-os/blincusui/internal/blincus"
	"github.com/ublue-os/blincusui/internal/profiles"

	"github.com/diamondburned/gotk4-adwaita/pkg/adw"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"github.com/diamondburned/gotkit/app"
	"github.com/diamondburned/gotkit/components/logui"
	"github.com/diamondburned/gotkit/gtkutil"
	"github.com/diamondburned/gotkit/gtkutil/cssutil"
	"github.com/lxc/incus/shared/api"
	"github.com/ublue-os/blincusui/internal/cfg"
	"gopkg.in/yaml.v2"
	"libdb.so/ctxt"
)

var _ = cssutil.WriteCSS(`
	.titlebar {
		background-color: @headerbar_bg_color;
	}

	window.devel .titlebar {
		background-image: cross-fade(
			5% -gtk-recolor(url("resource:/org/gnome/Adwaita/styles/assets/devel-symbolic.svg")),
			image(transparent));
		background-repeat: repeat-x;
	}
`)

// Window is the main gtkcord window.
type Window struct {
	*adw.ApplicationWindow
	win          *app.Window
	ctx          context.Context
	Overview     *OverviewPage
	Stack        *gtk.Stack
	Client       *blincus.Client
	state        *State
	Display      Display
	ToastOverlay *adw.ToastOverlay
}

// NewWindow creates a new Window.
func NewWindow(ctx context.Context) *Window {
	appInstance := app.FromContext(ctx)

	// dynamically change log level based on preference setting
	debugLog.Pubsub.Subscribe(func() {
		slog.Info("Setting Log Level", slog.Bool("debug", debugLog.Value()))
		if debugLog.Value() {
			logui.SetDefaultLevel(slog.LevelDebug)
		} else {
			logui.SetDefaultLevel(slog.LevelInfo)
		}
	})

	win := adw.NewApplicationWindow(appInstance.Application)
	win.SetSizeRequest(320, 320)
	win.SetDefaultSize(800, 600)

	appWindow := app.WrapWindow(appInstance, &win.ApplicationWindow)
	ctx = app.WithWindow(ctx, appWindow)
	de, err := DisplayEnvironment()
	if err != nil {
		app.Error(ctx, err)
	}
	overlay := adw.NewToastOverlay()
	w := Window{
		ApplicationWindow: win,
		win:               appWindow,
		ctx:               ctx,
		Display:           de,
		ToastOverlay:      overlay,
	}

	state, err := NewState()
	if err != nil {
		if strings.Contains(err.Error(), "no config file found") {
			slog.Debug("No configuration file found")
		}
	}
	w.state = state
	w.ctx = ctxt.With(w.ctx, &w)

	c, err := blincus.NewClient()
	if err != nil {
		app.Error(ctx, err)
	}
	w.Client = c

	w.Stack = gtk.NewStack()
	w.Stack.SetTransitionType(gtk.StackTransitionTypeCrossfade)
	w.Overview = NewOverviewPage(ctx, state, &w)
	w.Stack.AddChild(w.Overview)

	w.Stack.SetVisibleChild(w.Overview)
	w.ToastOverlay.SetChild(w.Stack)
	win.SetContent(w.ToastOverlay)
	breakpoint := adw.NewBreakpoint(adw.BreakpointConditionParse("max-width: 500sp"))
	// //breakpoint.AddSetter(p.OverlaySplitView, "collapsed", true)
	breakpoint.AddSetter(w.Overview.SwitcherBar, "reveal", true)

	breakpoint.ConnectApply(func() {
		if w.WidthBelowThreshold() {
			w.Overview.ViewSwitcher.SetVisible(false)
		} else {
			w.Overview.HeaderBar.SetTitleWidget(w.Overview.ViewSwitcher)
			w.Overview.ViewSwitcher.SetVisible(true)
		}
	})

	breakpoint.ConnectUnapply(func() {
		w.Overview.HeaderBar.SetTitleWidget(w.Overview.ViewSwitcher)
		w.Overview.ViewSwitcher.SetVisible(true)
	})

	w.AddBreakpoint(breakpoint)
	w.EnsureProfiles()
	return &w
}

func (w *Window) Context() context.Context {
	return w.ctx
}

func (w *Window) EnsureProfiles() {

	slog.Info("Ensuring profiles")
	w.EnsureBaseProfiles()
	w.EnsureAlpineProfiles()

}
func (w *Window) EnsureAlpineProfiles() {
	ff, err := profiles.Alpine.ReadDir("alpine")
	if err != nil {
		app.Error(w.ctx, err)
		return
	}
	for _, f := range ff {
		pname := strings.TrimSuffix(f.Name(), ".yaml")
		slog.Debug("Ensuring Profile", slog.String("name", pname))

		p, err := w.Client.Profile(w.ctx, pname)
		if err != nil {
			if !strings.Contains(err.Error(), "not found") {
				if err != nil {
					app.Error(w.ctx, err)
					return
				}
			}
		}
		if p == nil {
			slog.Warn("Creating missing profile", slog.String("name", pname))
			contents, err := profiles.Alpine.ReadFile(filepath.Join("alpine", f.Name()))
			if err != nil {
				app.Error(w.ctx, err)
				return
			}
			var put api.ProfilesPost
			err = yaml.Unmarshal(contents, &put)
			if err != nil {
				app.Error(w.ctx, err)
				return
			}

			put.Name = pname
			err = w.Client.ProfileCreate(w.ctx, put)
			if err != nil {
				app.Error(w.ctx, err)
				return
			}
		}
	}
}
func (w *Window) EnsureBaseProfiles() {
	ff, err := profiles.Shifting.ReadDir("shifting")
	if err != nil {
		app.Error(w.ctx, err)
		return
	}
	for _, f := range ff {
		pname := strings.TrimSuffix(f.Name(), ".yaml")
		slog.Debug("Ensuring Profile", slog.String("name", pname))

		p, err := w.Client.Profile(w.ctx, pname)
		if err != nil {
			if !strings.Contains(err.Error(), "not found") {
				if err != nil {
					app.Error(w.ctx, err)
					return
				}
			}
		}
		if p == nil {
			slog.Warn("Creating missing profile", slog.String("name", pname))
			contents, err := profiles.Shifting.ReadFile(filepath.Join("shifting", f.Name()))
			if err != nil {
				app.Error(w.ctx, err)
				return
			}
			var put api.ProfilesPost
			err = yaml.Unmarshal(contents, &put)
			if err != nil {
				app.Error(w.ctx, err)
				return
			}

			put.Name = pname
			err = w.Client.ProfileCreate(w.ctx, put)
			if err != nil {
				app.Error(w.ctx, err)
				return
			}
		}
	}
}
func (w *Window) NewInstance(ctx context.Context) {

	newWin := gtk.NewWindow()
	newWin.SetTransientFor(&w.Window)
	newWin.SetModal(true)
	newWin.SetSizeRequest(700, 350)

	titleLabel := gtk.NewLabel("Create New Instance")
	titleLabel.AddCSSClass("header")

	createButton := gtk.NewButtonWithLabel("Create")
	cancelButton := gtk.NewButtonWithLabel("Cancel")

	createButton.SetSensitive(false)

	cancelButton.ConnectClicked(func() {
		newWin.Destroy()
	})

	newBoxTitlebar := adw.NewHeaderBar()
	newBoxTitlebar.SetTitleWidget(titleLabel)

	newBoxTitlebar.PackEnd(createButton)
	newBoxTitlebar.PackStart(cancelButton)
	newWin.SetTitlebar(newBoxTitlebar)

	clamp := adw.NewClamp()
	mainBox := gtk.NewBox(gtk.OrientationVertical, 10)
	mainBox.SetMarginBottom(10)
	mainBox.SetMarginEnd(10)
	mainBox.SetMarginStart(10)
	mainBox.SetMarginTop(10)

	boxedList := gtk.NewListBox()
	boxedList.AddCSSClass("boxed-list")

	nameEntryRow := adw.NewEntryRow()
	nameEntryRow.SetHExpand(true)
	nameEntryRow.SetTitle("Name")
	//nameEntryRow.AddCSSClass(".error")
	nameEntryRow.ConnectChanged(func() {
		if len(nameEntryRow.Text()) > 0 {
			createButton.SetSensitive(true)
			//nameEntryRow.RemoveCSSClass(".error")
		}
	})
	m := make(map[string]cfg.Favorite)
	for _, f := range w.state.Favorites.Value() {
		m[f.Name] = f
	}
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}

	favSelect := gtk.NewDropDownFromStrings(keys)
	imgSelectRow := adw.NewActionRow()
	imgSelectRow.SetTitle("Blueprint")
	imgSelectRow.SetActivatableWidget(favSelect)
	imgSelectRow.AddSuffix(favSelect)
	mountHost := adw.NewSwitchRow()
	mountHost.SetTitle("Mount $HOME from host")
	mountHost.SetSubtitle("Mount host's $HOME at container's $HOME/host")
	mountHost.SetActive(true)

	loadingSpinner := gtk.NewSpinner()

	createButton.ConnectClicked(func() {
		loadingSpinner.Start()

		done := func() {
			loadingSpinner.Stop()

			// the incus event watcher doesn't know when
			// cloud-init is done, but we know here because
			// we explicity call Wait() in the create call.
			// delete & re-add the instance so we can get information
			// about users & status
			// This is hacky, HACK. Need to figure out a better way to update
			// the status
			name := nameEntryRow.Text()
			for _, i := range w.state.Instances.Value() {
				if i.Name == name {
					// remove it
					updatedInstances := slices.DeleteFunc(w.state.Instances.Value(), func(i api.InstanceFull) bool {
						return i.Name == name
					})
					// save it
					w.state.Instances.Update(updatedInstances)
					// re-add it
					i, _, err := w.Client.Instance(context.Background(), name)
					if err != nil {
						log.Println("json error", err.Error())
					}
					updatedInstances = append(w.state.Instances.Value(), *i)
					// and save it again
					w.state.Instances.Update(updatedInstances)
					label := fmt.Sprintf("Instance %s created", name)
					t := adw.NewToast(label)
					w.ShowToast(t)
				}
			}
			newWin.Destroy()
		}

		// actually create it

		gtkutil.Async(w.ctx, func() func() {

			createButton.SetSensitive(false)
			// simulate create
			//	time.Sleep(10 * time.Second)
			name := nameEntryRow.Text()
			selItemObj := favSelect.SelectedItem()
			str := selItemObj.Cast().(*gtk.StringObject)
			selectedFavorite := m[str.String()]
			mh := mountHost.Active()
			prof := w.Display.Profile(selectedFavorite.Image)
			pp := []string{prof}
			pp = append(pp, selectedFavorite.ExtraProfiles...)
			err := w.Client.Launch(w.ctx, selectedFavorite.Image, name, pp, false, true)
			if err != nil {
				app.Error(ctx, err)
			}
			if mh {
				home, err := w.Client.UserHome(w.ctx, name)
				if err != nil {
					log.Println("error getting userhome:", err.Error())
					app.Error(ctx, err)
				}
				targetPath := filepath.Join(home, "host")
				mountName := "hostmount"
				slog.Debug("Mount",
					slog.String("target", targetPath),
					slog.String("source", xdg.Home))

				err = w.Client.AddDeviceToInstance(ctx, name, mountName, map[string]string{"type": "disk", "path": targetPath, "source": xdg.Home})
				if err != nil {
					app.Error(ctx, err)
				}

			}
			return func() {
				done()
			}

		})
	})

	boxedList.Append(nameEntryRow)
	boxedList.Append(imgSelectRow)
	boxedList.Append(mountHost)

	mainBox.Append(boxedList)
	mainBox.Append(loadingSpinner)
	clamp.SetChild(mainBox)
	newWin.SetChild(clamp)

	newWin.Present()
}

func (w *Window) WidthBelowThreshold() bool {
	width := adw.LengthUnitFromPx(adw.LengthUnitSp, float64(w.Width()), nil)
	return width < 500.0
}

func (w *Window) SetLoading() {
	panic("not implemented")
}

// SetTitle sets the window title.
func (w *Window) SetTitle(title string) {
	w.ApplicationWindow.SetTitle(app.FromContext(w.ctx).SuffixedTitle(title))
}

func (w *Window) ShowToast(t *adw.Toast) {
	w.ToastOverlay.AddToast(t)
}

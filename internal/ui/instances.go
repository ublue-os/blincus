package ui

import (
	"context"
	"fmt"
	"log"
	"log/slog"

	"github.com/bketelsen/blincus/internal/blincus"
	"github.com/diamondburned/gotk4-adwaita/pkg/adw"
	"github.com/diamondburned/gotk4/pkg/core/gioutil"
	"github.com/diamondburned/gotk4/pkg/glib/v2"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"github.com/diamondburned/gotkit/app"
	"github.com/diamondburned/gotkit/app/locale"
	"github.com/diamondburned/gotkit/components/actionbutton"
	"github.com/diamondburned/gotkit/gtkutil"
	"github.com/lxc/incus/shared/api"
)

type InstancePage struct {
	*adw.StatusPage
	Clamp        *adw.Clamp
	ListBox      *gtk.ListBox
	client       *blincus.Client
	state        *State
	instanceList *gioutil.ListModel[api.InstanceFull]
	win          *gtk.Window
	ctx          context.Context
	parent       *Window
}

func NewInstancePage(ctx context.Context, state *State, w *Window) *InstancePage {
	page := adw.NewStatusPage()
	page.SetTitle("Instances")
	p := &InstancePage{
		StatusPage: page,
		ctx:        ctx,
		client:     w.Client,
		state:      state,
		win:        &w.Window,
		parent:     w,
	}
	p.Clamp = adw.NewClamp()

	p.ListBox = gtk.NewListBox()
	p.ListBox.SetCSSClasses([]string{"boxed-list"})
	p.ListBox.SetSelectionMode(gtk.SelectionBrowse)

	p.Clamp.SetChild(p.ListBox)
	p.SetChild(p.Clamp)

	p.instanceList = gioutil.NewListModel[api.InstanceFull]()

	p.ListBox.BindModel(p.instanceList.ListModel, func(item *glib.Object) (widget gtk.Widgetter) {
		slog.Debug("listbox bind model instance")
		instance := gioutil.ObjectValue[api.InstanceFull](item)
		w := p.newInstanceItem(p.ctx, instance)
		return w
	})

	OnChange(p.ctx, state.Instances, func(ii []api.InstanceFull) {
		slog.Debug("instance on change handler")
		// if p.instanceList.NItems() > 0 {
		p.instanceList.Splice(0, p.instanceList.NItems(), state.Instances.Value()...)
		// }
	})

	return p

}

type instanceItem struct {
	*adw.ExpanderRow
	instance api.InstanceFull
}

func (ip *InstancePage) newInstanceItem(ctx context.Context, inst api.InstanceFull) *instanceItem {
	i := instanceItem{
		instance: inst,
	}
	ar := adw.NewExpanderRow()
	i.ExpanderRow = ar
	i.SetTitle(i.instance.Name)
	i.SetSubtitle(i.instance.Config["image.os"] + "/" + i.instance.Config["image.release"] + " - " + "(" + inst.Status + ")")
	users := []string{}
	var err error
	if inst.Status == "Running" {
		users, err = ip.client.InstanceUsers(ctx, inst.Name)
		if err != nil {
			app.Error(ctx, err)
			return &i
		}
	}

	// Box for terminal buttons
	termBox := gtk.NewBox(gtk.OrientationHorizontal, 0)
	termBox.SetCSSClasses([]string{"toolbar"})

	termRow := adw.NewActionRow()
	termRow.SetTitle(inst.Name + " Terminals")
	termButton := gtk.NewButtonFromIconName("terminal-app-symbolic")
	termButton.SetTooltipText("Open Root Terminal")
	if inst.Status != "Running" {
		termButton.SetSensitive(false)
	}
	termButton.ConnectClicked(func() {
		gtkutil.Async(ctx, func() func() {
			done := func() {
			}
			termKey := terminal.Value()
			selectedTerminal := terminalMap[termKey]
			err := LaunchRootTerminal(selectedTerminal, inst.Name)
			if err != nil {
				app.Error(ctx, err)
				return func() {
					done()
				}
			}
			return func() {
				done()
			}
		})
	})

	for _, u := range users {
		mybutton := actionbutton.NewButton(locale.Localized(u), "terminal-app-symbolic", gtk.PosLeft)
		mybutton.SetCSSClasses([]string{"flat"})
		mybutton.SetTooltipText("Open Terminal as " + u)
		mybutton.ConnectClicked(func() {
			gtkutil.Async(ctx, func() func() {
				done := func() {
				}
				termKey := terminal.Value()
				selectedTerminal := terminalMap[termKey]
				err := LaunchUserTerminal(selectedTerminal, inst.Name, u)
				if err != nil {
					log.Println(err.Error())
					app.Error(ctx, err)
					return func() {
						done()
					}
				}
				return func() {
					done()
				}
			})
		})

		termBox.Append(mybutton)
	}
	termBox.Append(termButton)
	termRow.AddSuffix(termBox)

	aRow := adw.NewActionRow()
	aRow.SetTitle(inst.Name + " Actions")

	actionBox := gtk.NewBox(gtk.OrientationHorizontal, 0)
	actionBox.SetCSSClasses([]string{"toolbar"})

	startButton := gtk.NewButtonFromIconName("media-playback-start-symbolic")
	startButton.SetTooltipText("Start Instance")
	startButton.SetCSSClasses([]string{"suggested-action"})
	startButton.SetSensitive(false)
	if inst.Status != "Running" {
		startButton.SetSensitive(true)
	}
	startButton.ConnectClicked(func() {
		err := ip.client.StartInstance(ip.ctx, inst.Name)
		if err != nil {
			app.Error(ctx, err)
		}
		label := fmt.Sprintf("Instance %s started", inst.Name)
		t := adw.NewToast(label)
		ip.parent.ShowToast(t)
	})

	stopButton := gtk.NewButtonFromIconName("media-playback-stop-symbolic")
	stopButton.SetTooltipText("Stop Instance")
	stopButton.SetCSSClasses([]string{"opaque"})
	stopButton.SetSensitive(false)
	if inst.Status == "Running" {
		stopButton.SetSensitive(true)
	}
	stopButton.ConnectClicked(func() {
		err := ip.client.StopInstance(ip.ctx, inst.Name)
		if err != nil {
			app.Error(ctx, err)
		}
		label := fmt.Sprintf("Instance %s stopped", inst.Name)
		t := adw.NewToast(label)
		ip.parent.ShowToast(t)
	})

	delButton := gtk.NewButtonFromIconName("edit-delete-symbolic")
	delButton.SetTooltipText("Delete Instance")
	delButton.SetCSSClasses([]string{"destructive-action"})
	delButton.ConnectClicked(func() {
		window := app.GTKWindowFromContext(ip.ctx)
		dialog := adw.NewMessageDialog(window,
			"Delete Instance",
			fmt.Sprintf("Are you sure you want to delete instance '%s'?", inst.Name))
		dialog.SetBodyUseMarkup(true)
		dialog.AddResponse("cancel", "_Cancel")
		dialog.AddResponse("delete", "_Delete")
		dialog.SetResponseAppearance("delete", adw.ResponseDestructive)
		dialog.SetDefaultResponse("cancel")
		dialog.SetCloseResponse("cancel")
		dialog.ConnectResponse(func(response string) {
			switch response {
			case "delete":

				err := ip.client.DeleteInstance(ip.ctx, inst.Name)
				if err != nil {
					app.Error(ctx, err)
				}
				label := fmt.Sprintf("Instance %s deleted", inst.Name)
				t := adw.NewToast(label)
				ip.parent.ShowToast(t)
			}
		})
		dialog.Show()

	})
	if inst.Status == "Running" {
		delButton.SetSensitive(false)
	}

	actionBox.Append(startButton)
	actionBox.Append(stopButton)
	actionBox.Append(delButton)

	aRow.AddSuffix(actionBox)

	ar.AddRow(termRow)
	ar.AddRow(aRow)
	return &i

}

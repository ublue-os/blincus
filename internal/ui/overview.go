package ui

import (
	"context"

	"github.com/diamondburned/gotk4-adwaita/pkg/adw"
	"github.com/diamondburned/gotk4/pkg/gio/v2"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
)

type OverviewPage struct {
	*gtk.Box
	HeaderBar     *adw.HeaderBar
	ViewStack     *adw.ViewStack
	ViewSwitcher  *adw.ViewSwitcher
	SwitcherBar   *adw.ViewSwitcherBar
	InstancePage  *InstancePage
	FavoritesPage *BlueprintsPage
	state         *State

	ctx context.Context
}

func NewOverviewPage(ctx context.Context, state *State, w *Window) *OverviewPage {

	box := gtk.NewBox(gtk.OrientationVertical, 1)
	p := OverviewPage{
		ctx:   ctx,
		Box:   box,
		state: state,
	}
	p.ViewStack = adw.NewViewStack()
	p.ViewStack.SetVExpand(true)

	p.ViewSwitcher = adw.NewViewSwitcher()
	p.ViewSwitcher.SetStack(p.ViewStack)
	p.ViewSwitcher.SetPolicy(adw.ViewSwitcherPolicyWide)

	p.SwitcherBar = adw.NewViewSwitcherBar()
	p.SwitcherBar.SetStack(p.ViewStack)

	p.HeaderBar = adw.NewHeaderBar()
	p.HeaderBar.SetTitleWidget(p.ViewSwitcher)

	menuButton := gtk.NewMenuButton()
	menuButton.SetIconName("open-menu-symbolic")
	menuButton.SetTooltipText("Main Menu")
	menuModel := gio.NewMenu()
	menuModel.Append("Preferences", "app.preferences")
	menuModel.Append("Logs", "app.logs")

	menuButton.SetMenuModel(menuModel)
	p.HeaderBar.PackEnd(menuButton)
	addButton := gtk.NewButtonFromIconName("list-add-symbolic")
	addButton.SetTooltipText("New Instance")
	//addButton.SetCSSClasses([]string{"suggested-action"})
	addButton.ConnectClicked(func() {
		w.NewInstance(ctx)
	})
	p.HeaderBar.PackStart(addButton)
	p.Box.Prepend(p.HeaderBar)
	p.Box.Append(p.ViewStack)
	p.Box.Append(p.SwitcherBar)

	p.InstancePage = NewInstancePage(ctx, state, w)
	p.FavoritesPage = NewBlueprintsPage(ctx, state, w)

	p.ViewStack.AddTitledWithIcon(p.InstancePage, "Instances", "Instances", "open-menu-symbolic")
	p.ViewStack.AddTitledWithIcon(p.FavoritesPage, "Blueprints", "Blueprints", "starred-symbolic")

	return &p
}

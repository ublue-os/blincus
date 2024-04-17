package ui

import (
	"context"
	"fmt"
	"log/slog"
	"slices"

	"github.com/diamondburned/gotk4-adwaita/pkg/adw"
	"github.com/diamondburned/gotk4/pkg/core/gioutil"
	"github.com/diamondburned/gotk4/pkg/glib/v2"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"github.com/diamondburned/gotkit/app"
	"github.com/ublue-os/blincusui/internal/blincus"
	"github.com/ublue-os/blincusui/internal/cfg"
)

type BlueprintsPage struct {
	*adw.StatusPage
	client  *blincus.Client
	ctx     context.Context
	state   *State
	win     *gtk.Window
	favList *gioutil.ListModel[cfg.Favorite]

	FavoriteList *gtk.ListBox
	parent       *Window
}

func NewBlueprintsPage(ctx context.Context, state *State, w *Window) *BlueprintsPage {
	page := adw.NewStatusPage()
	page.SetTitle("Blueprints")
	p := &BlueprintsPage{
		StatusPage: page,
		ctx:        ctx,
		client:     w.Client,
		state:      state,
		win:        &w.Window,
		parent:     w,
	}
	listBox := gtk.NewListBox()
	listBox.AddCSSClass("boxed-list")
	p.FavoriteList = listBox
	p.favList = gioutil.NewListModel[cfg.Favorite]()

	p.FavoriteList.BindModel(p.favList.ListModel, func(item *glib.Object) (widget gtk.Widgetter) {
		slog.Debug("listbox bind model favorite")
		fav := gioutil.ObjectValue[cfg.Favorite](item)
		w := p.newFavoriteItem(p.ctx, fav)
		return w
	})
	contentBox := gtk.NewBox(gtk.OrientationVertical, 0)

	clamp := adw.NewClamp()

	newButton := gtk.NewButton()
	newButton.SetCSSClasses([]string{"suggested-action"})
	newButtonContent := adw.NewButtonContent()
	newButtonContent.SetIconName("list-add-symbolic")
	newButtonContent.SetLabel("New Blueprint")
	newButton.SetChild(newButtonContent)
	newButton.ConnectClicked(func() {
		p.NewFavorite()
	})

	toolBox := gtk.NewBox(gtk.OrientationHorizontal, 0)
	toolBox.AddCSSClass("linked")

	toolBox.Append(newButton)
	contentBox.Append(toolBox)
	contentBox.Append(p.FavoriteList)

	//	p.Add(p.FavoriteGroup)
	clamp.SetChild(contentBox)
	p.SetChild(clamp)
	OnChange(p.ctx, state.Favorites, func(ii []cfg.Favorite) {
		slog.Debug("fav on change handler")
		// if p.instanceList.NItems() > 0 {
		p.favList.Splice(0, p.favList.NItems(), state.Favorites.Value()...)
		// }
	})
	//p.ShowFavorites()

	return p

}

type favoriteItem struct {
	*adw.ExpanderRow
	favorite cfg.Favorite
}

func (ip *BlueprintsPage) newFavoriteItem(ctx context.Context, fav cfg.Favorite) *favoriteItem {
	i := favoriteItem{
		favorite: fav,
	}
	ar := adw.NewExpanderRow()
	i.ExpanderRow = ar
	i.SetTitle(i.favorite.Name)
	i.SetSubtitle(i.favorite.Description + " - (" + i.favorite.Image + ")")
	row := ip.AddFavorite(fav)
	ar.AddRow(row)
	return &i

}

func (p *BlueprintsPage) AddFavorite(favorite cfg.Favorite) *adw.ActionRow {
	ar := adw.NewActionRow()
	ar.SetTitle(favorite.Name)
	ar.SetSubtitle(favorite.Description + " - (" + favorite.Image + ")")
	actionBox := gtk.NewBox(gtk.OrientationHorizontal, 0)
	actionBox.SetCSSClasses([]string{"toolbar"})

	delButton := gtk.NewButtonFromIconName("trash")
	delButton.AddCSSClass("destructive-action")
	delButton.ConnectClicked(func() {
		window := app.GTKWindowFromContext(p.ctx)
		dialog := adw.NewMessageDialog(window,
			"Delete Blueprint",
			fmt.Sprintf("Are you sure you want to delete blueprint '%s'?", favorite.Name))
		dialog.SetBodyUseMarkup(true)
		dialog.AddResponse("cancel", "_Cancel")
		dialog.AddResponse("delete", "_Delete")
		dialog.SetResponseAppearance("delete", adw.ResponseDestructive)
		dialog.SetDefaultResponse("cancel")
		dialog.SetCloseResponse("cancel")
		dialog.ConnectResponse(func(response string) {
			switch response {
			case "delete":
				updatedFavorites := slices.DeleteFunc(p.state.Favorites.Value(), func(f cfg.Favorite) bool {
					return f.Name == favorite.Name
				})
				p.state.UpdateFavorites(updatedFavorites)
				err := cfg.Save(p.state.Favorites.Value())
				if err != nil {
					app.Error(p.ctx, err)
				}
				label := fmt.Sprintf("Blueprint %s deleted", favorite.Name)
				t := adw.NewToast(label)
				p.parent.ShowToast(t)
			}
		})
		dialog.Show()

	})

	actionBox.Append(delButton)

	ar.AddSuffix(actionBox)
	return ar
}

func (p *BlueprintsPage) NewFavorite() {
	newWin := gtk.NewWindow()
	newWin.SetModal(true)
	newWin.SetSizeRequest(700, 350)
	newWin.SetTransientFor(p.win)

	titleLabel := gtk.NewLabel("Create New Blueprint")
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

	detailsGroup := adw.NewPreferencesGroup()
	detailsGroup.SetTitle("Blueprint Details")

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
	imageEntryRow := adw.NewEntryRow()
	imageEntryRow.SetHExpand(true)
	imageEntryRow.SetTitle("Image")
	//nameEntryRow.AddCSSClass(".error")
	descEntryRow := adw.NewEntryRow()
	descEntryRow.SetHExpand(true)
	descEntryRow.SetTitle("Description")

	availableProfiles, err := p.client.ProfileNames(p.ctx)
	if err != nil {
		app.Error(p.ctx, err)
	}
	selectedProfiles := make(map[string]bool)

	profileGroup := adw.NewPreferencesGroup()
	profileGroup.SetTitle("Extra Profiles (Advanced)")
	profileGroup.SetDescription("Default and Display already included")

	suffixBox := gtk.NewBox(gtk.OrientationHorizontal, 0)
	suffixBox.AddCSSClass("flat")
	newButton := gtk.NewDropDownFromStrings(availableProfiles)
	newButton.SetCSSClasses([]string{"flat"})
	plusButton := gtk.NewButtonFromIconName("list-add-symbolic")
	plusButton.SetCSSClasses([]string{"flat"})
	plusButton.ConnectClicked(func() {
		profileName := newButton.SelectedItem()
		str := profileName.Cast().(*gtk.StringObject)
		_, ok := selectedProfiles[str.String()]
		if !ok {
			selectedProfiles[str.String()] = true
			ar := adw.NewActionRow()
			ar.SetTitle(str.String())
			removeButton := gtk.NewButtonFromIconName("trash")
			removeButton.SetTooltipText("Remove Profile")
			ar.AddSuffix(removeButton)
			removeButton.ConnectClicked(func() {
				profileGroup.Remove(ar)
				delete(selectedProfiles, str.String())
			})
			profileGroup.Add(ar)
		}
	})

	suffixBox.Append(newButton)
	suffixBox.Append(plusButton)
	profileGroup.SetHeaderSuffix(suffixBox)

	detailsGroup.Add(nameEntryRow)
	detailsGroup.Add(imageEntryRow)
	detailsGroup.Add(descEntryRow)

	mainBox.Append(detailsGroup)
	mainBox.Append(profileGroup)
	clamp.SetChild(mainBox)
	newWin.SetChild(clamp)
	createButton.ConnectClicked(func() {
		// add favorite
		name := nameEntryRow.Text()
		image := imageEntryRow.Text()
		desc := descEntryRow.Text()
		var profiles []string
		for k := range selectedProfiles {
			profiles = append(profiles, k)
		}
		fav := cfg.Favorite{
			Name:          name,
			Image:         image,
			ExtraProfiles: profiles,
			Description:   desc,
		}
		p.state.UpdateFavorites(append(p.state.Favorites.Value(), fav))
		err := cfg.Save(p.state.Favorites.Value())
		if err != nil {
			app.Error(p.ctx, err)
		}
		label := fmt.Sprintf("Blueprint %s created", fav.Name)
		t := adw.NewToast(label)
		p.parent.ShowToast(t)

		newWin.Destroy()

	})

	newWin.Present()
}

package ui

import (
	"cmp"
	"context"
	"encoding/json"
	"log"
	"log/slog"
	"slices"
	"strings"

	"github.com/imkira/go-observer/v2"
	incus "github.com/lxc/incus/client"
	"github.com/lxc/incus/shared/api"
	"github.com/ublue-os/blincusui/internal/blincus"
	"github.com/ublue-os/blincusui/internal/cfg"
)

type State struct {
	Favorites     observer.Property[[]cfg.Favorite]
	client        *blincus.Client
	incusListener *incus.EventListener
	Instances     observer.Property[[]api.InstanceFull]
}

func NewState() (*State, error) {
	slog.Debug("loading configuration")
	favs, err := cfg.Load()
	if err != nil {
		return nil, err
	}
	// sort them
	slices.SortFunc(favs, func(a, b cfg.Favorite) int {
		return cmp.Compare(strings.ToLower(a.Name), strings.ToLower(b.Name))
	})
	slog.Debug("configuration loaded")
	c, err := blincus.NewClient()
	if err != nil {
		return nil, err
	}
	slog.Debug("getting incus instances")
	instances, err := c.Instances(context.Background())
	if err != nil {
		return nil, err
	}

	// sort them
	slices.SortFunc(instances, func(a, b api.InstanceFull) int {
		return cmp.Compare(strings.ToLower(a.Name), strings.ToLower(b.Name))
	})
	listener, err := c.Listen()
	if err != nil {
		return nil, err
	}
	state := &State{
		Favorites:     observer.NewProperty(favs),
		Instances:     observer.NewProperty(instances),
		client:        c,
		incusListener: listener,
	}
	slog.Info("starting watch", slog.String("target", "incus"))
	state.WatchIncus()
	return state, nil
}

func (s *State) UpdateInstances(instances []api.InstanceFull) {
	slices.SortFunc(instances, func(a, b api.InstanceFull) int {
		return cmp.Compare(strings.ToLower(a.Name), strings.ToLower(b.Name))
	})
	s.Instances.Update(instances)
}

func (s *State) UpdateFavorites(favorites []cfg.Favorite) {
	slices.SortFunc(favorites, func(a, b cfg.Favorite) int {
		return cmp.Compare(strings.ToLower(a.Name), strings.ToLower(b.Name))
	})
	s.Favorites.Update(favorites)
}

func (s *State) WatchIncus() {
	s.incusListener.AddHandler([]string{api.EventTypeLifecycle}, func(e api.Event) {
		slog.Debug("event received", slog.String("metadata", string(e.Metadata)))
		var ev api.EventLifecycle
		err := json.Unmarshal(e.Metadata, &ev)
		if err != nil {
			log.Println("json error", err.Error())
		}

		slog.Debug("action", slog.String("name", ev.Action))
		if ev.Action == "instance-deleted" {
			slog.Info("removing instance", slog.String("action", "remove"), slog.String("name", ev.Name))
			updatedInstances := slices.DeleteFunc(s.Instances.Value(), func(i api.InstanceFull) bool {
				return i.Name == ev.Name
			})
			s.UpdateInstances(updatedInstances)
		}
		if ev.Action == "instance-created" {
			slog.Info("adding instance", slog.String("action", "create"), slog.String("name", ev.Name))
			i, _, err := s.client.Instance(context.Background(), ev.Name)
			if err != nil {
				log.Println("json error", err.Error())
			}
			updatedInstances := append(s.Instances.Value(), *i)
			s.UpdateInstances(updatedInstances)

		}
		if ev.Action == "instance-started" {
			slog.Info("updating instance", slog.String("action", "start"), slog.String("name", ev.Name))
			updatedInstances := slices.DeleteFunc(s.Instances.Value(), func(i api.InstanceFull) bool {
				return i.Name == ev.Name
			})
			i, _, err := s.client.Instance(context.Background(), ev.Name)
			if err != nil {
				log.Println("json error", err.Error())
			}
			updatedInstances = append(updatedInstances, *i)
			s.UpdateInstances(updatedInstances)

		}
		if ev.Action == "instance-stopped" {
			slog.Info("updating instance", slog.String("action", "stop"), slog.String("name", ev.Name))
			updatedInstances := slices.DeleteFunc(s.Instances.Value(), func(i api.InstanceFull) bool {
				return i.Name == ev.Name
			})
			i, _, err := s.client.Instance(context.Background(), ev.Name)
			if err != nil {
				log.Println("json error", err.Error())
			}
			updatedInstances = append(updatedInstances, *i)
			s.UpdateInstances(updatedInstances)

		}

	})
}

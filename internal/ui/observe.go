package ui

import (
	"context"

	"github.com/diamondburned/gotk4/pkg/glib/v2"
	"github.com/imkira/go-observer/v2"
)

// Call function when prop changes, and also once initially
func OnChange[T any](ctx context.Context, prop observer.Property[T], f func(T)) {
	defer f(prop.Value())
	go func() {
		stream := prop.Observe()
		for {
			select {
			case <-stream.Changes():
				stream.Next()
				glib.IdleAdd(func() {
					f(stream.Value())
				})
			case <-ctx.Done():
				return
			}
		}
	}()
}

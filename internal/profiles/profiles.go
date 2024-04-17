package profiles

import (
	"embed"
)

//go:embed shifting/*.yaml
var Shifting embed.FS

//go:embed alpine/*.yaml
var Alpine embed.FS

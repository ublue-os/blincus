package cfg

import (
	"log"
	"log/slog"
	"os"
	"path/filepath"
	"sync"

	"github.com/adrg/xdg"
	"gopkg.in/ini.v1"
)

const appName = "BlincusUI" //TODO blincus

// const configName = "favorites.json"
const configIniName = "favorites.ini" //TODO config.ini

var lock sync.Mutex

type Favorite struct {
	Name          string   `json:"name,omitempty"`
	Description   string   `json:"description,omitempty"`
	Image         string   `json:"image,omitempty"`
	Scripts       string   `json:"scripts,omitempty"`
	ExtraProfiles []string `json:"extra_profiles,omitempty"`
}

func Load() ([]Favorite, error) {
	var favs []Favorite

	config, err := readOrNew()
	if err != nil {
		return nil, err
	}
	slog.Debug("Config Loaded")
	for _, section := range config.Sections() {
		if section.Name() != "DEFAULT" {
			f := Favorite{}
			f.Description = section.Key("description").String()
			f.Image = section.Key("image").String()
			f.Name = section.Name()
			favs = append(favs, f)
		}
	}
	return favs, nil

}
func MakeFavorites() []Favorite {
	favs := []Favorite{
		{
			Name:        "Jammy",
			Description: "Jammy Cloud",
			Image:       "images:ubuntu/jammy/cloud",
			//		ExtraProfiles: []string{"default"},
		},
		{
			Name:        "F39",
			Description: "F39 Cloud",
			Image:       "images:fedora/39/cloud",
			//		ExtraProfiles: []string{"default"},
		},
	}
	return favs

}

func Save(favs []Favorite) error {
	lock.Lock()
	defer lock.Unlock()

	config, err := readOrNew()
	if err != nil {
		return err
	}
	slog.Debug("Config Loaded")

	for _, fav := range favs {
		config.Section(fav.Name).Key("description").SetValue(fav.Description)
		config.Section(fav.Name).Key("image").SetValue(fav.Image)

	}
	name, err := configIniFile()
	if err != nil {
		return err
	}
	config.SaveTo(name)
	return nil
}

// func configFile() (string, error) {
// 	return xdg.ConfigFile(filepath.Join(appName, configName))

// }
func configIniFile() (string, error) {
	return xdg.ConfigFile(filepath.Join(appName, configIniName))

}

func readOrNew() (*ini.File, error) {
	configFilePath, err := configIniFile()
	if err != nil {
		log.Fatal(err)
	}
	slog.Debug("Config File", slog.String("location", configFilePath))

	// Check if user config file exists, if not create it
	_, err = os.Stat(configFilePath)
	if os.IsNotExist(err) {
		slog.Debug("Creating User Config File", slog.String("path", configFilePath))

		err = new(configFilePath)
		if err != nil {
			log.Fatal(err)
		}
	}

	return ini.Load(configFilePath)

}

func new(path string) error {
	cfg := ini.Empty()
	err := defaults(cfg)
	if err != nil {
		return err
	}
	return cfg.SaveTo(path)
}

func defaults(ini *ini.File) error {
	// Section: Default
	favs := MakeFavorites()

	for _, fav := range favs {

		m, err := ini.NewSection(fav.Name)
		if err != nil {
			return err
		}
		m.Key("description").SetValue(fav.Description)
		m.Key("image").SetValue(fav.Image)
	}
	return nil

}

package cfg

import (
	"encoding/json"
	"log"
	"log/slog"
	"os"
	"path/filepath"
	"sync"

	"github.com/adrg/xdg"
)

const appName = "Blincus"
const configName = "favorites.json"

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
	cf, err := configFile()
	slog.Debug("config file", slog.String("location", cf))

	if err != nil {
		log.Println("getting config file location", err.Error())
		return []Favorite{}, err
	}
	_, err = os.Stat(cf)
	if err != nil {
		//return favs, errors.New("no config file found")
		err2 := MakeFavorites()
		if err2 != nil {
			return []Favorite{}, err
		}
	}
	bb, err := os.ReadFile(cf)
	if err != nil {
		log.Println("reading config file", err.Error())
		return []Favorite{}, err
	}
	err = json.Unmarshal(bb, &favs)
	if err != nil {
		log.Println("unmarshal config file", err.Error())
		return []Favorite{}, err
	}
	return favs, nil

}
func MakeFavorites() error {
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
	return Save(favs)

}

func Save(favs []Favorite) error {
	lock.Lock()
	defer lock.Unlock()

	cf, err := configFile()
	if err != nil {
		log.Println("getting config file location", err.Error())
		return err
	}
	bb, err := json.Marshal(favs)
	if err != nil {
		log.Println("marshal json", err.Error())
		return err
	}
	err = os.WriteFile(cf, bb, 0755)
	if err != nil {
		log.Println("write config file", err.Error())
		return err
	}
	return nil
}

func configFile() (string, error) {
	return xdg.ConfigFile(filepath.Join(appName, configName))

}

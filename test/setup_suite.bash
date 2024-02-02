setup_suite() {
   
    wget -O ~/.local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
   ./empty-incus.sh
    rm -rf ~/.config/blincus
    rm -rf ~/.local/share/blincus
    if ! grep -q 'root:1000:1' /etc/subgid; then
        echo "root:1000:1" | sudo tee -a /etc/subuid /etc/subgid
	fi

	if ! grep -q 'root:1000:1' /etc/subuid; then

		echo "root:1000:1" | sudo tee -a /etc/subuid /etc/subgid
	fi

    ./install


}
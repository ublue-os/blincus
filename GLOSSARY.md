# Glossary

<dl>
  <dt><b>image</b></dt>
  <dd>Pre-built operating system installations.</dd>
  <dd><a href="https://linuxcontainers.org/incus/docs/main/images/#images">Images</a> can be built locally or downloaded from a <a href="https://linuxcontainers.org/incus/docs/main/reference/remote_image_servers/#remote-image-servers">remote image server</a>. </dd>
  <dd>Original demonstration recipes are stored at <code>~/.local/share/blincus/recipes</code></dd>
  <dt><b>recipe</b></dt>
  <dd>Packer recipe to build images that Blincus uses to create your instances.</dd>
  <dd>Your recipes are stored at <code>~/.config/blincus/recipes</code></dd>
  <dd>Original demonstration recipes are stored at <code>~/.local/share/blincus/recipes</code></dd>
  <dt><b>profile</b></dt>
  <dd>Incus <a href="https://linuxcontainers.org/incus/docs/main/profiles/">profile</a> applied to your instance at launch.</dd>
  <dd>Your profiles are stored at <code>~/.config/blincus/profiles</code></dd>
  <dd>Original demonstration profiles are stored at <code>~/.local/share/blincus/profiles</code></dd>
  <dt><b><a href="https://cloudinit.readthedocs.io/en/latest/">cloud-init</a></b></dt>
  <dd>YAML-based initialization document that specifies provisioning users, ssh keys, packages, files and more</dd>
  <dd>Images with <code>cloud-init</code> installed will execute the provided configuration at instance launch.</dd>
  <dt><b>scripts</b></dt>
  <dd>Shared, distribution specific scripts that will be mounted into your instance at <code>/opt/scripts</code></dd>
  <dd>Your scripts are stored at <code>~/.config/blincus/scripts</code></dd>
  <dd>Original demonstration scripts are stored at <code>~/.local/share/blincus/scripts</code></dd>
  <dt><b>template</b></dt>
  <dd>A template is a launch specification that combines one or more <code>profiles</code>, a base image, a scripts directory reference, and a <code>cloud-init</code> reference. </dd>
  <dd>Your templates are defined in the Blincus config file</code></dd>
  <dd>Your config file is located at <code>~/.config/blincus/config.ini</code></dd>
  <dt><b>Blincus config</b></dt>
  <dd><code>ini</code> formatted configuration file that </code></dd>
  <dd>Your configuration file is located at <code>~/.config/blincus/config.ini</code></dd>
</dl>

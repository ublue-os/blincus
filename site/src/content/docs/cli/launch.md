---
title: blincus launch
description: | 
  Launch a new instance  

---

# blincus launch

Launch a new instance  
Use `blincus template list` to see a list of available templates.  


| Attributes       | &nbsp;
|------------------|-------------
| Alias:           | l

## Usage

```bash
blincus launch NAME [OPTIONS]
```

## Examples

```bash
blincus launch -t ubuntu mydevctr
```

```bash
blincus launch -t ubuntux mydevctr
```

```bash
blincus launch -t fedora mydevmachine
```

```bash
blincus launch -t ubuntu -w /var/home/me/projects/blincus blincusdev
```

```bash
blincus launch --vm large -t ubuntu myfatvm
```

## Arguments

#### *NAME*

Instance name

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

## Options

#### *--template, -t TEMPLATE*

Blincus template name   
Use `blincus template list` to see available templates,  
or view ~/.config/blincus/config.ini  


| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

#### *--vm, -v SIZE*

Run as a virtual machine with AWS "t3" style sizes  


| Attributes      | &nbsp;
|-----------------|-------------
| Allowed Values: | nano, micro, small, medium, large, xlarge, 2xlarge

#### *--workspace, -w DIRECTORY*

Mount specified directory at "/workspace"  


| Attributes      | &nbsp;
|-----------------|-------------
| Conflicts With: | *--vm*



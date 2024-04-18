---
title: blincus launch
description: | 
  Launch a new instance  

---

# blincus launch

Launch a new instance  
Use `blincus blueprint list` to see a list of available blueprints.

| Attributes       | &nbsp;
|------------------|-------------
| Alias:           | l

## Usage

```bash
blincus launch NAME [OPTIONS]
```

## Examples

```bash
blincus launch -b ubuntu mydevctr
```

```bash
blincus launch -b ubuntux mydevctr
```

```bash
blincus launch -b fedora mydevmachine
```

```bash
blincus launch -b ubuntu -w /var/home/me/projects/blincus blincusdev
```

```bash
blincus launch --vm large -b ubuntu myfatvm
```

## Arguments

#### *NAME*

Instance name

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

## Options

#### *--blueprint, -b BLUEPRINT*

Blincus blueprint name   
Use `blincus blueprint list` to see available blueprints,  
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



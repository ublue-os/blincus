---
title: blincus
description: | 
  Manage development containers with Incus  

---

# blincus

Manage development containers with Incus  
  
Wraps the `incus` command, so commands not implemented   
in blincus will pass through to `incus`.  


| Attributes       | &nbsp;
|------------------|-------------
| Version:         | 0.1.4
| Extensible:      | incus

## Usage

```bash
blincus COMMAND
```

## Dependencies

#### *incus*

incus is required to use blincus.

## Environment Variables

#### *CONFIG_FILE*

Location of blincus config.ini

| Attributes      | &nbsp;
|-----------------|-------------
| Default Value:  | $HOME/.config/blincus/config.ini

## Commands

- [blincus config](/cli/blincus/config) - Manage blincus config
- [blincus launch](/cli/blincus/launch) - Launch a new instance
- [blincus shell](/cli/blincus/shell) - Open a shell in an instance
- [blincus template](/cli/blincus/template) - Manage blincus templates



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

## Arguments

#### *NAME*

Instance name

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

## Options

#### *--template, -t TEMPLATE*

Blincus template name   
Use `blincus template list` to see available templates  


| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes



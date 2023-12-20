---
title: blincus custom-image create
description: | 
  Create custom image recipe and template
---

# blincus custom-image create

Create custom image recipe and template

| Attributes       | &nbsp;
|------------------|-------------
| Alias:           | c

## Usage

```bash
blincus custom-image create NAME [OPTIONS]
```

## Examples

```bash
blincus custom-image create ubuntu -t ubuntu -s ubuntu
```

## Arguments

#### *NAME*

Template name

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

## Options

#### *--template, -t TEMPLATE*

Template to copy   
Use `blincus template list` to see available templates  


| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

#### *--scripts, -s SCRIPTS*

Scripts directory to use   


| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes



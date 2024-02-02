---
title: Why Blincus?
description: Why yet another development container tool?
---

As a developer, you already have a lot of choices for local development.

- Local: install required tools and libraries locally
- Virtual Machine: create a VM, install required libraries and tools there
- Containers: keep source code locally, but develop inside a container

There are benefits and drawbacks to each approach. Let's take a simplistic look at each:

## Local

Installing your tools and libraries locally is by far the easiest approach. There's no hassle figuring out where you should be coding, it's on your laptop.

Unfortunately the Local method breaks down quickly if you have multiple projects that require different versions of libraries or tools. It's relatively easy to use the `version manager` type tools (nvm, rvm, etc) to install different versions of language tools. It's nearly impossible to have multiple versions of libraries like `libgtk` or `libssl` installed at the same time though. The arguments for isolated development environments have been made by many in the past. 

Finally, your local laptop is probably radically different from the operating environment to which you're deploying.

This is the least appealing option for stability when working on multiple projects.

## Virtual Machine

Installing your tools and libraries in a virtual machine and developing in the VM is another popular option.

There are a few drawbacks to this method though. Virtual Machines become ["pets"](https://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/), which require maintenance and long term persistant disk usage. Virtual machines also take a long time to create and provision. Going from an ISO to a working development environment will take 10 minutes or more, even if you have all the installations scripted.

Finally, working on a virtual machine can feel clunky. You're confined to using SSH and remote desktop viewers, both of which add some extra friction to the development process.

This is a common choice for developers, but we can do better.

## Containers

Docker brought us a world where you can define a development environment in a Dockerfile and run a single command to get a running shell inside that environment with your source code mounted. Hooray!

But Docker (and friends) were really built for running a single process inside a container. The model breaks when you need more than one process -- like adding a database server or a graphical desktop environment. The hacks that have been created to work around this limitation are annoying at best. `docker-compose` lets you define multiple containers that run as a group, but the friction of creating a working Dockerfile is multiplied by the number of services you need to run.

Finally, working in a container can be a very frustrating experience. This manifests in sometimes subtle ways like slow file operations between host and container, or hard-to-debug permissions issues.

Containerized development is getting great, especially with tooling like [dev containers](https://containers.dev/) making the process easier.

## Blincus

Blincus aims to bring the power and flexibility of the Virtual Machine model to containerized development without the drawbacks. 

Blincus is powered by [incus](https://linuxcontainers.org/incus/), which uses "system containers". Unlike Docker containers, system containers have a full init system, and for 99% of your development they can be treated just like a virtual machine. You can install packages and services just like a virtual machine, but start and stop them instantly like a container. 

Container images start from pre-built file systems, so the time required for installation drops from tens of minutes to the few seconds required to download the container image.

Finally, Blincus makes the process of launching and provisioning containers less tedious by providing a set of pre-configured templates. You can use the provided templates as-is, or you can customize them to suit your needs. When you really need to flex your tools you can create customized images using Packer.


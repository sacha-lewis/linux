Installation

On Aurora DX, install the GUI:
```aiignore
sudo rpm-ostree install virt-manager
```

Reboot.

Then verify virtualization is available:
```aiignore
lsmod | grep kvm
```

You should see something like:
```aiignore
kvm_intel
kvm
```

That means your CPU virtualization support is active.


# Install Aurora Linux

Create new virtual machine.

- Import existing disk image.
- Select storage path (hard disk)
- fedora 43
- customize before 
- 

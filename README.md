# mednafen-happyeyes

Patches and a build script to make Mednafen's debugger easier to read without eyestrain.

This project supports Mednafen 1.21.3, and it has been tested on both Microsoft Windows and Debian linux.

The patches are released under the GPL license, in order to match Mednafen's own license.


## Why?

The Mednafen emulator is best-of-class for emulating a number of consoles, especially the Sony PlayStation, NEC PC Engine, NEC PC-FX, Nintendo VirtualBoy and Bandai WonderSwan.

It has an excellent debugger built-in that makes it a wonderful tool for developing homebrew games or language-translation patches.

Unfortunately, the debugger defaults to using low-resolution 5x7 pixel fonts that are poorly defined, and then displays them on small pages that 640x480 pixel-or-less in size.

This makes the debugging screens very hard to read, especially on modern high-resolution monitors.

In order to avoid eyestrain and annoyance, this project patches the Mednafen source to use slightly larger and better-defined fonts, and then to display them on larger 800x600 pixel pages.

The result looks like this (using the PC Engine debugger as an example) ...

![Modified Debugger](https://farm5.staticflickr.com/4823/32392679408_a85a16269a_o.png)

Compared to the original display ...

![Original Debugger](https://farm5.staticflickr.com/4873/32392679508_34b8193318_o.png)


## Limited Console Platforms

Although all of Mednafen's emulated consoles (that have debuggers) are patched, the included build script only compiles Mednafen to include the PlayStation, PC Engine, PC-FX, VirtualBoy and WonderSwan.

The Sega Saturn emulation is currently disabled because it is still considered to be in beta-test, and the debugger still lacks information.

If you want to build Mednafen for all of its supported platforms, then just edit the build script to change the configuration.


## Intended Directory Layout

Source code ...

<some_directory>/src/mednafen/

Mednafen build output ...

<some_directory>/bin/mednafen/


Please take particular note that this means that the output will be put in a directory above the source directory.

If you want to change this, you can edit the build script.


## Building on Windows (with MSYS2)

Install the base MSYS2 system, either 32-bit or 64-bit, from [here](https://www.msys2.org/).

Install the "base-devel" and "git" packages.
```
pacman -Sy
pacman -S --needed base-devel git
```

Build the toolchain (which downloads the Mednafen source and installs some prerequisite libraries).
```
cd <some_directory>/src/mednafen/
./build_mednafen.sh
```

Clean up the temporary directories.
```
./build_mednafen.sh clean
```


## Building on Debian (Linux)

Install the "build-essential" package to get the compiler.
```
sudo apt-get install build-essential
```

Install the static libraries that are needed to build Mednafen.
```
sudo apt-get install pkg-config libasound2-dev libsdl2-dev libsndfile1-dev zlib1g-dev
```

Build the toolchain.
```
cd <some_directory>/src/mednafen/
./build_mednafen.sh
```

Clean up the temporary directories.
```
./build_mednafen.sh clean
```

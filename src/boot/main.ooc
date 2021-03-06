import Kernel, Multiboot, devices/Display, memory/MM, Panic, Bochs, Console

kmain: func (mb: MultibootInfo*, magic: UInt32) {
    multiboot = mb@
    Kernel setup()

    "Welcome to " print()
    Display setFgColor(Color lightGreen, ||
        "oos" print()
    )
    " booted by " print()
    Display setFgColor(Color lightBlue, ||
        multiboot bootLoaderName as String print()
    )
    ".\n" println()

    "Total Memory: %6i kB" printfln(MM memorySize / 1024)
    "Used Memory:  %6i kB" printfln(MM usedMemory / 1024)
    "Free Memory:  %6i kB" printfln(MM freeMemory / 1024)
    '\n' print()

    "This is " print()
    Display setFgColor(Color lightRed, ||
        "a super cool " print()
        Display setFgColor(Color red, ||
            "example of " print()
        )
        "the new " print()
        Display setBgColor(Color magenta, ||
            "setFgColor and setBgColor" print()
        )
        " functions.\n" println()
    )

    Console run()
}

# Replr

## Introduction
Replr is a tool for for creating shbang runners from existing programs.
There is a future intention to extend functionality to support generating REPL programs using a similar approach.

## Usage
The user creates a config `replr` file which contains all the information required to compile a given script.

### replr file format
`type:` `shbang` or `repl` defining the behaviour the program should possess

`base_name:` `Value` where value is the name of an artifact for the program (For java `JavaReplr` is the artifact for source file `JavaReplr.java`)

`source_extension:` `.ext` The extension of source files for this language

`compile:` `compiler <%%>.ext` The compile command for this program, replacing `<%%>` with the `base_name` artifact

`run:` `runtime <%%>` The executor command for this program, replacing `<%%>` with the `base_name` artifact

`template:` Placed at the end of the config file, this will be printed into the source file, replacing instances of `<%%>` with the text found
in the file using this as a shbang. The shbang script file produced will similarly use `<%%>` separators to jump to different positions in the template.

### Filled template example
Template: 
```java
<%%>
public class JavaReplr {
<%%>
public static void main(String... args) {
<%%>
}
}
```

With shbang script:
```java
import java.utils.*;
<%%>
public void doNothing() {}
<%%>
System.out.println("Hello World!");
```

Produces java source file:
```java
import java.utils.*;

public class JavaReplr {
    public void doNothing() {}

    public static void main(String... args) {
        System.out.println("Hello World!");
    }
}
```

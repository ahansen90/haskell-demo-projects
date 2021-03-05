# Producer Consumer in Haskell

## Summary

This is an implementation of the producer-consumer problem in Haskell that I did
for my Operating Systems Principles class in 2017. `MVar`s are used to share memory across (green) threads, and synchronization is achieved using semaphores from the `unix` package. As this was an exercise using low-level primitives, I didn't make use of higher-level constructs such as STM as I usually would.

## Building

Assuming `stack` is available on the $PATH,

```
stack build
```

within the project directory will build it.

## Usage

`stack exec producer-consumer` within the project directory will execute the program with the default
arguments.

```
Available options:
  -b,--buffer-size ARG     Buffer length in bytes
  -p,--producers ARG       Number of producer threads
  -c,--consumers ARG       Number of consumer threads
  -i,--items ARG           Number of items to insert
  -h,--help                Show this help text
```

## Limitations

This will only work on Posix systems.

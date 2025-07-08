# bind_stager

This stager works just as MSF bind_tcp stager does, except for one situation. For illegal requests, the MSF stager would crash because they are illegal shellcode. However, this stager wouldn't as it registers signal handlers and would restore if signals like SIGSEGV are received.

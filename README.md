## Fly.io Distributed System Challenges

This is a repository of solutions to the Fly.io distributed system challenges at https://fly.io/dist-sys/. The solutions are written in Ruby. 

It runs Maelstrom inside a docker container. To start the container, run `docker run -v ./workloads:/opt/app/workloads  -it maelstrom-ruby:latest bash`.

To run the echo workload, run `./maelstrom/maelstrom test -w echo --bin workloads/echo.rb --time-limit 5` from inside the container's `/opt/app` directory.

When adding new workloads, you will need to make them executable before running maelstrom.